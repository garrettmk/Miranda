import cupi as qp
import PyQt5.QtCore as qtc


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