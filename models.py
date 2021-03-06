import PyQt5.QtCore as qtc
from PyQt5 import QtQml

import cupi as qp
import re
from fuzzywuzzy import fuzz
from lxml import etree
from datetime import datetime, timezone
from tzlocal import get_localzone


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

    isMarketChanged = qtc.pyqtSignal()
    isMarket = qp.Property('is_market', bool, default=False, notify=isMarketChanged)


########################################################################################################################


class Product(qp.MapObject):

    __collection__ = 'products'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.priceChanged.connect(self.unitPriceChanged)
        self.quantityChanged.connect(self.unitPriceChanged)

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
    feedback = qp.Property('feedback', default=None, notify=feedbackChanged)

    descriptionChanged = qtc.pyqtSignal()
    description = qp.Property('description', default='', notify=descriptionChanged)

    unitPriceChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(float, notify=unitPriceChanged)
    def unitPrice(self):
        try:
            return self.price / self.quantity
        except (ZeroDivisionError, TypeError):
            return None

    marketFeesChanged = qtc.pyqtSignal()
    marketFees = qp.Property('market_fees', default=None, notify=marketFeesChanged)

    operationLogChanged = qtc.pyqtSignal()
    operationLog = qp.ListProperty('operation_log',
                                   default=lambda s: list(),
                                   default_set=True,
                                   notify=operationLogChanged)

    @qtc.pyqtSlot(qtc.QVariant)
    def addTags(self, tags):
        tags = tags.toVariant() if isinstance(tags, (qtc.QVariant, QtQml.QJSValue)) else tags
        self.tags = list(set(self.tags + list(tags)))

    @qtc.pyqtSlot(qtc.QVariant)
    def removeTags(self, tags):
        tags = tags.toVariant() if isinstance(tags, (qtc.QVariant, QtQml.QJSValue)) else tags
        self.tags = list(set(self.tags) - set(tags))


########################################################################################################################


class QuantityValidatorData(qp.MapObject):
    __collection__ = 'data'

    mapChanged = qtc.pyqtSignal()
    map = qp.Property('map', default=lambda s: dict(), default_set=True, notify=mapChanged)


########################################################################################################################


class SupplierLink(qp.MapObjectReference):
    referent_type = 'Product'

    # Mirrored values
    priceChanged = qtc.pyqtSignal()
    price = qp.Property('price', default=None, notify=priceChanged)

    quantityChanged = qtc.pyqtSignal()
    quantity = qp.Property('quantity', default=None, notify=quantityChanged)

    rankChanged = qtc.pyqtSignal()
    rank = qp.Property('rank', default=None, notify=rankChanged)

    shipRateChanged = qtc.pyqtSignal()
    shipRate = qp.Property('ship_rate', default=None, notify=shipRateChanged)

    vendorIdChanged = qtc.pyqtSignal()
    vendorId = qp.Property('vendor_id', default=None, notify=vendorIdChanged)

    def set_ref(self, obj):
        if self.ref is not None:
            self.ref.vendor.refChanged.disconnect(self._set_ship_rate)

        super().set_ref(obj)

        if obj is not None:
            self.vendorId = obj.vendor.referentId
            self._set_ship_rate()
            obj.vendor.refChanged.connect(self._set_ship_rate)
        else:
            self.vendorId = None

    def _set_ship_rate(self):
        if self.ref is not None and self.ref.vendor.ref is not None:
            self.shipRate = self.ref.vendor.ref.shippingRate


########################################################################################################################


class MarketLink(qp.MapObjectReference):
    referent_type = 'Product'

    # Mirrored values
    priceChanged = qtc.pyqtSignal()
    price = qp.Property('price', default=None, notify=priceChanged)

    quantityChanged = qtc.pyqtSignal()
    quantity = qp.Property('quantity', default=None, notify=quantityChanged)

    rankChanged = qtc.pyqtSignal()
    rank = qp.Property('rank', default=None, notify=rankChanged)

    marketFeesChanged = qtc.pyqtSignal()
    marketFees = qp.Property('market_fees', default=None, notify=marketFeesChanged)

    vendorIdChanged = qtc.pyqtSignal()
    vendorId = qp.Property('vendor_id', default=None, notify=vendorIdChanged)

    def set_ref(self, obj):
        super().set_ref(obj)
        if obj is not None:
            self.vendorId = obj.vendor.referentId
        else:
            self.vendorId = None


