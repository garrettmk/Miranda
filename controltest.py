import sys
import cupi as qp


if __name__ == '__main__':
    app = qp.App(sys.argv + ['-style', 'material'])
    app.prepare(load_file='ui/controls/controltest.qml')
    app.exec_()
