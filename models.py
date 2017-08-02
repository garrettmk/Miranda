import PyQt5.QtCore as qtc
import cupi as qp
import datetime


########################################################################################################################


class Vendor(qp.MapObject):

    __collection__ = 'vendors'

    titleChanged = qtc.pyqtSignal()
    title = qp.Property('title', str, default='', notify=titleChanged)

    websiteChanged = qtc.pyqtSignal()
    website = qp.Property('website', str, default='', notify=websiteChanged)

    imageUrlChanged = qtc.pyqtSignal()
    imageUrl = qp.Property('image_url', str, default='', notify=imageUrlChanged)

    salesTaxChanged = qtc.pyqtSignal()
    salesTax = qp.Property('sales_tax', bool, default=False, notify=salesTaxChanged)

    shippingRateChanged = qtc.pyqtSignal()
    shippingRate = qp.Property('shipping_rate', float, default=0, notify=shippingRateChanged)


########################################################################################################################


class Product(qp.MapObject):

    __collection__ = 'products'

    lastUpdatedChanged = qtc.pyqtSignal()
    lastUpdated = qp.DateTimeProperty('last_updated')

    tagsChanged = qtc.pyqtSignal()
    tags = qp.ListProperty('tags', default=lambda s: list(), default_set=True, notify=tagsChanged)

    vendorChanged = qtc.pyqtSignal()
    vendor = qp.MapObjectProperty('vendor', _type=qp.MapObjectReference, notify=vendorChanged)

    skuChanged = qtc.pyqtSignal()
    sku = qp.Property('sku', default='', notify=skuChanged)

    titleChanged = qtc.pyqtSignal()
    title = qp.Property('title', default='', notify=titleChanged)

    brandChanged = qtc.pyqtSignal()
    brand = qp.Property('brand', default='', notify=brandChanged)

    modelChanged = qtc.pyqtSignal()
    model = qp.Property('model', default='', notify=modelChanged)

    upcChanged = qtc.pyqtSignal()
    upc = qp.Property('upc', default='', notify=upcChanged)

    priceChanged = qtc.pyqtSignal()
    price = qp.Property('price', default=0, notify=priceChanged)

    quantityChanged = qtc.pyqtSignal()
    quantity = qp.Property('quantity', default=None, notify=quantityChanged)

    detailPageUrlChanged = qtc.pyqtSignal()
    detailPageUrl = qp.Property('detail_page_url', default='', notify=detailPageUrlChanged)

    imageUrlChanged = qtc.pyqtSignal()
    imageUrl = qp.Property('image_url', default='', notify=imageUrlChanged)

    rankChanged = qtc.pyqtSignal()
    rank = qp.Property('rank', default=0, notify=rankChanged)

    categoryChanged = qtc.pyqtSignal()
    category = qp.Property('category', default='', notify=categoryChanged)

    feedbackChanged = qtc.pyqtSignal()
    feedback = qp.Property('feedback', default=-1, notify=feedbackChanged)

    matchedProductsChanged = qtc.pyqtSignal()
    matchedProducts = qp.ObjectModelProperty('matched_products', _type='ProductLink', notify=matchedProductsChanged)

    descriptionChanged = qtc.pyqtSignal()
    description = qp.Property('description', default='', notify=descriptionChanged)

    unitPriceChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(float, notify=unitPriceChanged)
    def unitPrice(self):
        try:
            return self.price / self.quantity
        except ZeroDivisionError:
            return 0


########################################################################################################################


class ProductLink(qp.MapObjectReference):

    referent_type = 'Product'

    similarityChanged = qtc.pyqtSignal()
    similarity = qp.Property('similarity', notify=similarityChanged)

    defaultChanged = qtc.pyqtSignal()
    default = qp.Property('default', default=False, notify=defaultChanged)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


########################################################################################################################


class QuantityValidatorData(qp.MapObject):
    __collection__ = 'data'

    mapChanged = qtc.pyqtSignal()
    map = qp.MapObjectProperty('map', notify=mapChanged)


########################################################################################################################