########################################################################################################################


class ProfitRelationship(qp.MapObject):
    __collection__ = 'relationships'

    marketListingChanged = qtc.pyqtSignal()
    marketListing = qp.MapObjectProperty('market_listing', _type=MarketLink, notify=marketListingChanged)

    supplierListingChanged = qtc.pyqtSignal()
    supplierListing = qp.MapObjectProperty('supplier_listing', _type=SupplierLink, notify=supplierListingChanged)

    # Calculated properties
    profitChanged = qtc.pyqtSignal()
    profit = qp.Property('profit', default=None, notify=profitChanged)

    marginChanged = qtc.pyqtSignal()
    margin = qp.Property('margin', default=None, notify=marginChanged)

    roiChanged = qtc.pyqtSignal()
    roi = qp.Property('roi', default=None, notify=roiChanged)

    similarityScoreChanged = qtc.pyqtSignal()
    similarityScore = qp.Property('similarity_score', default=None, notify=similarityScoreChanged, read_only=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.marketListing.priceChanged.connect(self.refresh)
        self.marketListing.marketFeesChanged.connect(self.refresh)
        self.marketListing.quantityChanged.connect(self.refresh)
        self.supplierListing.priceChanged.connect(self.refresh)
        self.supplierListing.quantityChanged.connect(self.refresh)
        self.supplierListing.shipRateChanged.connect(self.refresh)

    def _all_data_is_valid(self):
        params = (self.marketListing.price,
                  self.marketListing.quantity,
                  self.marketListing.marketFees or 0,
                  self.supplierListing.price,
                  self.supplierListing.quantity,
                  self.supplierListing.shipRate or 0)

        for param in params:
            if param is None\
                    or not isinstance(param, (int, float)):
                return False

        if 0 in (params[1], params[4]):
            return False

        return True

    def refresh(self):
        self._refresh_similarity()

        if not self._all_data_is_valid():
            self.profit = None
            self.margin = None
            self.roi = None
            return

        market_price = self.marketListing.price
        market_quantity = self.marketListing.quantity
        market_fees = self.marketListing.marketFees or 0
        vendor_price = self.supplierListing.price
        vendor_quantity = self.supplierListing.quantity
        ship_rate = self.supplierListing.shipRate or 0

        revenue = market_price - market_fees
        subtotal = (vendor_price / vendor_quantity) * market_quantity
        shipping = ship_rate * subtotal

        self.profit = revenue - subtotal - shipping

        try:
            self.margin = self.profit / market_price
        except ZeroDivisionError:
            self.margin = None

        self.roi = self.profit / (subtotal + shipping)

        self.revenueChanged.emit()
        self.subtotalChanged.emit()
        self.estShippingChanged.emit()
        self.estCOGSChanged.emit()

    def _refresh_similarity(self):
        if self.marketListing.ref is None\
                or self.supplierListing.ref is None:
            return

        def remove_symbols(s):
            return re.sub(r'[^a-zA-Z0-9 ]', '', s)

        def average_partial_ratio(s1, s2):
            sims = (
                fuzz.partial_ratio(s1, s2),
                fuzz.partial_ratio(s2, s1)
            )
            return sum(sims)/len(sims)

        market = self.marketListing.ref
        supplier = self.supplierListing.ref
        scores = []

        brand_m = remove_symbols(market.brand.lower().strip()) if isinstance(market.brand, str) else None
        brand_s = remove_symbols(supplier.brand.lower().strip()) if isinstance(supplier.brand, str) else None

        model_m = remove_symbols(market.model.lower().strip()) if isinstance(market.model, str) else None
        model_s = remove_symbols(supplier.model.lower().strip()) if isinstance(supplier.model, str) else None

        title_m = remove_symbols(market.title.lower().strip()) if isinstance(market.title, str) else None
        title_s = remove_symbols(supplier.title.lower().strip()) if isinstance(supplier.title, str) else None

        brand_scores = []
        if brand_m and brand_s:
            brand_scores.append(average_partial_ratio(brand_m, brand_s))
        elif brand_m and title_s:
            brand_scores.append(fuzz.partial_ratio(brand_m, title_s))
        elif brand_s and title_m:
            brand_scores.append(fuzz.partial_ratio(brand_s, title_m))

        if brand_scores:
            scores.append(max(brand_scores))

        model_scores = []
        if model_m and model_s:
            model_scores.append(average_partial_ratio(model_m, model_s))
        elif model_m and title_s:
            model_scores.append(fuzz.partial_ratio(model_m, title_s))
        elif model_s and title_m:
            model_scores.append(fuzz.partial_ratio(model_s, title_m))

        if model_scores:
            scores.extend((max(model_scores), max(model_scores)))

        if title_m and title_s:
            scores.append(fuzz.token_set_ratio(title_m, title_s))

        self['similarity_score'] = sum(scores) / len(scores) / 100 if scores else None
        self.similarityScoreChanged.emit()


    revenueChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=revenueChanged)
    def revenue(self):
        try:
            return self.marketListing.price - (self.marketListing.marketFees or 0)
        except TypeError:
            return None

    subtotalChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=subtotalChanged)
    def subtotal(self):
        try:
            return (self.supplierListing.price / self.supplierListing.quantity) * self.marketListing.quantity
        except TypeError:
            return None

    estShippingChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=estShippingChanged)
    def estShipping(self):
        try:
            return self.subtotal * self.supplierListing.shipRate
        except TypeError:
            return None

    estCOGSChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=estCOGSChanged)
    def estCOGS(self):
        try:
            return self.subtotal + self.estShipping
        except TypeError:
            return self.subtotal


