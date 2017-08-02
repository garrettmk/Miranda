import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import Product 1.0


BrowserView {
    id: root
    title: "Products"
    Material.primary: Material.color(Material.Green, Material.Shade700)
    Material.accent: Material.color(Material.Orange, Material.Shade500)

    property ObjectModel selectionModel: ObjectModel {}

    // Dialogs
    EditProductDialog {
        id: editProductDialog

        onAccepted: {
            if (!root.model.contains(product)) {
                root.model.insert(0, product)
            }

            database.saveObject(product)
            product = null
        }

        onRejected: {
            if (!root.model.contains(product)) {
                product.destroy()
            }

            product = null
        }
    }

    ProductValidatorDialog {
        id: validateProductDialog
    }

    CompareProductsDialog {
        id: compareProductsDialog
        model: selectionModel
    }

    Dialog {
        id: confirmDeleteDialog
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        x: ApplicationWindow.window.width / 2 - width / 2
        y: ApplicationWindow.window.height / 2 - height / 2

        M.Label {
            text: "Delete all " + selectionModel.length + " products?"
        }

        onAccepted: {
            var idx
            for (var i=0; i<selectionModel.length; i++) {
                idx = root.model.matchObject(selectionModel.getObject(i))
                root.model.removeRow(idx)
            }

            database.deleteModel(selectionModel)
            selectionModel.clear()
        }
    }

    // View body
    queryBuilder: ProductQueryBuilder {}

    cardDelegate: ProductCard {
        id: productCard
        product: index >= 0 ? root.model.getObject(index) : null
        selected: selectionModel.contains(product)
        Material.theme: root.Material.theme
        Material.primary: Material.color(Material.Green, Material.Shade600)
        Material.accent: root.Material.accent
        vendorName: product !== null ? database.getNameOfVendor(product) || "(vendor n/a)" : "(vendor n/a)"
        interactive: !ListView.view.moving

        actionMenu: Menu {
            MenuItem {
                text: "Edit"
                onTriggered: {
                    editProductDialog.product = product
                    editProductDialog.open()
                }
            }

            MenuItem {
                text: "Validate"
                onTriggered: {
                    validateProductDialog.product = product
                    validateProductDialog.open()
                }
            }

            MenuItem {
                text: "Copy SKU"
                onTriggered: application.setClipboardText(sku)
            }

            MenuItem {
                text: "Google product..."
                onTriggered: Qt.openUrlExternally("http://googl.com/#q=" + brand.concat("+" + model).replace(" ", "+"))
            }

        }

        onSelectButtonClicked: {
            if (!selected) {
                selectionModel.removeRow(selectionModel.matchObject(product))
            } else {
                selectionModel.append(product)
            }
            selected = Qt.binding(function() {return selectionModel.contains(product)})
        }

        property var conn: Connections {
            target: selectionModel
            onModelReset: productCard.selected = Qt.binding(function() {return selectionModel.contains(product)})
            onRowsRemoved: productCard.selected = Qt.binding(function() {return selectionModel.contains(product)})
        }
    }

    toolArea: ColumnLayout {
        spacing: 48

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true

                M.SystemIcon {
                    source: "icons/vendor.png"
                    Layout.leftMargin: 24
                }

                ComboBox {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24
                }

                M.IconToolButton {
                    iconSource: "../icons/dots_vertical.png"
                    Layout.leftMargin: 8

                    Menu {
                        id: matchedListingsMenu

                        MenuItem {
                            text: "Add..."
                        }

                        MenuItem {
                            text: "Remove"
                        }
                    }
                }
            }

            M.Divider {
                Layout.topMargin: 8
                Layout.fillWidth: true
                Layout.bottomMargin: 8
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    spacing: 0

                    M.TextField {
                        labelText: "List Price"
                        text: "999.99"
                        prefix: M.Label { text: "$"; opacity: 0.70 }
                    }

                    M.TextField {
                        labelText: "Mkt. Fees"
                        text: "34.78"
                        prefix: M.Label {text: "$-"; opacity: 0.70 }
                    }

                    M.TextField {
                        labelText: "Est. COGS"
                        text: "32.67"
                        prefix: M.Label {text: "$-"; opacity: 0.70 }
                    }
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.leftMargin: 32
                    columns: 3
                    columnSpacing: 32
                    rowSpacing: 8

                    M.Label {
                        type: "Caption"
                        text: "Profit Each"
                    }

                    M.Label {
                        type: "Caption"
                        text: "Margin"
                    }

                    M.Label {
                        type: "Caption"
                        text: "ROI"
                    }

                    M.Label {
                        type: "Display 2"
                        text: "$22.34"
                    }

                    M.Label {
                        type: "Display 2"
                        text: "34%"
                    }

                    M.Label {
                        type: "Display 2"
                        text: "125%"
                    }
                }
            }

        }

        M.ObjectTable {
            id: selectionTable
            title: model.length + " selected"
            model: selectionModel
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: [
                {name: "Title", property: "title", width: 200},
                {name: "Brand", property: "brand", width: 100, alignment: Text.AlignLeft},
                {name: "Model", property: "model", width: 100, alignment: Text.AlignLeft}
            ]

            onRowClicked: {
                var idx = root.model.matchObject(selectionModel.getObject(index))
                cardListView.positionViewAtIndex(idx, ListView.Beginning)
            }

            headerTools: RowLayout {
                spacing: 0

                M.IconToolButton {
                    enabled: selectionModel.length > 0
                    iconSource: "../icons/new_window.png"
                    onClicked: compareProductsDialog.open()
                }

                M.IconToolButton {
                    iconSource: "../icons/dots_vertical.png"
                    enabled: selectionModel.length > 0
                    onClicked: selectionTableMenu.open()

                    Menu {
                        id: selectionTableMenu

                        MenuItem {
                            text: "Add tags..."
                        }

                        MenuItem {
                            text: "Remove tags..."
                        }

                        MenuSeparator {}

                        MenuItem {
                            text: "Delete..."
                            onTriggered: confirmDeleteDialog.open()
                        }
                    }
                }
            }
        }


    }

    onNewItemClicked: {
        var prod = Qt.createQmlObject("import QtQuick 2.7; import Product 1.0; Product {}", editProductDialog)
        editProductDialog.product = prod
        editProductDialog.open()
    }


}
