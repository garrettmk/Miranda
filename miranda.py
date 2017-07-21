import sys, psutil, subprocess, sip
import cupi as qp
from models import *
from queries import *
from PyQt5 import QtGui


########################################################################################################################


class ClipboardAdapter(qtc.QObject):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._clipboard = QtGui.QClipboard()

    @qtc.pyqtSlot(str)
    def setText(self, text):
        self._clipboard.setText(text, QtGui.QClipboard.Clipboard)
        self._clipboard.setText(text, QtGui.QClipboard.Selection)


########################################################################################################################


class MirandaDatabase(qp.MongoDatabase):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def new_vendor_query(self):
        """Helper method for returning a basic Vendor query object."""
        return ObjectQuery(objectType='Vendor',
                           query=VendorQueryDocument(),
                           sort=VendorSortDocument(title=qtc.Qt.AscendingOrder))

    @qtc.pyqtSlot(result=ObjectQuery)
    def newVendorQuery(self):
        """QML frontend for the new_vendor_query() method. Transfers ownership of the query object to QML before
        returning."""
        q = self.new_vendor_query()
        sip.transferto(q, q)
        return q

    def new_product_query(self):
        """Helper method for creating a basic Product query object."""
        return ObjectQuery(objectType='Product',
                           query=ProductQueryDocument(),
                           sort=ProductSortDocument(rank=qtc.Qt.AscendingOrder))

    @qtc.pyqtSlot(result=ObjectQuery)
    def newProductQuery(self):
        """QML frontend for the new_product_query() method."""
        q = self.new_product_query()
        sip.transferto(q, q)
        return q

    @qtc.pyqtSlot(Product, result=str)
    def getNameOfVendor(self, product):
        """Helper method to return the name of a product's vendor."""
        collection = self._get_collection(Vendor.__collection__)
        doc = collection.find_one({'_id': product.vendor.referentId}, projection={'title': 1})
        return doc['title'] if doc is not None else ''


########################################################################################################################


class MirandaApp(qp.App):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.db = MirandaDatabase()

    def prepare_root_context(self, context):
        context.setContextProperty('application', self)
        context.setContextProperty('database', self.db)

    @qtc.pyqtSlot(str)
    def setClipboardText(self, text):
        self.clipboard().setText(text)

    @qtc.pyqtSlot(str, Vendor, list)
    def importProducts(self, file, vendor, tags):
        """Import """


########################################################################################################################


if __name__ == '__main__':
    # Start mongod if it isn't already running
    if 'mongod' not in (p.name() for p in psutil.process_iter()):
        subprocess.Popen(['mongod'])

    app = MirandaApp(sys.argv + ['-style', 'material'])
    app.prepare(load_file='ui/miranda.qml', cupi_path='../Cupi')
    app.exec_()