########################################################################################################################


class APICall(qp.MapObject):
    __collection__ = 'apicalls'

    api = NotImplemented
    action = NotImplemented

    finished = qtc.pyqtSignal()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.finished.connect(self.parse_response)
        if 'rawResponse' in kwargs:
            self.parse_response()

    parametersChanged = qtc.pyqtSignal()
    parameters = qp.Property('parameters', default=None, notify=parametersChanged)

    rawResponseChanged = qtc.pyqtSignal()
    rawResponse = qp.Property('raw_response', default=None, notify=rawResponseChanged)

    errorCodeChanged = qtc.pyqtSignal()
    errorCode = qp.Property('error_code', default=None, notify=errorCodeChanged)

    errorMessageChanged = qtc.pyqtSignal()
    errorMessage = qp.Property('error_message', default=None, notify=errorMessageChanged)

    succeededChanged = qtc.pyqtSignal()
    succeeded = qp.Property('succeeded', default=None, notify=succeededChanged)

    isValidResponseChanged = qtc.pyqtSignal()
    isValidResponse = qp.Property('is_valid', default=None, notify=isValidResponseChanged)

    isErrorResponseChanged = qtc.pyqtSignal()
    isErrorResponse = qp.Property('is_error', default=None, notify=isErrorResponseChanged)

    def parse_response(self):
        """Called to parse rawResponse."""


########################################################################################################################


class AmazonMWSCall(APICall):
    api = 'AmazonMWS'

    @staticmethod
    def remove_namespaces(xml):
        """Removes all traces of namespaces from an XML string."""
        re_ns_decl = re.compile(r' xmlns(:\w*)?="[^"]*"', re.IGNORECASE)
        re_ns_open = re.compile(r'<\w+:')
        re_ns_close = re.compile(r'/\w+:')

        response = re_ns_decl.sub('', xml)          # Remove namespace declarations
        response = re_ns_open.sub('<', response)    # Remove namespaces in opening tags
        response = re_ns_close.sub('/', response)   # Remove namespaces in closing tags
        return response

    @staticmethod
    def xpath_get(tag, path, _type=str, default=None):
        try:
            data = tag.xpath(path)[0].text
            return _type(data)
        except (IndexError, ValueError, TypeError):
            return default


########################################################################################################################


