import sys
import sip
import cupi as qp
from PyQt5 import QtCore, QtGui, QtNetwork
from apis import *
from datetime import datetime


class ControlTestApp(qp.App):
    register_classes = [AmazonMWS, AmazonPA]

    def prepare_root_context(self, context):
        context.setContextProperty('application', self)

    datetimePropertyChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QDateTime, notify=datetimePropertyChanged)
    def datetimeProperty(self):
        return datetime.now()

    # variantPropertyChanged = QtCore.pyqtSignal()
    # @QtCore.pyqtProperty(QtCore.QVariant, notify=variantPropertyChanged)
    # def variantProperty(self):
    #     return datetime.now()
    #
    # qdtPropertyChanged = QtCore.pyqtSignal()
    # @QtCore.pyqtProperty(QtCore.QDateTime, notify=qdtPropertyChanged)
    # def qdtProperty(self):
    #     return datetime.now()

if __name__ == '__main__':
    app = ControlTestApp(sys.argv + ['-style', 'material'])
    app.prepare(load_file='ui/controls/controltest.qml')
    app.exec_()
