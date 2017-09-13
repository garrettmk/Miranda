from datetime import datetime, timedelta, timezone
from tzlocal import get_localzone
from PyQt5 import QtCore, QtNetwork
from queries import *
from models import *
from apis import *
from productvalidator import PriceValidator, QuantityValidator
import cupi as qp
import sip


########################################################################################################################


class Operation(qp.MapObject):
    __collection__ = 'operations'

    application = None
    finished = QtCore.pyqtSignal()

    activeChanged = QtCore.pyqtSignal()
    active = qp.Property('active', _type=bool, default=False, notify=activeChanged)

    scheduledChanged = QtCore.pyqtSignal()
    scheduled = qp.DateTimeProperty('scheduled',
                                    default=lambda s: datetime.now(tz=get_localzone()),
                                    default_set=True,
                                    notify=scheduledChanged)

    repeatChanged = QtCore.pyqtSignal()
    repeat = qp.Property('repeat', default=None, notify=repeatChanged)

    nameChanged = QtCore.pyqtSignal()
    name = qp.Property('name', default=None, notify=nameChanged)

    def start(self):
        pass


########################################################################################################################


class DummyOperation(Operation):

    def start(self):
        print('Starting dummy operation...')
        self.startTimer(5000)

    def timerEvent(self, event):
        print('Finishing dummy operation...')
        self.killTimer(event.timerId())
        self.active = False
        self.finished.emit()


########################################################################################################################


class ObjectOperation(Operation):
    """A base class for operations that iterate through a query of objects."""

    objectQueryChanged = QtCore.pyqtSignal()
    objectQuery = qp.MapObjectProperty('object_query',
                                       _type=ObjectQuery,
                                       notify=objectQueryChanged,
                                       default=lambda s: s.default_query())

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.current_object = None

    @staticmethod
    def default_query():
        """Returns an ObjectQuery to use as the default query. Meant to be overridden by subclasses."""
        raise NotImplementedError

    def stamped_query(self):
        """Returns a copy of objectQuery, modified to only return stamped objects."""
        stamped = {
            'operation_log.operation_id': {
                '$in': [self._id]
            }
        }

        q_copy = qp.MapObject.from_document(self.objectQuery.current_document)
        q_copy.query.update(stamped)
        return q_copy

    def unstamped_query(self):
        """Returns a copy of objectQuery, modified to only return unstamped objects."""
        unstamped = {
            'operation_log.operation_id': {
                '$nin': [self._id]
            }
        }

        q_copy = qp.MapObject.from_document(self.objectQuery.current_document)
        q_copy.query.update(unstamped)
        return q_copy

    @QtCore.pyqtSlot(result=ObjectQuery)
    def stampedQuery(self):
        q = self.stamped_query()
        sip.transferto(q, q)
        return q

    @QtCore.pyqtSlot(result=ObjectQuery)
    def unstampedQuery(self):
        q = self.unstamped_query()
        sip.transferto(q, q)
        return q

    def get_next_object(self):
        query = self.unstamped_query()
        obj = self.application.database.get_object(query, parent=self)
        self.current_object = obj
        return obj

    def stamp_object(self, object, succeeded, message=None):
        """Places an entry in the object's operations_log, indicating whether the operation was successfull
        and providing any additional information in the message."""
        stamp = {
            'operation_id': self._id,
            'succeeded': succeeded,
            'message': message
        }

        if 'operation_log' not in object:
            object['operation_log'] = []

        object['operation_log'].append(stamp)
        self.application.database.saveObject(object)

    def finish(self):
        if self.current_object is not None:
            self.current_object.deleteLater()

        self.current_object = None
        self.finished.emit()


########################################################################################################################


