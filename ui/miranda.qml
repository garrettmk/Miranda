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

    Drawer {
        id: drawer
        width: 300
        height: parent.height

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                height: 48
                Layout.fillWidth: true
                color: "transparent"
            }

            M.Divider {Layout.fillWidth: true}

            M.NavItem {
                text: "Products"
                iconSource: "../icons/product.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 0
                state: contentStack.currentIndex === 0 ? "ActiveFocused" : "ActiveUnfocused"
            }

            M.NavItem {
                text: "Vendors"
                iconSource: "../icons/vendor.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 1
                state: contentStack.currentIndex === 1 ? "ActiveFocused" : "ActiveUnfocused"
            }

            M.NavItem {
                text: "Operations"
                iconSource: "../icons/operation.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 2
                state: contentStack.currentIndex === 2 ? "ActiveFocused" : "ActiveUnfocused"
            }

            M.NavItem {
                text: "Database"
                iconSource: "../icons/database.png"
                Layout.fillWidth: true
                state: contentStack.currentIndex === 3 ? "ActiveFocused" : "ActiveUnfocused"

                onClicked: contentStack.currentIndex = 3
            }

            Item {Layout.fillHeight: true}
        }

    }

   StackLayout {
       id: contentStack
       anchors.fill: parent
       onCurrentIndexChanged: drawer.visible = false

       Item {}

       Loader {
           focus: true
           source: "VendorsView.qml"
       }

       Item {}

       Loader {
           id: databaseViewLoader
           focus: true
           source: "DatabaseView.qml"
       }
   }

   RoundButton {
       id: drawerFAB
       radius: 28
       width: 56
       height: 56
       onClicked: drawer.visible = true
       Material.elevation: 12
       anchors {
           bottom: parent.bottom
           left: parent.left
           bottomMargin: 8
           leftMargin: 8
       }

       M.SystemIcon {
           source: "icons/menu.png"
           anchors.centerIn: parent
       }
   }
}
