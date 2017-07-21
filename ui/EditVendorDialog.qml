import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Vendor 1.0

Dialog {
    id: dialog
    modal: true
    title: "Edit Vendor"
    standardButtons: Dialog.Save | Dialog.Cancel

    x: ApplicationWindow.window.width / 2 - (width / 2)
    y: ApplicationWindow.window.height / 2 - (height / 2)
    implicitWidth: 800

    property Vendor vendor

    // Methods
    onAccepted: {
        if (vendor !== null) {
            vendor.title = titleField.text
            vendor.website = websiteField.text
            vendor.imageUrl = imageUrlField.text
            vendor.salesTax = taxSwitch.checked
            vendor.shippingRate = parseFloat(shippingField.text)
        }
    }

    GridLayout {
        columns: 4
        columnSpacing: 24
        rowSpacing: 16
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        M.SystemIcon {
            source: "icons/title.png"

            Layout.row: 0
            Layout.column: 0
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
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
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            id: websiteField
            labelText: "Website"
            text: vendor !== null ? vendor.website : ""

            Layout.fillWidth: true
            Layout.row: 1
            Layout.column: 1
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/image.png"

            Layout.row: 2
            Layout.column: 0
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            id: imageUrlField
            labelText: "Image URL"
            text: vendor !== null ? vendor.imageUrl : ""

            Layout.fillWidth: true
            Layout.row: 2
            Layout.column: 1
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/shipping.png"

            Layout.row: 3
            Layout.column: 0
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            id: shippingField
            labelText: "Avg. Shipping"
            suffix: Label {text: "%"; opacity: 0.54}
            text: "0.0"
            horizontalAlignment: TextInput.AlignRight
            validator: DoubleValidator {
                top: 100
                bottom: 0
                decimals: 1
            }
        }

        RowLayout {
            Layout.row: 3
            Layout.column: 2
            Layout.fillWidth: true

            SwitchDelegate {
                id: taxSwitch
                text: "Sales Tax:"
                Layout.topMargin: 24
            }
            Item {
                Layout.fillWidth: true
            }
        }

        M.ProductImage {
            source: imageUrlField.text

            Layout.row: 0
            Layout.column: 3
            Layout.rowSpan: 4
            Layout.fillHeight: true
            Layout.preferredWidth: height
        }
    }
}