class FindMarketMatches(ObjectOperation):

    @staticmethod
    def default_query():
        return ObjectQuery(objectType='Product',
                           query=ProductQueryDocument(),
                           sort=ProductSortDocument())

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._matched_products = {}
        self._lmp_call = None
        self._gcp_call = None
        self._lookup_call = None
        self._gfe_call = None

    def start(self):
        product = self.get_next_object()
        if product is None:
            self.active = False
            self.finish()
            return
        else:
            self.application.database.get_referenced_object(product.vendor)

        if product.brand and product.model:
            query_str = product.brand + ' ' + product.model
        else:
            query_str = product.title

        self._lmp_call = ListMatchingProducts(query=query_str)
        self._lmp_call.finished.connect(self._parse_lmp_call)
        self.application.amazonMWS.enqueue(self._lmp_call)

    def finish(self):
        self._lmp_call = None
        self._gcp_call = None
        self._lookup_call = None
        self._matched_products = {}
        super().finish()

    def _parse_lmp_call(self):
        if not self._lmp_call.succeeded:
            self.stamp_object(self.current_object, False, self._lmp_call.errorMessage)
            self.finish()
            return

        self._matched_products = {
            match.get('sku'): {
                'category': match.get('category', None),
                'rank': match.get('rank', None)
            } for match in self._lmp_call.products
        }

        if self._matched_products:
            self._gcp_call = GetCompetitivePricingForASIN(asins=self._matched_products.keys())
            self._gcp_call.finished.connect(self._parse_gcp_call)
            self.application.amazonMWS.enqueue(self._gcp_call)
        else:
            self.stamp_object(self.current_object, True)
            self.finish()

    def _parse_gcp_call(self):
        for price_group in self._gcp_call.prices:
            if 'error' in price_group:
                continue

            sku = price_group['sku']
            landed_price = price_group.get('landed_price', None)
            listing_price = price_group.get('listing_price', None)
            shipping = price_group.get('shipping', 0)

            if landed_price is not None:
                price = landed_price
            elif listing_price is not None:
                price = listing_price + shipping
            else:
                continue

            self._matched_products[sku]['price'] = price
            self._matched_products[sku]['offers'] = price_group.get('offers', 1)

        self._lookup_call = ItemLookup(asins=self._matched_products.keys())
        self._lookup_call.finished.connect(self._parse_lookup_call)
        self.application.amazonPA.enqueue(self._lookup_call)

    def _parse_lookup_call(self):
        if not self._lookup_call.succeeded:
            self.stamp_object(self.current_object, False, self._lookup_call.errorMessage)
            self.finish()
            return

        for product in self._lookup_call.products:
            asin = product['sku']
            if 'error' in product:
                del self._matched_products[asin]
                continue

            if 'price' in self._matched_products[asin]:
                product.pop('price', None)

            self._matched_products[asin].update(product)

        asins = [key for key, value in self._matched_products.items() if value.get('price', None)]
        if not asins:
            self.stamp_object(self.current_object, False, "No valid matches found.")
            self.finish()
            return

        prices = [self._matched_products[asin].get('price') for asin in asins]
        self._gfe_call = GetMyFeesEstimate(asins=asins, prices=prices)
        self._gfe_call.finished.connect(self._parse_gfe_call)
        self.application.amazonMWS.enqueue(self._gfe_call)

    def _parse_gfe_call(self):
        for total in self._gfe_call.feeTotals:
            sku = total['sku']
            if total.pop('error', None) and 'price' in self._matched_products[sku]:
                total['market_fees'] = self._matched_products[sku]['price'] * 0.30

            self._matched_products[sku]['market_fees'] = total['market_fees']

        self._all_data_received()

    def _all_data_received(self):
        db = self.application.database
        price_validator = PriceValidator(always_apply=True)
        quant_validator = db.new_quantity_validator(always_apply=True)
        amazon = db.get_object(db.new_vendor_query(query={'title': 'Amazon'}), parent=self)

        for asin, match in self._matched_products.items():
            # Check if the product is already in the database
            existing_query = db.new_product_query(query={'vendor': amazon, 'sku': asin})

            matched_product = db.get_object(existing_query)
            if matched_product is None:
                matched_product = Product(vendor=qp.MapObjectReference(ref=amazon), sku=asin)

            # Update the product in the database
            matched_product.update(match)

            price_validator.product = matched_product
            quant_validator.product = matched_product

            db.saveObject(matched_product)

            # Update or create a profit relationship
            rel = db.get_object(db.new_opportunity_query(query={'marketListing': matched_product,
                                                                 'supplierListing': self.current_object}))

            rel = rel if rel is not None else ProfitRelationship()
            rel.marketListing.ref = matched_product
            rel.supplierListing.ref = self.current_object
            rel.refresh()
            db.saveObject(rel)

        self.stamp_object(self.current_object, True)
        self.finish()


########################################################################################################################


class UpdateProducts(ObjectOperation):

    logChanged = QtCore.pyqtSignal()
    log = qp.Property('log', _type=bool, default=False, notify=logChanged)

    @staticmethod
    def default_query():
        return ObjectQuery(objectType='Product',
                           query=ProductQueryDocument(),
                           sort=ProductSortDocument())

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._update = None
        self._lookup_call = None
        self._get_pricing_call = None

    def start(self):
        product = self.get_next_object()
        if product is None:
            self.active = False
            self.finish()
            return
        elif not product.sku:
            self.stamp_object(product, succeeded=False, message='SKU required')
            self.finish()

        self._get_pricing_call = GetCompetitivePricingForASIN(asins=[product.sku])
        self._get_pricing_call.finished.connect(self._parse_get_pricing)
        self.application.amazonMWS.enqueue(self._get_pricing_call)

    def finish(self):
        self._update = None
        self._lookup_call = None
        self._get_pricing_call = None
        super().finish()

    def _parse_get_pricing(self):
        if self._get_pricing_call.succeeded:
            self._get_pricing_call.update_product(self.current_object)

        self._lookup_call = ItemLookup(asins=[self.current_object.sku])
        self._lookup_call.finished.connect(self._parse_lookup)
        self.application.amazonPA.enqueue(self._lookup_call)

    def _parse_lookup(self):
        if not self._lookup_call.succeeded:
            self.stamp_object(self.current_object, succeeded=False, message=self._lookup_call.errorMessage)
            self.finish()
            return

        self._lookup_call.update_product(self.current_object, except_price=True)

        if self.log:
            q = self.application.database.new_product_history_query(query={'product': self.current_object})
            history = self.application.database.get_object(q)
            if history is None:
                history = ProductHistory(product=qp.MapObjectReference(ref=self.current_object))
            history.add_to_history(self.current_object)
            self.application.database.saveObject(history)

        self.stamp_object(self.current_object, succeeded=True)
        self.finish()