class GetServiceStatus(AmazonMWSCall):
    action = 'GetServiceStatus'
    quota_max = 2
    restore_rate = 30
    hourly_max = 12

    statusChanged = qtc.pyqtSignal()
    status = qp.Property('status', default=None, notify=statusChanged)

    def parse_response(self):
        xml = self.remove_namespaces(self.rawResponse)
        tree = etree.fromstring(xml)

        self.status = tree.xpath('.//Status')[0].text
        self.succeeded = True


########################################################################################################################


class ListMatchingProducts(AmazonMWSCall):
    action = 'ListMatchingProducts'
    quota_max = 20
    restore_rate = 5
    hourly_max = 720

    parametersChanged = qtc.pyqtSignal()
    parameters = qp.Property('parameters',
                             notify=parametersChanged,
                             default_set=True,
                             default=lambda s: dict(MarketplaceId='ATVPDKIKX0DER', Query=''))

    productsChanged = qtc.pyqtSignal()
    products = qp.ListProperty('products', notify=productsChanged)

    queryChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(str, notify=queryChanged)
    def query(self):
        return self.parameters['Query']

    @query.setter
    def query(self, value):
        self.parameters['Query'] = str(value)
        self.queryChanged.emit()

    def parse_response(self):
        xml = self.remove_namespaces(self.rawResponse)
        xpath_get = AmazonMWSCall.xpath_get
        products = []
        try:
            tree = etree.fromstring(xml)
        except Exception as e:
            self.errorMessage = str(e)
            self.succeeded = False
            return

        if tree.xpath('Error'):
            self.errorMessage = tree.xpath('.//Error/Message')[0].text
            self.succeeded = False
            return

        for tag in tree.iterdescendants('Product'):
            product = dict()

            product['sku'] = xpath_get(tag, './Identifiers/MarketplaceASIN/ASIN')
            product['brand'] = xpath_get(tag, './/Brand')\
                                or xpath_get(tag, './/Manufacturer')\
                                or xpath_get(tag, './/Label')\
                                or xpath_get(tag, './/Publisher')\
                                or xpath_get(tag, './/Studio')
            product['model'] = xpath_get(tag, './/Model')\
                                or xpath_get(tag, './/PartNumber')
            product['price'] = xpath_get(tag, './/ListPrice/Amount', _type=float)
            product['NumberOfItems'] = xpath_get(tag, './/NumberOfItems', _type=int)
            product['PackageQuantity'] = xpath_get(tag, './/PackageQuantity', _type=int)
            product['image_url'] = xpath_get(tag, './/SmallImage/URL')
            product['title'] = xpath_get(tag, './/Title')

            for rank_tag in tag.iterdescendants('SalesRank'):
                if not rank_tag.xpath('./ProductCategoryId')[0].text.isdigit():
                    product['category'] = xpath_get(rank_tag, './ProductCategoryId')
                    product['rank'] = xpath_get(rank_tag, './Rank', _type=int)
                    break

            product['description'] = '\n'.join([t.text for t in tag.iterdescendants('Feature')]) or None

            products.append({k: v for k, v in product.items() if v is not None})

        self.products = products
        self.succeeded = True


########################################################################################################################


