from datetime import datetime, timedelta, timezone
from tzlocal import get_localzone
from PyQt5 import QtCore, QtNetwork
from queries import ObjectQuery, ProductQueryDocument, ProductSortDocument
from models import Product, ProfitRelationship, MarketLink, SupplierLink
from apis import ListMatchingProducts, GetMatchingProductForId, GetCompetitivePricingForASIN, GetMyFeesEstimate, ItemLookup
from productvalidator import PriceValidator, QuantityValidator
import cupi as qp


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


class ProductOperation(Operation):
    """An operation that acts on a group of products, designated by a ProductQuery."""

    productQueryChanged = QtCore.pyqtSignal()
    productQuery = qp.MapObjectProperty('product_query',
                                        _type=ObjectQuery,
                                        notify=productQueryChanged,
                                        default=lambda s: ObjectQuery(objectType='Product',
                                                                      query=ProductQueryDocument(),
                                                                      sort=ProductSortDocument()))

    def get_next_product(self):
        """Returns the next product given by productQuery that has not been stamped."""
        unstamped = {'operation_log.operation_id': {'$nin': [self._id]}}
        query_copy = qp.MapObject.from_document(self.productQuery.current_document)
        query_copy.query.update(unstamped)

        prod = self.application.database.get_object(query_copy)
        if prod is not None:
            self.application.database.get_referenced_object(prod.vendor)

        return prod

    def stamp_product(self, product, succeeded, message=None):
        """Places an entry in the product's operation_log, indicating whether the operation succeeded and providing
        additional information in message."""
        stamp = {'operation_id': self._id,
                 'succeeded': succeeded,
                 'message': message}
        product.operationLog.append(stamp)
        self.application.database.saveObject(product)


########################################################################################################################


class FindMarketMatches(ProductOperation):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._vendor_product = None
        self._matched_products = {}
        self._lmp_call = None
        self._gcp_call = None
        self._lookup_call = None
        self._gfe_call = None

    def start(self):
        self._matched_products = {}
        self._vendor_product = self.get_next_product()
        if self._vendor_product is None:
            self.active = False
            self.finished.emit()
            return
        else:
            self._vendor_product.setParent(self)

        if self._vendor_product.brand and self._vendor_product.model:
            query_str = self._vendor_product.brand + ' ' + self._vendor_product.model
        else:
            query_str = self._vendor_product.title

        self._lmp_call = ListMatchingProducts(query=query_str)
        self._lmp_call.finished.connect(self._parse_lmp_call)
        self.application.amazonMWS.enqueue(self._lmp_call)

    def finish(self):
        self._lmp_call = None
        self._gcp_call = None
        self._lookup_call = None
        if self._vendor_product is not None:
            self._vendor_product.setParent(None)
            self._vendor_product = None
        self.finished.emit()

    def _parse_lmp_call(self):
        if not self._lmp_call.succeeded:
            self.stamp_product(self._vendor_product, False, self._lmp_call.errorMessage)
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
            self.stamp_product(self._vendor_product, True)
            self.finish()

    def _parse_gcp_call(self):
        if not self._gcp_call.succeeded:
            return

        for price_group in self._gcp_call.prices:
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
            self.stamp_product(self._vendor_product, False, self._lookup_call.errorMessage)
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
            self.stamp_product(self._vendor_product, False, "No valid matches found.")
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

        for match in self._matched_products.values():
            # Check if the product is already in the database
            existing_query = db.new_product_query(query={'vendor': amazon, 'sku': match['sku']})
            matched_product = db.get_object(existing_query)
            if matched_product is None:
                matched_product = Product(vendor=qp.MapObjectReference(ref=amazon), sku=match['sku'])

            # Update the product in the database
            matched_product.update(match)

            price_validator.product = matched_product
            quant_validator.product = matched_product

            db.saveObject(matched_product)

            # Update or create a profit relationship
            rel = db.get_object(db.new_opportunity_query(query={'marketListing': matched_product,
                                                                 'supplierListing': self._vendor_product}))

            rel = rel if rel is not None else ProfitRelationship()
            rel.marketListing.ref = matched_product
            rel.supplierListing.ref = self._vendor_product
            rel.refresh()
            db.saveObject(rel)

        self.stamp_product(self._vendor_product, True)
        self.finish()


########################################################################################################################


class UpdateProducts(ProductOperation):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._current_product = None
        self._update = None
        self._lookup_call = None
        self._get_pricing_call = None

    def start(self):
        product = self.get_next_product()
        if product is None:
            self.active = False
            self.finish()
            return
        elif not product.sku:
            self.stamp_product(product, succeeded=False, message='SKU required')
            self.finish()

        self._get_pricing_call = GetCompetitivePricingForASIN(asins=[product.sku])
        self._get_pricing_call.finished.connect(self._parse_get_pricing)
        self.application.amazonMWS.enqueue(self._get_pricing_call)

    def _parse_get_pricing(self):
        if self._get_pricing_call.succeeded:
            self._get_pricing_call.update_product(self._current_product)

        self._lookup_call = ItemLookup(asins=[self._current_product.sku])
        self._lookup_call.finished.connect(self._parse_lookup)
        self.application.amazonPA.enqueue(self._lookup_call)

    def _parse_lookup(self):
        if not self._lookup_call.succeeded:
            self.stamp_product(self._current_product, succeeded=False, message=self._lookup_call.errorMessage)
            self.finish()
            return

        self._lookup_call.update_product(self._current_product, except_price=True)
        self.stamp_product(self._current_product, succeeded=True)
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
        self.set_status_message(f'processNext({kind})')

        kinds = [t.__name__ for t in Operation.subclasses()] if kind is None else [kind]
        kinds = [k for k in kinds if self._timers.get(k, None) is None]

        for kind in kinds:
            query = self._db.new_operation_query(query={'active': True},
                                                 sort={'scheduled': QtCore.Qt.AscendingOrder})
            query.objectType = kind
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

        self.set_status_message(f'{kind}: {op.name}')
        op.start()

    def on_op_finished(self, kind):
        self.set_status_message(f'on_op_finished({kind})')
        op = self._ops[kind]

        op.application = None
        op.finished.disconnect(self._lambdas[kind])

        if not op.active and op.repeat:
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


