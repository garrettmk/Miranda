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

    CompareProductsDialog {
        id: compareProductsDialog
        model: selectionModel
    }

    // View body
    queryBuilder: ProductQueryBuilder {}

    cardDelegate: ProductCard {
        id: productCard
        property Product product: index >= 0 ? root.model.getObject(index) : null
        selected: selectionModel.contains(product)
        Material.theme: root.Material.theme
        Material.primary: Material.color(Material.Green, Material.Shade600)
        Material.accent: root.Material.accent

        vendorName: database.getNameOfVendor(product)

        actionMenu: Menu {
            MenuItem {
                text: "Edit"
                onTriggered: {
                    editProductDialog.product = product
                    editProductDialog.open()
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

    comparisonTool: M.ObjectTable {
        id: selectionTable
        title: model.length + " selected"
        model: selectionModel

        columns: [
            {name: "Title", property: "title", width: 200},
            {name: "Brand", property: "brand", width: 100, alignment: Text.AlignLeft},
            {name: "Model", property: "model", width: 100, alignment: Text.AlignLeft}
        ]

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
                    }
                }
            }
        }

        onRowClicked: {
            var idx = root.model.matchObject(selectionModel.getObject(index))
            cardListView.positionViewAtIndex(idx, ListView.Beginning)
        }
    }

    onNewItemClicked: {
        var prod = Qt.createQmlObject("import QtQuick 2.7; import Product 1.0; Product {}", editProductDialog)
        editProductDialog.product = prod
        editProductDialog.open()
    }


}
