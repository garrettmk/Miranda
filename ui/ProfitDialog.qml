import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0


Dialog {
    id: root
    title: product !== null ? "Profit Relationships - " + product.title : "Profit Calculations"
    clip: true
    modal: true
    standardButtons: Dialog.Ok

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    contentWidth: layout.implicitWidth
    height: width / (16/9)
    padding: 0

    Material.theme: parent.Material.theme
    Material.primary: parent.Material.primary
    Material.foreground: parent.Material.foreground
    Material.accent: parent.Material.accent
    Material.background: Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)

    property Product product
    property bool productIsMarket: product !== null ? database.isMarket(product.vendor) : false

    onProductChanged: refresh()
    onAccepted: product = null

    function refresh() {
        if (product !== null && product !== undefined) {
            var q = database.newRelationshipQuery()

            if (database.isMarket(product.vendor))
                q.query.marketListing = product
            else
                q.query.supplierListing = product

            table.model = database.getModel(q)
        } else {
            table.model = []
        }
    }

    FindProductsDialog {
        id: findProductsDialog
        onAccepted: {
            var isMarket = database.isMarket(product.vendor)
            var rel
            for (var i=0; i<selectionModel.length; i++) {
                rel = Qt.createQmlObject("import ProfitRelationship 1.0; ProfitRelationship {}", findProductsDialog)
                if (isMarket) {
                    rel.supplierListing.ref = selectionModel.getObject(i)
                    rel.marketListing.ref = product
                } else {
                    rel.marketListing.ref = selectionModel.getObject(i)
                    rel.supplierListing.ref = product
                }
                database.saveObject(rel)
                rel.destroy()
            }
            selectionModel.clear()
            refresh()
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        RowLayout {
            spacing: 8
            Layout.leftMargin: 32

            Button {
                flat: true
                text: "Add..."
                onClicked: findProductsDialog.open()
            }

            Button {
                flat: true
                text: "Delete"
            }
        }

        M.ObjectTable {
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: [
                {name: "Listing", width: 400},
                {name: "Vendor", width: 150},
                {name: "SKU", width: 100},
                {name: "Quantity", width: 75, alignment: Qt.AlignRight},
                {name: "Price", width: 75, alignment: Qt.AlignRight},
                {name: "Profit", width: 75, alignment: Qt.AlignRight},
                {name: "Margin", width: 75, alignment: Qt.AlignRight},
                {name: "ROI", width: 75, alignment: Qt.AlignRight}
            ]

            delegate: M.TableRow {
                property var header: index >= 0 ? database.getProductHeader(root.productIsMarket ? supplierListing : marketListing) : null
                M.LinkLabel {
                    type: "Body 1"
                    text: header !== null ? header["title"] : "n/a"
                    link: header !== null && header["detail_page_url"] !== undefined ? header["detail_page_url"] : ""
                    elide: Text.ElideRight
                }

                M.Label {
                    type: "Body 1"
                    text: header !== null ? header["vendor"] : "n/a"
                    elide: Text.ElideRight
                }

                M.Label {
                    type: "Body 1"
                    text: header !== null ? header["sku"] : "n/a"
                    elide: Text.ElideRight
                }

                M.Label {
                    type: "Body 1"
                    text: root.productIsMarket ? supplierListing.quantity !== undefined ? supplierListing.quantity : "n/a" : marketListing.quantity !== undefined ? marketListing.quantity : "n/a"
                    horizontalAlignment: Text.AlignRight
                }

                M.Label {
                    type: "Body 1"
                    text: "$" + (root.productIsMarket ? supplierListing.price !== undefined ? supplierListing.price : "n/a" : marketListing.price !== undefined ? marketListing.price : "n/a")
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }

                M.Label {
                    type: "Body 1"
                    text: profit !== undefined ? "$" + profit.toFixed(2) : "n/a"
                    horizontalAlignment: Text.AlignRight
                }

                M.Label {
                    type: "Body 1"
                    text: margin !== undefined ? (margin * 100).toFixed() + "%" : "n/a"
                    horizontalAlignment: Text.AlignRight
                }

                M.Label {
                    type: "Body 1"
                    text: roi !== undefined ? (roi * 100).toFixed() + "%" : "n/a"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
