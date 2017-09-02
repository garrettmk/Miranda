import csv, os, sip, json, itertools
import cupi as qp
from PyQt5 import QtCore, QtQml
from models import Product
from bson import ObjectId


########################################################################################################################


class FileImportHelper(QtCore.QObject):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._running = False
        self._can_import = False
        self._complete = False

        self._vendor = None
        self._db = None
        self._tags = []
        self._validators = []
        self._file_path = ''

        self._file = None
        self._reader = None
        self._objs_in_file = 0
        self._current_index = -1
        self._current_product = None
        self._busy = False
        self._message = ''

    runningChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=runningChanged)
    def running(self):
        """True if the import is currently scanning or importing."""
        return bool(self._running)

    @running.setter
    def running(self, value):
        """Setting this value to True will either start/resume checking the current file, or start/resume importing
        if it has already been checked. Setting to False pauses the currently running operation."""
        self._running = value if self._file is not None else False
        self.runningChanged.emit()

        if self._running:
            self.import_file() if self.canImport else self._check_file()

    @QtCore.pyqtSlot(str, result=bool)
    def open(self, path):
        """Returns True if the file opens successfully."""
        self.close()

        try:
            self._file = open(path)
        except OSError:
            return False

        self.set_file_path(path)
        self.set_complete(False)
        return True

    @QtCore.pyqtSlot()
    def close(self):
        """Closes the file and resets the object's state."""
        if self._file is not None:
            self._file.close()
            self._file = None

        self.running = False
        self._reader = None
        self.set_current_product(None)
        self.set_current_index(-1)
        self.set_objects_in_file(0)
        self.set_can_import(False)
        self.set_complete(False)

    vendorChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=vendorChanged)
    def vendor(self):
        """The vendor id for the imported products."""
        return self._vendor

    @vendor.setter
    def vendor(self, value):
        self._vendor = value
        self.vendorChanged.emit()

    tagsChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=tagsChanged)
    def tags(self):
        """Tags that will be added to the imported products."""
        return self._tags

    @tags.setter
    def tags(self, values):
        self._tags = values.toVariant() if isinstance(values, (QtCore.QVariant, QtQml.QJSValue)) else values
        self.tagsChanged.emit()

    validatorsChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=validatorsChanged)
    def validators(self):
        """The preprocessor to use on any products that are invalidated by this update."""
        return self._validators

    @validators.setter
    def validators(self, obj):
        self._validators = obj.toVariant() if isinstance(obj, (QtCore.QVariant, QtQml.QJSValue)) else obj
        self.validatorsChanged.emit()

    databaseChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=databaseChanged)
    def database(self):
        return self._db

    @database.setter
    def database(self, value):
        self._db = value
        self.databaseChanged.emit()

    # Read-only properties, used to notify the GUI of progress/status

    completeChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=completeChanged)
    def complete(self):
        return self._complete

    def set_complete(self, value):
        self._complete = bool(value)
        self.completeChanged.emit()

    messageChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(str, notify=messageChanged)
    def message(self):
        return self._message

    def set_message(self, value):
        self._message = str(value)
        self.messageChanged.emit()

    currentIndexChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(int, notify=currentIndexChanged)
    def currentIndex(self):
        return self._current_index

    def set_current_index(self, value):
        self._current_index = int(value)
        self.currentIndexChanged.emit()

    currentProductChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=currentProductChanged)
    def currentProduct(self):
        return self._current_product

    def set_current_product(self, value):
        self._current_product = value
        self.currentProductChanged.emit()

    canImportChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=canImportChanged)
    def canImport(self):
        return bool(self._can_import and self._vendor and self._db)

    def set_can_import(self, value):
        self._can_import = value
        self.canImportChanged.emit()

    objectsInFileChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(int, notify=objectsInFileChanged)
    def objectsInFile(self):
        return int(self._objs_in_file)

    def set_objects_in_file(self, value):
        self._objs_in_file = value
        self.objectsInFileChanged.emit()

    filePathChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(str, notify=filePathChanged)
    def filePath(self):
        """The path of the file to import."""
        return str(self._file_path)

    def set_file_path(self, value):
        self._file_path = value
        self.filePathChanged.emit()

    def _check_file(self):
        """Does an initial read of the file."""
        self.set_message('Checking file...')
        QtCore.QCoreApplication.processEvents()

        self._reader = csv.DictReader(self._file)
        self._objs_in_file = 0
        for data in self._reader:
            self.set_objects_in_file(self._objs_in_file + 1)
            self.set_message("%s objects scanned..." % self._objs_in_file)

            QtCore.QCoreApplication.processEvents()
            if not self.running:
                return

        self._file.seek(0)
        self._reader = None
        self.set_message('%s objects ready to import.' % self._objs_in_file)
        self.set_can_import(True)
        self.running = False

    def import_file(self):
        self.set_message('Importing...')
        QtCore.QCoreApplication.processEvents()

        if self._reader is None:
            self._reader = csv.DictReader(self._file)

        for row, data in enumerate(self._reader, self._current_index + 1):
            if '_id' in data:
                del data['_id']
            if '_type' in data:
                del data['_type']
            if '' in data:
                del data['']

            self.set_current_index(row)
            self.set_message('Importing object %s of %s...' % (self._current_index + 1, self._objs_in_file))

            query = self._db.new_product_query()
            query.query.vendor = self.vendor
            query.query.sku = data['sku'].strip()
            product = self._db.get_object(query) or Product(vendor=qp.MapObjectReference(ref=self.vendor),
                                                            sku=data['sku'])

            validation = product.get('_validation', {})
            if validation:
                for key, value in data.items():
                    if str(value) in validation:
                        data[key] = validation[str(value)]

            product.update(data)
            product.tags = list(set(itertools.chain(product.tags, self._tags)))

            self.set_current_product(product)

            for validator in self._validators:
                validator.product = product

            QtCore.QCoreApplication.processEvents()

            for validator in self._validators:
                if not validator.isValid:
                    self.running = False
                    self.set_message('Validator needs input.')
                    QtCore.QCoreApplication.processEvents()
                    return

            self._db.saveObject(product)

            if not self.running:
                self.set_message('Importing stopped.')
                return

        self._file.seek(0)
        self._reader = None
        self.set_complete(True)
        self.set_message('%s objects imported.' % (self._current_index + 1))








