import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import Vendor 1.0


TableBrowserView {
    id: root
    title: "Vendors"

    Material.primary: Material.color(Material.Purple, Material.Shade500)
    Material.accent: Material.color(Material.Teal, Material.Shade500)

    mainToolBarColor: Material.primary
    sideToolBarColor: Material.color(Material.Purple, Material.Shade800)
    addNewButtonColor: Material.color(Material.Purple, Material.ShadeA200)

    queryDialog.onlyShow: "Vendors"

    Component.onCompleted: model = database.getParentedModel(database.newVendorQuery(), root)

    EditVendorDialog {
        id: editVendorDialog
        onAccepted: {
            database.saveObject(vendor)
        }

        onRejected: {
            if (vendor !== null && vendor !== undefined)
                if (!model.contains(vendor)) {
                    vendor.destroy()
                    vendor = null
                }
        }
    }

    M.CenteredModalDialog {
        id: confirmDeleteDialog
        title: "Confirm Delete"
        standardButtons: Dialog.Yes | Dialog.No

        M.Label {
            id: messageLabel
            type: "Body 1"
            text: "Are you sure you want to delete the selected vendors?"
        }

        onAccepted: {
            var obj
            var selected = table.selectedIndices
            selected.sort(function(a, b) { return b - a }) // Sort descending
            for (var i=0; i<selected.length; i++) {
                obj = model.getObject(selected[i])
                model.removeRow(selected[i])
                database.deleteObject(obj)
                obj.destroy()
            }
            table.selectedIndices = []
        }
    }

    actionOnSelectedMenu: Menu {
        MenuItem {
            text: "Delete " + table.selectedIndices.length + " vendors..."
            onClicked: confirmDeleteDialog.open()
        }
    }

    onAddNewButtonClicked: {
        var vend = Qt.createQmlObject("import QtQuick 2.7; import Vendor 1.0; Vendor {}", editVendorDialog)
        editVendorDialog.vendor = vend
        editVendorDialog.open()
    }

    columns: [
        {name: "Title", width: 300},
        {name: "Website", width: 300},
        {name: "Market", width: 75},
        {name: "Sales Tax", width: 75},
        {name: "Avg. Shipping (%)", width: 125}
    ]

    tableRowDelegate: M.TableRow {
        onClicked: table.currentIndex = index

        M.Label {
            type: "Body 1"
            text: title !== undefined ? title : "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: website !== undefined ? website : "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: isMarket !== undefined ? isMarket ? "Yes" : "No" : "n/a"
        }

        M.Label {
            type: "Body 1"
            text: salesTax !== undefined ? salesTax ? "Yes" : "No" : "n/a"
        }

        M.Label {
            type: "Body 1"
            text: shippingRate !== undefined ? (shippingRate * 100).toFixed(1) + "%" : "n/a"
        }
    }

    sideToolBar: Item {
        M.IconToolButton {
            iconSource: "../icons/edit.png"
            enabled: root.currentObject !== null
            anchors {
                top: parent.top
                right: parent.right
                margins: 8
            }
            onClicked: {
                editVendorDialog.vendor = root.currentObject
                editVendorDialog.open()
            }
        }

        M.Label {
            type: "Headline"
            text: root.currentObject !== null ? root.currentObject.title !== undefined ? root.currentObject.title : "n/a" : ""
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.Wrap
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 24
            }
        }
    }

    sidePanel: ColumnLayout {
        anchors.top: parent.top
        width: parent.width
        spacing: 0
        enabled: root.currentObject !== null

        M.ProductImage {
            Layout.fillWidth: true
            Layout.preferredHeight: width / (16/9)
            source: enabled ? root.currentObject.imageUrl : ""
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.margins: 24
            columns: 2
            columnSpacing: 32
            rowSpacing: 8

            M.Label {
                type: "Body 2"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.alignment: Qt.AlignRight
                text: "Website:"
            }

            M.LinkLabel {
                type: "Body 1"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                text: enabled ? root.currentObject.website !== undefined ? root.currentObject.website : "n/a" : ""
                link: enabled && root.currentObject.website !== undefined ? root.currentObject.website : ""
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            M.Label {
                type: "Body 2"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.alignment: Qt.AlignRight
                text: "Market:"
            }

            M.LinkLabel {
                type: "Body 1"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                text: enabled ? root.currentObject.isMarket ? "Yes" : "No" : ""
                elide: Text.ElideRight
            }

            M.Label {
                type: "Body 2"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.alignment: Qt.AlignRight
                text: "Sales Tax:"
            }

            M.LinkLabel {
                type: "Body 1"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                text: enabled ? root.currentObject.salesTax ? "Yes" : "No" : ""
                elide: Text.ElideRight
            }

            M.Label {
                type: "Body 2"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.alignment: Qt.AlignRight
                text: "Avg. Shipping:"
            }

            M.LinkLabel {
                type: "Body 1"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                text: enabled ? root.currentObject.shippingRate !== undefined ? (root.currentObject.shippingRate * 100).toFixed(1) + "%" : "n/a" : ""
                elide: Text.ElideRight
            }
        }

        M.Divider {
            Layout.fillWidth: true
        }

    }
}
