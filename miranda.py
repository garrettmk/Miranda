import sys, psutil, subprocess, sip, pymongo
import cupi as qp
from models import *
from queries import *
from productvalidator import *
from importhelper import FileImportHelper
from apis import *
from operations import *
from PyQt5 import QtGui, QtNetwork


########################################################################################################################


class MirandaDatabase(qp.MongoDatabase):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.connectedChanged.connect(self._create_indices)

    def _disambiguate_vendor_id(self, vendor):
        """Takes a Vendor object, a MapObjectReference to a Vendor, or a string representation of a Vendor's ObjectId,
        and returns an ObjectId."""
        if isinstance(vendor, Vendor):
            return vendor._id
        elif isinstance(vendor, qp.MapObjectReference) and vendor.referentType == 'Vendor':
            return vendor.referentId
        elif isinstance(vendor, str):
            return ObjectId(vendor)
        elif isinstance(vendor, dict) and vendor.get('referent_type', None) == 'Vendor':
            return vendor['referent_id']
        else:
            return None

    def _create_indices(self):
        """Create any necessary indices in the database."""
        products = self._get_collection(Product.__collection__)
        products.create_index([('vendor.referent_id', pymongo.ASCENDING), ('sku', pymongo.ASCENDING)], unique=True)
        products.create_index('category')
        products.create_index('rank')

        if 'text_index' not in products.index_information():
            products.create_index([('title', pymongo.TEXT),
                                   ('brand', pymongo.TEXT),
                                   ('model', pymongo.TEXT),
                                   ('sku', pymongo.TEXT),
                                   ('description', pymongo.TEXT)],
                                  default_language='english',
                                  name='text_index')

    def new_vendor_query(self, query=None, sort=None):
        """Helper method for returning a basic Vendor query object."""
        query = {} if query is None else query
        sort = {'title': qtc.Qt.AscendingOrder} if sort is None else sort
        return ObjectQuery(objectType='Vendor',
                           query=VendorQueryDocument(**query),
                           sort=VendorSortDocument(**sort))

    @qtc.pyqtSlot(result=ObjectQuery)
    def newVendorQuery(self):
        """QML frontend for the new_vendor_query() method. Transfers ownership of the query object to QML before
        returning."""
        q = self.new_vendor_query()
        sip.transferto(q, q)
        return q

    @qtc.pyqtSlot(qtc.QVariant, result=str)
    def getVendorName(self, vendor):
        """Helper method to return the name of a product's vendor."""
        vendor_id = self._disambiguate_vendor_id(vendor)
        if vendor_id is None:
            return None

        collection = self._get_collection(Vendor.__collection__)
        doc = collection.find_one({'_id': vendor_id}, projection={'title': 1})
        return doc['title'] if doc is not None else ''

    @qtc.pyqtSlot(qtc.QVariant, result=qtc.QVariant)
    def getVendor(self, vendor):
        obj = self.get_object(vendor, _type='Vendor')
        if obj is not None:
            sip.transferto(obj, obj)

        return obj

    @qtc.pyqtSlot(qtc.QVariant, result=bool)
    def isMarket(self, vendor):
        """Helper method the checks whether a given vendor (or reference to a vendor) is a market."""
        vendor_id = self._disambiguate_vendor_id(vendor)
        collection = self._get_collection(Vendor.__collection__)
        doc = collection.find_one({'_id': vendor_id}, projection={'is_market': 1})
        return doc.get('is_market', False) if doc is not None else None

    def new_product_query(self, query=None, sort=None):
        """Helper method for creating a basic Product query object."""
        query = {} if query is None else query
        sort = {'rank': qtc.Qt.AscendingOrder} if sort is None else sort
        return ObjectQuery(objectType='Product',
                           query=ProductQueryDocument(**query),
                           sort=ProductSortDocument(**sort))

    @qtc.pyqtSlot(result=ObjectQuery)
    def newProductQuery(self):
        """QML frontend for the new_product_query() method."""
        q = self.new_product_query()
        sip.transferto(q, q)
        return q

    def new_opportunity_query(self, query=None, sort=None):
        """Helper method for creating a basic relationship query."""
        query = {} if query is None else query
        sort = {'roi': qtc.Qt.DescendingOrder} if sort is None else sort
        return ObjectQuery(objectType='ProfitRelationship',
                           query=OpportunityQueryDocument(**query),
                           sort=OpportunitySortDocument(**sort))

    @qtc.pyqtSlot(result=ObjectQuery)
    def newOpportunityQuery(self):
        q = self.new_opportunity_query()
        sip.transferto(q, q)
        return q

    def new_operation_query(self, query=None, sort=None):
        """Helper method for creating a basic Operations query."""
        query = query if query is not None else {}
        sort = sort if sort is not None else {}
        return ObjectQuery(objectType='Operation',
                           query=OperationQueryDocument(**query),
                           sort=OperationSortDocument(**sort))

    @qtc.pyqtSlot(result=ObjectQuery)
    def newOperationQuery(self):
        """QML frontend for new_operation_query()."""
        q = self.new_operation_query()
        sip.transferto(q, q)
        return q

    @qtc.pyqtSlot(qtc.QVariant, result=qtc.QVariant)
    def getProductHeader(self, product_ref):
        collection = self._get_collection(Product.__collection__)
        doc = collection.find_one({'_id': product_ref.referentId}, projection={'title': 1,
                                                                               'detail_page_url': 1,
                                                                               'vendor': 1,
                                                                               'sku': 1})
        if doc is None:
            return None

        doc['vendor'] = self.getVendorName(doc['vendor'])
        return doc

    def new_quantity_validator(self, **kwargs):
        """Helper method to create a QuantityValidator, preloaded with a saved QuantityValidatorData object."""
        data = self.get_object(ObjectQuery(objectType='QuantityValidatorData'))
        data = data if data is not None else QuantityValidatorData()
        return QuantityValidator(map=data, **kwargs)

    @qtc.pyqtSlot(result=QuantityValidator)
    def newQuantityValidator(self):
        """QML frontend for new_quantity_validator()."""
        val = self.new_quantity_validator()
        sip.transferto(val, val)
        return val


########################################################################################################################


class MirandaApp(qp.App):

    register_classes = [FileImportHelper,
                        Validator]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._db = MirandaDatabase()
        self._network = QtNetwork.QNetworkAccessManager(self)
        self._amazon_mws = AmazonMWS(network=self._network, running=True)
        self._amazon_pa = AmazonPA(network=self._network, running=True)
        self._operations = OperationsManager(self)

    def prepare_root_context(self, context):
        context.setContextProperty('application', self)
        context.setContextProperty('database', self._db)

    @qtc.pyqtSlot(str)
    def setClipboardText(self, text):
        self.clipboard().setText(text)

    databaseChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(QtCore.QVariant, notify=databaseChanged)
    def database(self):
        return self._db

    operationsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(QtCore.QVariant, notify=operationsChanged)
    def operations(self):
        return self._operations

    amazonMWSChanged = qtc.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=amazonMWSChanged)
    def amazonMWS(self):
        return self._amazon_mws

    amazonPAChanged = qtc.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=amazonPAChanged)
    def amazonPA(self):
        return self._amazon_pa


########################################################################################################################


if __name__ == '__main__':
    # Start mongod if it isn't already running
    if 'mongod' not in (p.name() for p in psutil.process_iter()):
        subprocess.Popen(['mongod'])

    app = MirandaApp(sys.argv + ['-style', 'material'])
    app.prepare(load_file='ui/miranda.qml', cupi_path='../Cupi')
    app.exec_()