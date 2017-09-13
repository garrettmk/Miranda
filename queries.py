import cupi as qp
import PyQt5.QtCore as qtc
from models import Vendor
from bson import ObjectId


########################################################################################################################


class ObjectQuery(qp.MongoQuery):

    __collection__ = 'queries'

    nameChanged = qtc.pyqtSignal()
    name = qp.Property('name', str, default='New query', notify=nameChanged)


########################################################################################################################


class QueryQueryDocument(qp.MongoQueryDocument):

    objectTypeChanged = qtc.pyqtSignal()
    objectType = qp.QueryProperty('object_type', 'equals', notify=objectTypeChanged)


########################################################################################################################


class VendorQueryDocument(qp.MongoQueryDocument):

    titleChanged = qtc.pyqtSignal()
    title = qp.QueryProperty('title', 'regex', notify=titleChanged)

    websiteChanged = qtc.pyqtSignal()
    website = qp.QueryProperty('website', 'regex', notify=websiteChanged)


########################################################################################################################


class VendorSortDocument(qp.MongoSortDocument):

    titleChanged = qtc.pyqtSignal()
    title = qp.SortProperty('title', notify=titleChanged)

    websiteChanged = qtc.pyqtSignal()
    website = qp.SortProperty('website', notify=websiteChanged)


########################################################################################################################


class ProductQueryDocument(qp.MongoQueryDocument):

    vendorChanged = qtc.pyqtSignal()
    vendor = qp.QueryReferenceProperty('vendor', notify=vendorChanged)

    skuChanged = qtc.pyqtSignal()
    sku = qp.QueryProperty('sku', 'equals', notify=skuChanged)

    titleChanged = qtc.pyqtSignal()
    title = qp.QueryProperty('title', 'regex', notify=titleChanged)

    brandChanged = qtc.pyqtSignal()
    brand = qp.QueryProperty('brand', 'regex', notify=brandChanged)

    modelChanged = qtc.pyqtSignal()
    model = qp.QueryProperty('model', 'regex', notify=modelChanged)

    categoryChanged = qtc.pyqtSignal()
    category = qp.QueryProperty('category', 'regex', notify=categoryChanged)

    minRankChanged = qtc.pyqtSignal()
    minRank = qp.QueryProperty('rank', 'range_min', notify=minRankChanged)

    maxRankChanged = qtc.pyqtSignal()
    maxRank = qp.QueryProperty('rank', 'range_max', notify=maxRankChanged)

    feedbackChanged = qtc.pyqtSignal()
    feedback = qp.QueryProperty('feedback', 'range_min', notify=feedbackChanged)

    tagsChanged = qtc.pyqtSignal()
    tags = qp.QueryProperty('tags', 'elements_all', notify=tagsChanged)


########################################################################################################################


class ProductSortDocument(qp.MongoSortDocument):

    titleChanged = qtc.pyqtSignal()
    title = qp.SortProperty('title', notify=titleChanged)

    brandChanged = qtc.pyqtSignal()
    brand = qp.SortProperty('brand', notify=brandChanged)

    modelChanged = qtc.pyqtSignal()
    model = qp.SortProperty('model', notify=modelChanged)

    categoryChanged = qtc.pyqtSignal()
    category = qp.SortProperty('category', notify=categoryChanged)

    rankChanged = qtc.pyqtSignal()
    rank = qp.SortProperty('rank', notify=rankChanged)

    feedbackChanged = qtc.pyqtSignal()
    feedback = qp.SortProperty('feedback', notify=feedbackChanged)


########################################################################################################################