########################################################################################################################


class UpdateOpportunities(ObjectOperation):

    @staticmethod
    def default_query():
        return ObjectQuery(objectType='ProfitRelationship',
                           query=OpportunityQueryDocument(),
                           sort=OpportunitySortDocument())

    def start(self):
        opp = self.get_next_object()
        if opp is None:
            self.active = False
            self.finish()
            return

        db = self.application.database
        if db.get_referenced_object(opp.marketListing) is None\
            or db.get_referenced_object(opp.supplierListing) is None:
            self.stamp_object(opp, succeeded=False, message='marketListing or supplierListing not found.')
            self.finish()
            return

        db.get_referenced_object(opp.marketListing.ref.vendor)
        db.get_referenced_object(opp.supplierListing.ref.vendor)

        price_validator = PriceValidator(always_apply=True)
        quant_validator = db.new_quantity_validator(always_apply=True)

        for listing in (opp.marketListing.ref, opp.supplierListing.ref):
            price_validator.product = listing
            quant_validator.product = listing
            price_validator.apply()
            quant_validator.apply()

        opp.refresh()
        db.saveObject(opp)
        self.stamp_object(opp, succeeded=True)
        self.finish()





########################################################################################################################


class OperationsManager(QtCore.QObject):

    def __init__(self, app, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._app = app
        self._db = app.database
        self._running = False
        self._status_message = ""
        self._min_priority = 0
        self._ops = {}
        self._timers = {}
        self._lambdas = {}

    @QtCore.pyqtSlot(str)
    def processNext(self, kind=None):
        """Process the next operation of type :kind:, or all operations of kind=None."""
        kinds = [t.__name__ for t in Operation.subclasses()] if kind is None else [kind]
        kinds = [k for k in kinds if self._timers.get(k, None) is None]

        for kind in kinds:
            query = self._db.new_operation_query(query={'active': True},
                                                 sort={'scheduled': QtCore.Qt.AscendingOrder})
            query.objectType = kind
            query.includeSubclasses = False

            op = self._db.get_object(query)
            if op is None:
                continue

            self._ops[kind] = op
            now = datetime.now(tz=timezone.utc)
            wait = max((op.scheduled - now).total_seconds(), 0) * 1000
            timer_id = self.startTimer(wait)
            self._timers[kind] = timer_id

    def timerEvent(self, event):
        """Starts the next operation."""
        timer_id = event.timerId()
        kind = [k for k, t_id in self._timers.items() if t_id == timer_id][0]
        self.killTimer(timer_id)
        self._timers[kind] = None

        op = self._ops[kind]
        op.application = self._app

        if kind not in self._lambdas:
            self._lambdas[kind] = lambda k=kind: self.on_op_finished(k)
        op.finished.connect(self._lambdas[kind])

        self.set_status_message(f'{datetime.now(tz=get_localzone())} {kind}: {op.name}...')
        op.start()

    def on_op_finished(self, kind):
        op = self._ops[kind]

        op.application = None
        op.finished.disconnect(self._lambdas[kind])

        if not op.active and op.repeat:
            self._db.clear_op_logs(op)
            op.scheduled = datetime.now(tz=timezone.utc) + timedelta(hours=op.repeat)
            op.active = True

        self._db.saveObject(op)

        if self.running:
            self.processNext(kind)

    statusMessageChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(str, notify=statusMessageChanged)
    def statusMessage(self):
        return self._status_message

    def set_status_message(self, msg):
        self._status_message = msg
        self.statusMessageChanged.emit()

    runningChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=runningChanged)
    def running(self):
        return self._running

    def set_running(self, value):
        self._running = value
        self.runningChanged.emit()

    minPriorityChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(int, notify=minPriorityChanged)
    def minPriority(self):
        return self._min_priority

    @minPriority.setter
    def minPriority(self, value):
        self._min_priority = value
        self.minPriorityChanged.emit()

    @QtCore.pyqtSlot()
    def stop(self):
        self.set_status_message('Stopping...')
        self.set_running(False)
        for timer_id in (t_id for t_id in self._timers.values() if t_id is not None):
            self.killTimer(timer_id)

    @QtCore.pyqtSlot()
    def start(self):
        self.set_status_message('Starting...')
        self.set_running(True)
        self.processNext()


########################################################################################################################




