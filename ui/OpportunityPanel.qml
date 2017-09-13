import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ProfitRelationship 1.0
import GetMyFeesEstimate 1.0
import Product 1.0


Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property ProfitRelationship currentOpp: null
    property Product _marketListing: null
    property Product _supplierListing: null

    onCurrentOppChanged: {
        if (currentOpp !== null) {
            _marketListing = database.getReferencedObject(currentOpp.marketListing)
            _supplierListing = database.getReferencedObject(currentOpp.supplierListing)
        } else {
            _marketListing = null
            _supplierListing = null
        }
    }

    GetMyFeesEstimate {
        id: getMyFeesEstimate
        onSucceededChanged: {
            if (succeeded) {
                var total = feeTotals[0]["market_fees"]
                _marketListing.marketFees = total
                editMarketFeesLabel.editTextField.text = total.toFixed(2)
                database.saveObject(_marketListing)
                database.saveObject(currentOpp)
            } else {
                messageDialog.text = errorMessage
                messageDialog.open()
            }
        }
    }

    function save() {
        if (_marketListing !== null)
            database.saveObject(_marketListing)

        if (_supplierListing !== null)
            database.saveObject(_supplierListing)

        if (currentOpp !== null)
            database.saveObject(currentOpp)
    }

    M.CenteredModalDialog {
        id: messageDialog
        standardButtons: Dialog.Ok

        property alias text: textLabel.text

        M.Label {
            id: textLabel
            type: "Body 1"
        }
    }

    ProductValidatorDialog {
        id: validateProductDialog
        onAccepted: { database.saveObject(currentOpp) }
    }

    EditProductDialog {
        id: editProductDialog
        onAccepted: {
            database.saveObject(product)
            database.saveObject(currentOpp)
            product = null
        }
        onRejected: product = null
    }

    ObjectDocumentDialog {
        id: documentViewerDialog
        onAccepted: documentViewerDialog.currentObject = null
    }

    // Body
    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // Market column
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: layout.width / 2 - 1
                spacing: 16

                M.ProductImage {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width //(width * 2 + 1) / (16/9)
                    source: _marketListing !== null && _marketListing.imageUrl !== undefined ? _marketListing.imageUrl : ""

                    Row {
                        spacing: 8
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 8
                        }

                        M.TinyIconButton {
                            Material.theme: Material.Light
                            iconSource: "icons/edit_dark.png"
                            onClicked: {
                                editProductDialog.product = _marketListing
                                editProductDialog.open()
                            }
                        }

                        M.TinyIconButton {
                            Material.theme: Material.Light
                            iconSource: "icons/double_check_dark.png"
                            onClicked: {
                                validateProductDialog.product = _marketListing
                                validateProductDialog.open()
                            }
                        }

                        M.TinyIconButton {
                            Material.theme: Material.Light
                            iconSource: "icons/code_dark.png"
                            onClicked: {
                                documentViewerDialog.currentObject = _marketListing
                                documentViewerDialog.open()
                            }
                        }
                    }
                }

                M.LinkLabel {
                    id: marketTitleLabel
                    type: "Body 2"
                    text: _marketListing !== null ? _marketListing.title : ""
                    link: _marketListing !== null ? _marketListing.detailPageUrl !== undefined ? _marketListing.detailPageUrl : "" : ""
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.preferredHeight: Math.max(supplierTitleLabel.implicitHeight, marketTitleLabel.implicitHeight)
                }

                Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 4

                    M.Label {
                        type: "Caption"
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: _marketListing !== null ? database.getVendorName(_marketListing.vendor) + " " + _marketListing.sku : ""
                        wrapMode: Text.Wrap
                    }

                    M.Label {
                        type: "Caption"
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: _marketListing !== null ? (_marketListing.rank !== undefined ? _marketListing.rank.toLocaleString() : "n/a") + " in " + (_marketListing.category !== undefined ? _marketListing.category : "n/a") : ""
                        wrapMode: Text.Wrap
                    }
                }


                M.Label {
                    type: "Body 1"
                    text: _marketListing !== null ? _marketListing.brand + " " + _marketListing.model : ""
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    M.Label {
                        type: "Body 2"
                        text: _marketListing !== null ? "$" + _marketListing.price.toFixed(2) : ""
                        Layout.alignment: Qt.AlignHCenter
                    }

                    M.Label {
                        type: "Caption"
                        text: _marketListing !== null ? "per " + _marketListing.quantity : ""
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            M.Divider {
                id: columnDivider
                orientation: Qt.Vertical
                Layout.fillHeight: true
            }

            // Supplier column
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: layout.width / 2 - 1
                spacing: 16

                M.ProductImage {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width //(width * 2 + 1) / (16/9)
                    source: _supplierListing !== null ? _supplierListing.imageUrl : ""

                    Row {
                        spacing: 8
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 8
                        }

                        M.TinyIconButton {
                            Material.theme: Material.Light
                            iconSource: "icons/edit_dark.png"
                            onClicked: {
                                editProductDialog.product = _supplierListing
                                editProductDialog.open()
                            }
                        }

                        M.TinyIconButton {
                            Material.theme: Material.Light
                            iconSource: "icons/double_check_dark.png"
                            onClicked: {
                                validateProductDialog.product = _supplierListing
                                validateProductDialog.open()
                            }
                        }

                        M.TinyIconButton {
                            Material.theme: Material.Light
                            iconSource: "icons/code_dark.png"
                            onClicked: {
                                documentViewerDialog.currentObject = _supplierListing
                                documentViewerDialog.open()
                            }
                        }
                    }
                }

                M.LinkLabel {
                    id: supplierTitleLabel
                    type: "Body 2"
                    text: _supplierListing !== null ? _supplierListing.title : ""
                    link: _supplierListing !== null ? _supplierListing.detailPageUrl : ""
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.preferredHeight: Math.max(supplierTitleLabel.implicitHeight, marketTitleLabel.implicitHeight)
                    horizontalAlignment: Text.AlignHCenter
                }

                Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 4

                    M.Label {
                        type: "Caption"
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: _supplierListing !== null ? database.getVendorName(_supplierListing.vendor) + " " + _supplierListing.sku : ""
                        wrapMode: Text.Wrap
                    }

                    M.Label {
                        type: "Caption"
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: _supplierListing !== null ? (_supplierListing.rank !== undefined ? _supplierListing.rank.toLocaleString() : "n/a") + " in " + (_supplierListing.category !== undefined ? _supplierListing.category : "n/a") : ""
                        wrapMode: Text.Wrap
                    }
                }

                M.Label {
                    type: "Body 1"
                    text: _supplierListing !== null ? _supplierListing.brand + " " + _supplierListing.model : ""
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    M.Label {
                        type: "Body 2"
                        text: _supplierListing !== null ? "$" + _supplierListing.price.toFixed(2) : ""
                        Layout.alignment: Qt.AlignHCenter
                    }

                    M.Label {
                        type: "Caption"
                        text: _supplierListing !== null ? "per " + _supplierListing.quantity : ""
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        M.Divider {
            Layout.fillWidth: true
            Layout.topMargin: 32
            Layout.bottomMargin: 32
        }

        // Profit Calculator
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Item {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                implicitWidth: children[0].implicitWidth
                implicitHeight: children[0].implicitHeight

                GridLayout {
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }

                    columns: 2
                    columnSpacing: 24
                    rowSpacing: 8

                    M.Label {
                        type: "Caption"
                        text: "Price:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.EditMoneyLabel {
                        id: editMarketPriceLabel
                        text: _marketListing !== null ? _marketListing.price : ""
                        editTextField.labelText: "Sale Price"
                        Layout.preferredWidth: 100
                        onEditAccepted: {
                            _marketListing.price = parseFloat(editTextField.text)
                            database.saveObject(_marketListing)
                            database.saveObject(currentOpp)
                        }
                    }

                    M.Label {
                        type: "Caption"
                        text: "Mkt. Fees:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.EditMoneyLabel {
                        id: editMarketFeesLabel
                        text: _marketListing !== null ? _marketListing.marketFees !== undefined ? _marketListing.marketFees.toFixed(2) : "n/a" : ""
                        editTextField.labelText: "Market Fees"
                        Layout.preferredWidth: editMarketPriceLabel.width
                        editTextField.suffix: M.TinyIconButton {
                            iconSource: "icons/wand.png"
                            onClicked: {
                                getMyFeesEstimate.asins = [currentOpp.marketListing.ref.sku]
                                getMyFeesEstimate.prices = [currentOpp.marketListing.ref.price]
                                application.amazonMWS.enqueue(getMyFeesEstimate)
                            }
                        }
                        onEditAccepted: {
                            _marketListing.marketFees = parseFloat(editTextField.text)
                            database.saveObject(_marketListing)
                            database.saveObject(currentOpp)
                        }
                    }

                    Item { width: 1 }

                    M.Divider {
                        Layout.preferredWidth: editMarketPriceLabel.width
                    }

                    M.Label {
                        type: "Caption"
                        text: "Revenue:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.AffixedLabel {
                        type: "Body 1"
                        text: currentOpp !== null && currentOpp.revenue !== undefined ? currentOpp.revenue.toFixed(2) : "n/a"
                        prefix: M.Label { type: "Body 1"; text: "$"; opacity: 0.5 }
                        Layout.preferredWidth: editMarketPriceLabel.width
                        horizontalAlignment: Text.AlignRight
                        rightPadding: 16 + 18
                    }

                    M.Label {
                        type: "Caption"
                        text: "Pkg. Quantity:"
                    }

                    M.LabelWithEdit {
                        id: editMarketQuantityLabel
                        type: "Body 1"
                        enabled: currentOpp !== null
                        text: _marketListing !== null ? _marketListing.quantity !== undefined ? _marketListing.quantity : "n/a" : ""
                        Layout.preferredWidth: editMarketPriceLabel.width
                        horizontalAlignment: Text.AlignRight

                        editTools: M.TextField {
                            id: editMarketQuantityField
                            labelText: "Quantity"
                            onAccepted: editMarketQuantityLabel.popup.accept()
                        }

                        onEditClicked: {
                            editMarketQuantityField.text = editMarketQuantityLabel.text
                            editMarketQuantityField.selectAll()
                            editMarketQuantityField.focus = true
                        }

                        onEditAccepted: {
                            _marketListing.quantity = parseInt(editMarketQuantityField.text)
                            database.saveObject(_marketListing)
                            database.saveObject(currentOpp)
                        }
                    }
                }
            }

            Item {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                implicitWidth: children[0].implicitWidth
                implicitHeight: children[0].implicitHeight

                GridLayout {
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }

                    columns: 2
                    columnSpacing: 24
                    rowSpacing: 8

                    M.Label {
                        type: "Caption"
                        text: "Unit Price:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.LabelWithEdit {
                        id: editSupplierUnitPriceLabel
                        text: _supplierListing !== null ? _supplierListing.unitPrice.toFixed(2) : ""
                        Layout.preferredWidth: 100
                        prefix: M.Label { type: "Body 1"; text: "$"; opacity: 0.5 }
                        horizontalAlignment: Text.AlignRight

                        editTools: Column {
                            spacing: 0

                            M.TextField {
                                id: editSupplierPriceField
                                labelText: "Price"
                                onAccepted: editSupplierUnitPriceLabel.popup.accept()
                            }

                            M.TextField {
                                id: editSupplierQuantityField
                                labelText: "Quantity"
                                onAccepted: editSupplierUnitPriceLabel.popup.accept()
                            }
                        }

                        onEditClicked: {
                            editSupplierPriceField.text = _supplierListing !== null ? _supplierListing.price !== null ? _supplierListing.price.toFixed(2) : "n/a" : ""
                            editSupplierQuantityField.text = _supplierListing !== null ? _supplierListing.quantity !== null ? _supplierListing.quantity : "n/a" : ""

                            editSupplierPriceField.selectAll()
                            editSupplierPriceField.focus = true
                        }

                        onEditAccepted: {
                            _supplierListing.price = parseFloat(editSupplierPriceField.text)
                            _supplierListing.quantity = parseInt(editSupplierQuantityField.text)
                            database.saveObject(_supplierListing)
                            database.saveObject(currentOpp)
                        }

                    }

                    M.Label {
                        type: "Caption"
                        text: "Quantity"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.AffixedLabel {
                        text: _supplierListing !== null ? _supplierListing.quantity !== undefined ? _supplierListing.quantity : "n/a" : ""
                        Layout.preferredWidth: editMarketPriceLabel.width
                        prefix: M.Label { type: "Body 1"; text: "×"; opacity: 0.5}
                        rightPadding: 18 + 16
                        horizontalAlignment: Text.AlignRight
                    }

                    Item { width: 1 }

                    M.Divider {
                        Layout.preferredWidth: editMarketPriceLabel.width
                    }

                    M.Label {
                        type: "Caption"
                        text: "Subtotal:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.AffixedLabel {
                        type: "Body 1"
                        text: currentOpp !== null && currentOpp.subtotal !== undefined ? currentOpp.subtotal.toFixed(2) : "n/a"
                        prefix: M.Label { type: "Body 1"; text: "$"; opacity: 0.5}
                        rightPadding: 18 + 16
                        Layout.preferredWidth: editMarketPriceLabel.width
                        horizontalAlignment: Text.AlignRight
                    }

                    M.Label {
                        type: "Caption"
                        text: "Est. Shipping:"
                    }

                    M.AffixedLabel {
                        Layout.preferredWidth: editMarketPriceLabel.width
                        horizontalAlignment: Text.AlignRight
                        prefix: M.Label { type: "Body 1"; text: "$"; opacity: 0.5 }
                        rightPadding: 18 + 16
                        text: currentOpp !== null && currentOpp.estShipping !== undefined ? currentOpp.estShipping.toFixed(2) : "n/a"
                    }

                    Item { width: 1 }

                    M.Divider {
                        Layout.preferredWidth: editMarketPriceLabel.width
                    }

                    M.Label {
                        type: "Caption"
                        text: "Est. COGS:"
                        horizontalAlignment: Text.AlignRight
                    }

                    M.AffixedLabel {
                        Layout.preferredWidth: editMarketPriceLabel.width
                        horizontalAlignment: Text.AlignRight
                        prefix: M.Label { type: "Body 1"; text: "$"; opacity: 0.5 }
                        rightPadding: 18 + 16
                        text: currentOpp !== null && currentOpp.estCOGS !== undefined ? currentOpp.estCOGS.toFixed(2) : "n/a"
                    }
                }
            }
        }

        M.Divider {
            Layout.fillWidth: true
            Layout.margins: 24
        }

        GridLayout {
            columns: 3
            columnSpacing: 48
            rowSpacing: 0
            Layout.alignment: Qt.AlignHCenter

            M.Label {
                type: "Caption"
                text: "Profit:"
            }

            M.Label {
                type: "Caption"
                text: "Margin:"
            }

            M.Label {
                type: "Caption"
                text: "ROI:"
            }

            M.Label {
                type: "Display 2"
                text: currentOpp !== null && currentOpp.profit !== undefined ? "$" + currentOpp.profit.toFixed(2) : "n/a"
            }

            M.Label {
                type: "Display 2"
                text: currentOpp !== null && currentOpp.margin !== undefined ? (currentOpp.margin * 100).toFixed() + "%" : "n/a"
            }

            M.Label {
                type: "Display 2"
                text: currentOpp !== null && currentOpp.roi !== undefined ? (currentOpp.roi * 100).toFixed() + "%" : "n/a"
            }
        }
    }
}
