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
    tags = qp.ListProperty('tags', default=[], default_set=True, notify=tagsChanged)

    vendorChanged = qtc.pyqtSignal()
    vendor = qp.MapObjectProperty('vendor', _type=qp.MapObjectReference, notify=vendorChanged)

    skuChanged = qtc.pyqtSignal()
    sku = qp.Property('sku', str, default='', notify=skuChanged)

    titleChanged = qtc.pyqtSignal()
    title = qp.Property('title', str, default='', notify=titleChanged)

    brandChanged = qtc.pyqtSignal()
    brand = qp.Property('brand', str, default='', notify=brandChanged)

    modelChanged = qtc.pyqtSignal()
    model = qp.Property('model', str, default='', notify=modelChanged)

    upcChanged = qtc.pyqtSignal()
    upc = qp.Property('upc', str, default='', notify=upcChanged)

    priceChanged = qtc.pyqtSignal()
    price = qp.Property('price', float, default=0, notify=priceChanged)

    quantityChanged = qtc.pyqtSignal()
    quantity = qp.Property('quantity', int, default=1, notify=quantityChanged)

    detailPageUrlChanged = qtc.pyqtSignal()
    detailPageUrl = qp.Property('detail_page_url', str, default='', notify=detailPageUrlChanged)

    imageUrlChanged = qtc.pyqtSignal()
    imageUrl = qp.Property('image_url', str, default='', notify=imageUrlChanged)

    rankChanged = qtc.pyqtSignal()
    rank = qp.Property('rank', int, default=0, notify=rankChanged)

    categoryChanged = qtc.pyqtSignal()
    category = qp.Property('category', str, default='', notify=categoryChanged)

    feedbackChanged = qtc.pyqtSignal()
    feedback = qp.Property('feedback', float, default=-1, notify=feedbackChanged)

    associatedProductsChanged = qtc.pyqtSignal()
    associatedProducts = qp.ObjectModelProperty('associated_products', _type=qp.MapObjectReference, notify=associatedProductsChanged)

    matchedProductsChanged = qtc.pyqtSignal()
    matchedProducts = qp.ObjectModelProperty('matched_products', _type=qp.MapObjectReference, notify=matchedProductsChanged)

    descriptionChanged = qtc.pyqtSignal()
    description = qp.Property('description', str, default='', notify=descriptionChanged)

    unitPriceChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(float, notify=unitPriceChanged)
    def unitPrice(self):
        try:
            return self.price / self.quantity
        except ZeroDivisionError:
            return 0