class GetMatchingProductForId(AmazonMWSCall):
    action = 'GetMatchingProductForId'
    quota_max = 20
    restore_rate = 0.2
    hourly_max = 18000

    parametersChanged = qtc.pyqtSignal()
    parameters = qp.Property('parameters',
                             default=lambda s: dict(MarketplaceId='ATVPDKIKX0DER', IdType='ASIN', IdList=['']),
                             default_set=True,
                             notify=parametersChanged)

    asinsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(list, notify=asinsChanged)
    def asins(self):
        return self.parameters['IdList']

    @asins.setter
    def asins(self, values):
        self.parameters['IdList'] = values
        self.asinsChanged.emit()

    productsChanged = qtc.pyqtSignal()
    products = qp.ListProperty('products', default=lambda s: list(), default_set=True, notify=productsChanged)

    def parse_response(self):
        xml = self.remove_namespaces(self.rawResponse)
        xpath_get = AmazonMWSCall.xpath_get
        products = []
        try:
            tree = etree.fromstring(xml)
        except Exception as e:
            self.errorMessage = str(e)
            self.succeeded = False
            return

        for result_tag in tree.iterdescendants('GetMatchingProductForIdResult'):
            product = {}

            # Check that the request for this ID succeeded
            if result_tag.attrib.get('status') != 'Success':
                product['sku'] = result_tag.attrib.get('Id')
                product['error'] = xpath_get(result_tag, './/Error/Message')
                products.append(product)
                continue

            product['sku'] = xpath_get(result_tag, './/Product/Identifiers/MarketplaceASIN/ASIN')
            product['brand'] = xpath_get(result_tag, './/Brand') \
                               or xpath_get(result_tag, './/Manufacturer') \
                               or xpath_get(result_tag, './/Label') \
                               or xpath_get(result_tag, './/Publisher') \
                               or xpath_get(result_tag, './/Studio')
            product['model'] = xpath_get(result_tag, './/Model') \
                               or xpath_get(result_tag, './/MPN') \
                               or xpath_get(result_tag, './/PartNumber')
            product['price'] = xpath_get(result_tag, './/ListPrice/Amount', _type=float)
            product['NumberOfItems'] = xpath_get(result_tag, './/NumberOfItems', _type=int)
            product['PackageQuantity'] = xpath_get(result_tag, './/PackageQuantity', _type=int)
            product['image_url'] = xpath_get(result_tag, './/SmallImage/URL')
            product['title'] = xpath_get(result_tag, './/Title')
            product['description'] = '\n'.join([t.text for t in result_tag.iterdescendants('Feature')]) or None
            product['detail_page_url'] = 'http://www.amazon.com/dp/' + product['sku']

            for rank_tag in result_tag.iterdescendants('SalesRank'):
                if not rank_tag.xpath('./ProductCategoryId')[0].text.isdigit():
                    product['category'] = xpath_get(rank_tag, './ProductCategoryId')
                    product['rank'] = xpath_get(rank_tag, './Rank', _type=int)
                    break

            product = {k: v for k, v in product.items() if v is not None}
            products.append(product)

        self.products = products

        # If at least one ID succeeded, mark the API call as succeeded
        if [1 for p in products if 'error' not in p] and len(products):
            self.succeeded = True
        else:
            self.errorMessage = xpath_get(tree, './/Error/Message')
            self.succeeded = False


########################################################################################################################


class GetCompetitivePricingForASIN(AmazonMWSCall):
    action = 'GetCompetitivePricingForASIN'
    quota_max = 20
    restore_rate = 0.1
    hourly_max = 36000

    parametersChanged = qtc.pyqtSignal()
    parameters = qp.Property('parameters',
                             default=lambda s: dict(MarketplaceId='ATVPDKIKX0DER', ASINList=[]),
                             default_set=True,
                             notify=parametersChanged)

    asinsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(list, notify=asinsChanged)
    def asins(self):
        return self.parameters['ASINList']

    @asins.setter
    def asins(self, values):
        self.parameters['ASINList'] = list(values)
        self.parametersChanged.emit()

    pricesChanged = qtc.pyqtSignal()
    prices = qp.ListProperty('prices', default=lambda s: list(), default_set=True, notify=pricesChanged)

    def parse_response(self):
        xml = self.remove_namespaces(self.rawResponse)
        xpath_get = AmazonMWSCall.xpath_get
        prices = []
        try:
            tree = etree.fromstring(xml)
        except Exception as e:
            self.errorMessage = str(e)
            self.succeeded = False
            return

        for result_tag in tree.iterdescendants('GetCompetitivePricingForASINResult'):
            price = {}

            # Check that the request for this ASIN succeeded
            if result_tag.attrib.get('status') != 'Success':
                price['sku'] = result_tag.attrib.get('ASIN')
                price['error'] = xpath_get(result_tag, './/Error/Message')
                prices.append(price)
                continue

            price['sku'] = xpath_get(result_tag, './/MarketplaceASIN/ASIN')

            for price_tag in result_tag.iterdescendants('CompetitivePrice'):
                if price_tag.attrib.get('condition') != 'New':
                    continue

                price['listing_price'] = xpath_get(price_tag, './/ListingPrice/Amount', _type=float)
                price['shipping'] = xpath_get(price_tag, './/Shipping/Amount', _type=float)
                price['landed_price'] = xpath_get(price_tag, './/LandedPrice/Amount', _type=float)

            for count_tag in result_tag.iterdescendants('OfferListingCount'):
                if count_tag.attrib.get('condition') == 'New':
                    price['offers'] = count_tag.text
            else:
                if 'offers' not in price:
                    price['offers'] = 0

            prices.append(price)

        self.prices = prices

        # If at least one ID succeeded, mark the api call as a success
        if [1 for p in prices if 'error' not in p] and len(prices):
            self.succeeded = True
        else:
            self.errorMessage = xpath_get(tree, './/Error/Message')
            self.succeeded = False

    def update_product(self, product):
        sku = product.sku
        try:
            price_group = [pg for pg in self.prices if pg['sku'] == sku][0]
        except (KeyError, IndexError):
            return False

        landed_price = price_group.get('landed_price', None)
        list_price = price_group.get('listing_price', None)
        shipping = price_group.get('shipping', 0)

        if landed_price is not None:
            product.price = landed_price
        elif list_price is not None:
            product.price = list_price + shipping

        return True

    @qtc.pyqtSlot(Product, result=bool)
    def updateProduct(self, product):
        return self.update_product(product)


