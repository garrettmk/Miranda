import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import cupi.ui 1.0 as QP
import "controls" as M

ApplicationWindow {
    id: window
    width: 1000
    height: 800
    visible: true

    Material.theme: Material.Dark

    function newDatabaseView() {
        var view = Qt.createQmlObject("import QtQuick 2.7; DatabaseView {}", contentStack)
    }

    ImportDialog {
        id: importDialog
        modal: true
        dim: false
        x: window.width / 2 - (width / 2)
        y: window.height / 2 - (height / 2)
    }

    M.NavigationDrawer {
        id: drawer
        width: 400
        dragMargin: 30
    }

    header: TabBar {
        id: tabbar
        Layout.fillWidth: true

        Repeater {
            model: contentStack.children

            TabButton {
                text: modelData.title
                width: implicitWidth
            }
        }
    }

    footer: ToolBar {
        position: ToolBar.Footer
        height: 16
        RowLayout {
            anchors.fill: parent
            Label {
                text: "All systems go."
                horizontalAlignment: Text.AlignLeft
            }
        }
    }

   StackLayout {
       id: contentStack
       anchors.fill: parent
       currentIndex: tabbar.currentIndex
   }

}
