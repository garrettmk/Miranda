import sys
import cupi as qp


########################################################################################################################


class MirandaApp(qp.App):
    pass


########################################################################################################################


if __name__ == '__main__':
    app = MirandaApp(sys.argv + ['-style', 'material'])
    app.prepare(load_file='ui/miranda.qml', cupi_path='../Cupi')
    app.exec_()