########################################################################################################################


class GetMyFeesEstimate(AmazonMWSCall):
    action = 'GetMyFeesEstimate'
    quota_max = 20
    restore_rate = 0.1
    hourly_max = 36000

    parametersChanged = qtc.pyqtSignal()
    parameters = qp.Property('parameters',
                             default=lambda s: {'FeesEstimateRequestList': []},
                             default_set=True,
                             notify=parametersChanged)

    asinsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(list, notify=asinsChanged)
    def asins(self):
        return [req['IdValue'] for req in self.parameters['FeesEstimateRequestList']]

    @asins.setter
    def asins(self, values):
        self.parameters['FeesEstimateRequestList'] = [
            {
                'MarketplaceId': 'ATVPDKIKX0DER',
                'IdType': 'ASIN',
                'IdValue': asin,
                'IsAmazonFulfilled': 'true',
                'Identifier': 'request1',
                'PriceToEstimateFees.ListingPrice.CurrencyCode': 'USD',
                'PriceToEstimateFees.ListingPrice.Amount': 0
            }
            for asin in values
        ]

        self.asinsChanged.emit()

    pricesChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(list, notify=pricesChanged)
    def prices(self):
        return [req['PriceToEstimateFees.ListingPrice.Amount'] for req in self.parameters]

    @prices.setter
    def prices(self, values):
        for idx, price in enumerate(values):
            self.parameters['FeesEstimateRequestList'][idx]['PriceToEstimateFees.ListingPrice.Amount'] = price

        self.pricesChanged.emit()

    feeTotalsChanged = qtc.pyqtSignal()
    feeTotals = qp.ListProperty('fee_totals', default=lambda s: list(), default_set=True, notify=feeTotalsChanged)

    def parse_response(self):
        xml = self.remove_namespaces(self.rawResponse)
        try:
            tree = etree.fromstring(xml)
        except Exception as e:
            self.errorMessage = str(e)
            self.succeeded = False
            return

        xpath_get = AmazonMWSCall.xpath_get

        totals = []

        for result_tag in tree.iterdescendants('FeesEstimateResult'):
            total = {'sku': xpath_get(result_tag, './/IdValue')}

            if xpath_get(result_tag, './Status') != 'Success':
                total['error'] = xpath_get(result_tag, './/Error/Message')
                totals.append(total)
                continue

            total['market_fees'] = xpath_get(result_tag, './/TotalFeesEstimate/Amount', _type=float)
            totals.append(total)

        self.feeTotals = totals

        if [1 for t in totals if 'error' not in t] and len(totals):
            self.succeeded = True
        else:
            self.errorMessage = xpath_get(tree, './/Error/Message')
            self.succeeded = False


########################################################################################################################


