import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Vendor 1.0


M.CenteredModalDialog {
    id: root
    title: "Edit Vendor"
    standardButtons: Dialog.Save | Dialog.Cancel

    property Vendor vendor

    onVendorChanged: {
        if (vendor !== null && vendor !== undefined) {
            titleField.text = vendor.title !== undefined ? vendor.title : ""
            websiteField.text = vendor.website !== undefined ? vendor.website : ""
            imageUrlField.text = vendor.imageUrl !== undefined ? vendor.imageUrl : ""
            shippingField.text = vendor.shippingRate !== undefined ? (vendor.shippingRate * 100).toFixed(1) : ""
            taxSwitch.checked = vendor.salesTax
            marketSwitch.checked = vendor.isMarket
        } else {
            titleField.text = ""
            websiteField.text = ""
            imageUrlField.text = ""
            shippingField.text = ""
            taxSwitch.checked = false
            marketSwitch.checked = false
        }
    }

    // Methods
    onAccepted: {
        if (vendor !== null) {
            vendor.title = titleField.text ? titleField.text : undefined
            vendor.website = websiteField.text ? websiteField.text : undefined
            vendor.imageUrl = imageUrlField.text ? imageUrlField.text : undefined
            vendor.salesTax = taxSwitch.checked
            vendor.shippingRate = parseFloat(shippingField.text) / 100
            vendor.isMarket = marketSwitch.checked
        }
    }

    // Body
    GridLayout {
        columns: 4
        columnSpacing: 32
        rowSpacing: 0

        M.SystemIcon {
            source: "icons/title.png"

            Layout.row: 0
            Layout.column: 0
            Layout.topMargin: 30
        }

        M.TextField {
            id: titleField
            labelText: "Title"
            text: vendor !== null ? vendor.title : ""

            Layout.fillWidth: true
            Layout.row: 0
            Layout.column: 1
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/web.png"

            Layout.row: 1
            Layout.column: 0
            Layout.topMargin: 30
        }

        M.TextField {
            id: websiteField
            labelText: "Website"

            Layout.fillWidth: true
            Layout.row: 1
            Layout.column: 1
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/image.png"

            Layout.row: 2
            Layout.column: 0
            Layout.topMargin: 30
        }

        M.TextField {
            id: imageUrlField
            labelText: "Image URL"

            Layout.fillWidth: true
            Layout.row: 2
            Layout.column: 1
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/shipping.png"

            Layout.row: 3
            Layout.column: 0
            Layout.topMargin: 30
        }

        M.TextField {
            id: shippingField
            labelText: "Avg. Shipping"
            suffix: M.Label { type: "Body 1"; text: "%"; opacity: 0.50 }
            horizontalAlignment: TextInput.AlignRight
            validator: DoubleValidator {
                top: 100
                bottom: 0
                decimals: 1
            }
        }

        SwitchDelegate {
            id: taxSwitch
            text: "Sales Tax:"
            leftPadding: 0
            Layout.row: 3
            Layout.column: 2
            Layout.topMargin: 24
        }


        M.SystemIcon {
            source: "icons/market.png"
            Layout.row: 4
            Layout.column: 0
            Layout.topMargin: 24
        }

        SwitchDelegate {
            id: marketSwitch
            text: "Market:"
            leftPadding: 0
            Layout.row: 4
            Layout.column: 1
            Layout.topMargin: 24
        }


        M.ProductImage {
            source: imageUrlField.text

            Layout.row: 0
            Layout.column: 3
            Layout.rowSpan: 5
            Layout.fillHeight: true
            Layout.preferredWidth: height
        }
    }
}