class OpportunityQueryDocument(qp.MongoQueryDocument):

    marketVendorChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=marketVendorChanged)
    def marketVendor(self):
        return str(self.get('market_listing.vendor_id', ''))

    @marketVendor.setter
    def marketVendor(self, obj):
        if obj is None:
            _id = None
        elif isinstance(obj, ObjectId):
            _id = obj
        elif isinstance(obj, str):
            _id = ObjectId(obj) if len(obj) else None
        elif isinstance(obj, qp.MapObjectReference):
            _id = obj.referentId
        elif isinstance(obj, Vendor):
            _id = obj._id
        else:
            raise TypeError(f'Expected ObjectId, MapObjectReference, Vendor, or None; got {obj}')

        if _id is None:
            self.deleteFilter('market_listing.vendor_id')
        else:
            self.filterBy('market_listing.vendor_id', 'equals', _id)

    supplierVendorChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=supplierVendorChanged)
    def supplierVendor(self):
        return str(self.get('supplier_listing.vendor_id', ''))

    @supplierVendor.setter
    def supplierVendor(self, obj):
        if obj is None:
            self.deleteFilter('supplier_listing.vendor_id')
            return
        elif isinstance(obj, ObjectId):
            _id = obj
        elif isinstance(obj, qp.MapObjectReference):
            _id = obj.referentId
        elif isinstance(obj, Vendor):
            _id = obj._id
        else:
            raise TypeError(f'Expected ObjectId, MapObjectReference, Vendor, or None; got {obj}')

        self.filterBy('supplier_listing.vendor_id', 'equals', _id)

    marketListingChanged = qtc.pyqtSignal()
    marketListing = qp.QueryReferenceProperty('market_listing', notify=marketListingChanged)

    minMarketRankChanged = qtc.pyqtSignal()
    minMarketRank = qp.QueryProperty('market_listing.rank', 'range_min', notify=minMarketRankChanged)

    maxMarketRankChanged = qtc.pyqtSignal()
    maxMarketRank = qp.QueryProperty('market_listing.rank', 'range_max', notify=maxMarketRankChanged)

    supplierListingChanged = qtc.pyqtSignal()
    supplierListing = qp.QueryReferenceProperty('supplier_listing', notify=supplierListingChanged)

    minSimilarityChanged = qtc.pyqtSignal()
    minSimilarity = qp.QueryProperty('similarity_score', 'range_min', notify=minSimilarityChanged)

    minProfitChanged = qtc.pyqtSignal()
    minProfit = qp.QueryProperty('profit', 'range_min', notify=minProfitChanged)

    minMarginChanged = qtc.pyqtSignal()
    minMargin = qp.QueryProperty('margin', 'range_min', notify=minMarginChanged)

    minROIChanged = qtc.pyqtSignal()
    minROI = qp.QueryProperty('roi', 'range_min', notify=minROIChanged)


########################################################################################################################


class OpportunitySortDocument(qp.MongoSortDocument):

    marketVendorChanged = qtc.pyqtSignal()
    marketVendor = qp.SortProperty('market_listing.vendor_id', notify=marketVendorChanged)

    marketRankChanged = qtc.pyqtSignal()
    marketRank = qp.SortProperty('market_listing.rank', notify=marketRankChanged)

    supplierVendorChanged = qtc.pyqtSignal()
    supplierVendor = qp.SortProperty('supplier_listing.vendor_id', notify=supplierVendorChanged)

    profitChanged = qtc.pyqtSignal()
    profit = qp.SortProperty('profit', notify=profitChanged)

    marginChanged = qtc.pyqtSignal()
    margin = qp.SortProperty('margin', notify=marginChanged)

    roiChanged = qtc.pyqtSignal()
    roi = qp.SortProperty('roi', notify=roiChanged)


########################################################################################################################


class OperationQueryDocument(qp.MongoQueryDocument):

    activeChanged = qtc.pyqtSignal()
    active = qp.QueryProperty('active', 'equals', notify=activeChanged)

    minPriorityChanged = qtc.pyqtSignal()
    minPriority = qp.QueryProperty('priority', 'range_min', notify=minPriorityChanged)

    scheduledBeforeChanged = qtc.pyqtSignal()
    scheduledBefore = qp.QueryProperty('scheduled', 'range_max', notify=scheduledBeforeChanged)

    nameChanged = qtc.pyqtSignal()
    name = qp.QueryProperty('name', 'regex', notify=nameChanged)

    opTypeChanged = qtc.pyqtSignal()
    opType = qp.QueryProperty('_type', 'equals', notify=opTypeChanged)


########################################################################################################################


class OperationSortDocument(qp.MongoSortDocument):

    priorityChanged = qtc.pyqtSignal()
    priority = qp.SortProperty('priority', notify=priorityChanged)

    scheduledChanged = qtc.pyqtSignal()
    scheduled = qp.SortProperty('scheduled', notify=scheduledChanged)

    typeChanged = qtc.pyqtSignal()
    type = qp.SortProperty('_type', notify=typeChanged)


########################################################################################################################


class ProductHistoryQueryDocument(qp.MongoQueryDocument):

    productChanged = qtc.pyqtSignal()
    product = qp.QueryReferenceProperty('product', notify=productChanged)