class ItemLookup(AmazonMWSCall):
    action = 'ItemLookup'

    parametersChanged = qtc.pyqtSignal()
    parameters = qp.Property('parameters',
                             default=lambda s: dict(ItemId='', ResponseGroup='Images,ItemAttributes,OfferFull,SalesRank'
                                                                             ',EditorialReview'),
                             default_set=True,
                             notify=parametersChanged)

    asinsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(list, notify=asinsChanged)
    def asins(self):
        return [asin.strip() for asin in self.parameters['ItemId'].split(',')]

    @asins.setter
    def asins(self, values):
        self.parameters['ItemId'] = ','.join(values)
        self.asinsChanged.emit()

    productsChanged = qtc.pyqtSignal()
    products = qp.ListProperty('products', default=lambda s: list(), default_set=True, notify=productsChanged)

    def parse_response(self):
        xml = self.remove_namespaces(self.rawResponse)
        xpath_get = AmazonMWSCall.xpath_get
        products = []
        try:
            tree = etree.fromstring(xml)
        except Exception as e:
            self.errorMessage = str(e)
            self.succeeded = False
            return

        for error_tag in tree.iterdescendants('Error'):
            message = xpath_get(error_tag, './/Message')
            try: asin = [asin for asin in self.asins if asin in message][0]
            except IndexError: continue
            products.append({'sku': asin, 'error': message})

        for item_tag in tree.iterdescendants('Item'):
            product = {}
            product['sku'] = xpath_get(item_tag, './/ASIN')
            product['detail_page_url'] = f'http://www.amazon.com/dp/{product["sku"]}'
            product['rank'] = xpath_get(item_tag, './/SalesRank', _type=int)
            product['image_url'] = xpath_get(item_tag, './/LargeImage/URL')
            product['brand'] = xpath_get(item_tag, './/Brand')\
                            or xpath_get(item_tag, './/Manufacturer')\
                            or xpath_get(item_tag, './/Label')\
                            or xpath_get(item_tag, './/Publisher')\
                            or xpath_get(item_tag, './/Studio')
            product['model'] = xpath_get(item_tag, './/Model')\
                            or xpath_get(item_tag, './/MPN')\
                            or xpath_get(item_tag, './/PartNumber')
            product['NumberOfItems'] = xpath_get(item_tag, './/NumberOfItems', _type=int)
            product['PackageQuantity'] = xpath_get(item_tag, './/PackageQuantity', _type=int)
            product['title'] = xpath_get(item_tag, './/Title')
            product['upc'] = xpath_get(item_tag, './/UPC')
            price = xpath_get(item_tag, './/LowestNewPrice/Amount', _type=float)
            product['price'] = price / 100 if price is not None else None
            product['merchant'] = xpath_get(item_tag, './/Merchant')
            product['prime'] = xpath_get(item_tag, './/IsEligibleForPrime')
            product['features'] = '\n'.join([t.text for t in item_tag.iterdescendants('Feature')]) or None
            product['description'] = xpath_get(item_tag, './/EditorialReview/Content')
            product = {k:v for k, v in product.items() if v is not None}

            products.append(product)

        self.products = products
        self.succeeded = True

    def update_product(self, product, except_price=False):
        sku = product.sku
        try:
            update = dict([p for p in self.products if p['sku'] == sku][0])
        except (KeyError, IndexError):
            return False

        if except_price:
            update.pop('price', None)

        product.update(update)
        return True

    @qtc.pyqtSlot(Product, result=bool)
    def updateProduct(self, product):
        return self.update_product(product)


########################################################################################################################


