import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import "controls" as M

ApplicationWindow {
    id: window
    x: 0
    y: 0
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true

    Material.theme: Material.Dark

    Component.onCompleted: dbConnectionDialog.accepted()

    function newDatabaseView() {
        var view = Qt.createQmlObject("import QtQuick 2.7; DatabaseView {}", contentStack)
    }

    // Dialogs
    DBConnectionDialog {
        id: dbConnectionDialog
        modal: true
        dim: true
        x: window.width / 2 - (width / 2)
        y: window.height / 2 - (height / 2)

        onAccepted: database.connect(dbName, uri)
    }

    M.IconToolButton {
        z: 50
        id: drawerFAB
        iconSource: "../icons/menu.png"
        onClicked: drawer.visible = true
        anchors {
            top: parent.top
            left: parent.left
            margins: 8
        }
    }

    // Navigation drawer
    Drawer {
        id: drawer
        width: 400
        height: parent.height
        dragMargin: 24

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Database connection header
            Item {
                Layout.preferredHeight: 128
                Layout.fillWidth: true

                M.SystemIcon {
                    source: "icons/database.png"
                    state: database.connected ? "ActiveFocused" : "Inactive"
                    anchors{
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                }

                Column {
                    spacing: 0
                    anchors {
                        left: parent.left
                        leftMargin: 72
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: database.connected ? database.databaseName : "Disconnected"
                        font.weight: Font.DemiBold
                        font.pointSize: 16
                        opacity: database.connected ? 0.87 : 0.54
                    }

                    Label {
                        text: database.uri
                        font.weight: Font.Normal
                        opacity: 0.54
                    }
                }

                Button {
                    flat: true
                    M.SystemIcon {
                        source: "icons/dropdown.png"
                        anchors.centerIn: parent
                    }
                    anchors {
                        right: parent.right
                        rightMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: connectionMenu.open()

                    Menu {
                        id: connectionMenu
                        MenuItem {
                            text: "Connect..."
                            onTriggered: dbConnectionDialog.open()
                        }
                        MenuItem {
                            text: "Disconnect"
                            onTriggered: database.disconnect()
                        }
                    }
                }
            }

            M.Divider {Layout.fillWidth: true}

            // Navigation items
            M.NavItem {
                text: "Products"
                iconSource: "../icons/product.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 0
                state: database.connected ? contentStack.currentIndex === 0 ? "ActiveFocused" : "ActiveUnfocused" : "Inactive"
            }

            M.NavItem {
                text: "Vendors"
                iconSource: "../icons/vendor.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 1
                state: database.connected ? contentStack.currentIndex === 1 ? "ActiveFocused" : "ActiveUnfocused" : "Inactive"
            }

            M.NavItem {
                text: "Operations"
                iconSource: "../icons/operation.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 2
                state: database.connected ? contentStack.currentIndex === 2 ? "ActiveFocused" : "ActiveUnfocused" : "Inactive"
            }

            M.NavItem {
                text: "Database"
                iconSource: "../icons/database.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 3
                state: database.connected ? contentStack.currentIndex === 3 ? "ActiveFocused" : "ActiveUnfocused" : "Inactive"
            }

            M.NavItem {
                text: "Opportunities"
                iconSource: "../icons/money.png"
                Layout.fillWidth: true
                onClicked: contentStack.currentIndex = 4
                state: database.connected ? contentStack.currentIndex === 4 ? "ActiveFocused" : "ActiveUnfocused" : "Inactive"
            }

            Item {Layout.fillHeight: true}
        }

    }

    // Content
   StackLayout {
       id: contentStack
       anchors.fill: parent
       currentIndex: 5
       onCurrentIndexChanged: {
           drawer.visible = false
           var current = children[currentIndex]
           if (!current.active) {
               current.active = true
           }
       }

       Loader {
           focus: true
           active: false
           source: "ProductsView.qml"
       }

       Loader {
           focus: true
           active: false
           source: "VendorsView.qml"
       }

       Loader {
           focus: true
           active: false
           source: "OperationsView.qml"
       }

       Loader {
           focus: true
           active: false
           source: "DatabaseView.qml"
       }

       Loader {
           focus: true
           active: false
           source: "OpportunitiesView.qml"
       }

       Item {}
   }
}