class ProductHistory(qp.MapObject):
    __collection__ = 'product_history'

    productChanged = qtc.pyqtSignal()
    product = qp.MapObjectProperty('product', _type=qp.MapObjectReference, notify=productChanged)

    historyChanged = qtc.pyqtSignal()
    history = qp.ListProperty('history', default=lambda s: list(), default_set=True, notify=historyChanged)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._daterange_min = None
        self._daterange_max = None
        self._rank_points = []
        self._price_points = []
        self._min_datetime = None
        self._max_datetime = None
        self._min_rank = None
        self._max_rank = None
        self._min_price = None
        self._max_price = None
        self._avg_rank = None
        self._avg_price = None
        self.refresh()

    @qtc.pyqtSlot()
    def refresh(self):
        points = (p for p in self.history)

        if self._daterange_min:
            points = (p for p in points if p['timestamp'] >= self._daterange_min)
        if self._daterange_max:
            points = (p for p in points if p['timestamp'] <= self._daterange_max)

        rank_points = []
        price_points = []
        min_datetime = None
        max_datetime = None
        min_rank = 0
        max_rank = 0
        min_price = 0
        max_price = 0
        rank_total, rank_count = 0, 0
        price_total, price_count = 0, 0

        for p in points:
            time_dt = p['timestamp']
            time_ms = time_dt.timestamp() * 1000

            if min_datetime is None or time_dt < min_datetime:
                min_datetime = time_dt
            if max_datetime is None or time_dt > max_datetime:
                max_datetime = time_dt

            rank = p.get('rank', None)
            if rank is not None:
                rank_points.append({'x': time_ms, 'y': rank})
                min_rank = rank if rank < min_rank else min_rank
                max_rank = rank if rank > max_rank else max_rank
                rank_total += rank
                rank_count += 1

            price = p.get('price', None)
            if price is not None:
                price_points.append({'x': time_ms, 'y': price})
                min_price = price if price < min_price else min_price
                max_price = price if price > max_price else max_price
                price_total += price
                price_count += 1

        self._min_datetime = min_datetime
        self._max_datetime = max_datetime

        self._rank_points = rank_points
        if rank_points:
            self._min_rank = min_rank
            self._max_rank = max_rank
            self._avg_rank = int(round(rank_total / rank_count, 0))
        else:
            self._min_rank = None
            self._max_rank = None
            self._avg_rank = None

        self._price_points = price_points
        if price_points:
            self._min_price = min_price
            self._max_price = max_price
            self._avg_price = price_total / price_count
        else:
            self._min_price = None
            self._max_price = None
            self._avg_price = None

        self.minDateTimeChanged.emit()
        self.maxDateTimeChanged.emit()

        self.rankPointsChanged.emit()
        self.minRankChanged.emit()
        self.maxRankChanged.emit()
        self.averageRankChanged.emit()

        self.pricePointsChanged.emit()
        self.minPriceChanged.emit()
        self.maxPriceChanged.emit()
        self.averagePriceChanged.emit()

    def add_to_history(self, product):
        """Adds the current state of product to the product history."""
        now = datetime.now(tz=get_localzone())

        self.history.append(
            {
                'timestamp': now,
                'rank': product.rank,
                'price': product.price,
            }
        )

    minDateTimeChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=minDateTimeChanged)
    def minDateTime(self):
        return qtc.QDateTime(self._min_datetime) if self._min_datetime else None

    maxDateTimeChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=maxDateTimeChanged)
    def maxDateTime(self):
        return qtc.QDateTime(self._max_datetime) if self._max_datetime else None

    @qtc.pyqtSlot(qtc.QVariant, qtc.QVariant)
    def setDateRange(self, min_date, max_date):
        if isinstance(min_date, qtc.QDateTime):
            min_date = min_date.toPyDateTime().replace(tzinfo=get_localzone())
        if isinstance(max_date, qtc.QDateTime):
            max_date = max_date.toPyDateTime().replace(tzinfo=get_localzone())

        self._daterange_min = min_date
        self._daterange_max = max_date

        self.refresh()

    rankPointsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=rankPointsChanged)
    def rankPoints(self):
        return self._rank_points

    minRankChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=minRankChanged)
    def minRank(self):
        return self._min_rank

    maxRankChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=maxRankChanged)
    def maxRank(self):
        return self._max_rank

    averageRankChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=averageRankChanged)
    def averageRank(self):
        return self._avg_rank

    pricePointsChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=pricePointsChanged)
    def pricePoints(self):
        return self._price_points

    minPriceChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=minPriceChanged)
    def minPrice(self):
        return self._min_price

    maxPriceChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=maxPriceChanged)
    def maxPrice(self):
        return self._max_price

    averagePriceChanged = qtc.pyqtSignal()
    @qtc.pyqtProperty(qtc.QVariant, notify=averagePriceChanged)
    def averagePrice(self):
        return self._avg_price