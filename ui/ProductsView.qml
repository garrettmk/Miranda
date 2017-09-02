import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import Product 1.0
import ProfitRelationship 1.0
//import QtCharts 2.2


TableBrowserView {
    id: root
    title: "Products"

    Material.primary: Material.color(Material.DeepPurple, Material.Shade500)
    Material.accent: Material.color(Material.Orange, Material.Shade500)

    mainToolBarColor: Material.primary
    sideToolBarColor: Material.color(Material.DeepPurple, Material.Shade800)
    addNewButtonColor: Material.color(Material.DeepPurple, Material.ShadeA200)

    queryDialog.onlyShow: "Products"

    Component.onCompleted: model = database.getModel(database.newProductQuery())

    mainToolButtons: M.IconToolButton {
        iconSource: "../icons/import.png"
        onClicked: importDialog.open()
    }

    ImportDialog {
        id: importDialog
    }

    EditProductDialog {
        id: editProductDialog
        onAccepted: {
            database.saveObject(product)
            product = null
        }
    }

    ProductValidatorDialog {
        id: validateProductDialog
    }

    M.CenteredModalDialog {
        id: confirmDeleteDialog
        title: "Confirm Delete"
        standardButtons: Dialog.Yes | Dialog.No

        M.Label {
            id: messageLabel
            type: "Body 1"
            text: "Are you sure you want to delete the selected products?"
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

    M.CenteredModalDialog {
        id: groupEditTagsDialog
        property bool adding: true

        title: adding ? "Add Tags" : "Remove Tags"
        standardButtons: Dialog.Ok | Dialog.Cancel

        implicitWidth: 450
        contentHeight: groupChipEditor.implicitHeight
        padding: 24

        RowLayout {
            anchors.fill: parent
            spacing: 32
            M.SystemIcon {
                source: "icons/tag.png"
            }

            M.ChipEditor {
                id: groupChipEditor
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            var obj
            var selected = table.selectedIndices
            for (var i=0; i<selected.length; i++) {
                obj = model.getObject(selected[i])
                if (adding)
                    obj.addTags(groupChipEditor.model)
                else
                    obj.removeTags(groupChipEditor.model)

                database.saveObject(obj)
            }
            groupChipEditor.clear()
        }

    }

    onAddNewButtonClicked: {
        var prod = Qt.createQmlObject("import QtQuick 2.7; import Product 1.0; Product {}", editProductDialog)
        editProductDialog.product = prod
        editProductDialog.open()
    }

    columns: [
        {name: "Vendor", width: 225},
        {name: "SKU", width: 150},
        {name: "Brand", width: 150},
        {name: "Model", width: 125},
        {name: "Rank", width: 75, alignment: Qt.AlignRight},
        {name: "Category", width: 200}
    ]

    actionOnSelectedMenu: Menu {
        MenuItem {
            text: "Add tags..."
            onTriggered: { groupEditTagsDialog.adding = true; groupEditTagsDialog.open() }
        }
        MenuItem {
            text: "Remove tags..."
            onTriggered: { groupEditTagsDialog.adding = false; groupEditTagsDialog.open() }
        }
        MenuItem {
            text: "Delete..."
            onTriggered: confirmDeleteDialog.open()
        }
    }

    tableRowDelegate: M.TableRow {
        onClicked: { table.currentIndex = index; table.focus = true }

        M.Label {
            type: "Body 1"
            text: database.getVendorName(vendor) || "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: sku !== undefined ? sku : "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: brand !== undefined ? brand : "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: model !== undefined ? model : "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: rank !== undefined ? rank.toLocaleString() : "n/a"
            elide: Text.ElideLeft
            horizontalAlignment: Text.AlignRight
        }

        M.Label {
            type: "Body 1"
            text: category !== undefined ? category : "n/a"
            elide: Text.ElideRight
        }
    }

    sideToolBar: Item {
        Row {
            id: sideToolsRow
            spacing: 8
            anchors {
                top: parent.top
                right: parent.right
                margins: 8
            }

            M.IconToolButton {
                iconSource: "../icons/edit.png"
                enabled: root.currentObject !== null
                onClicked: {
                    editProductDialog.product = root.currentObject
                    editProductDialog.open()
                }
            }

            M.IconToolButton {
                iconSource: "../icons/double_check.png"
                enabled: root.currentObject !== null
                onClicked: {
                    validateProductDialog.product = root.currentObject
                    validateProductDialog.open()
                }
            }
        }


        M.Label {
            anchors {
                top: sideToolsRow.bottom
                topMargin: 0
                margins: 24
                left: parent.left
                right:parent.right
                bottom: parent.bottom
            }

            type: "Title"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            text: root.currentObject !== null ? root.currentObject.title !== undefined ? root.currentObject.title : "n/a" : ""
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
    }

    sidePanel: Flickable {
        id: panel
        clip: true
        anchors.fill: parent
        contentWidth: width
        contentHeight: panelLayout.implicitHeight

        ColumnLayout {
            id: panelLayout
            width: parent.width
            enabled: root.currentObject !== null
            spacing: 0

            M.ProductImage {
                source: enabled ? root.currentObject.imageUrl : ""
                Layout.fillWidth: true
                Layout.preferredHeight: width / (16/9)
            }

            M.ChipEditor {
                id: chipEditor
                readOnly: true
                model: enabled ? root.currentObject.tags : []
                Layout.fillWidth: true
                Layout.margins: 24
            }

            M.Divider { Layout.fillWidth: true }

            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 24
                rows: 5
                flow: GridLayout.TopToBottom
                columnSpacing: 32
                rowSpacing: 8

                // Column 1
                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Vendor:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "SKU:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Category:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Rank:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Feedback:"
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? database.getVendorName(root.currentObject.vendor) : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.sku : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.category !== undefined ? root.currentObject.category : "n/a" : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.rank !== undefined ? root.currentObject.rank.toLocaleString() : "n/a" : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.feedback !== undefined ? (root.currentObject.feedback * 100).toFixed() + "%" : "n/a" : ""
                }

                // Column 2
                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Brand:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Model:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "UPC:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Price:"
                }

                M.Label {
                    type: "Body 2"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.alignment: Qt.AlignRight
                    text: "Quantity:"
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.brand !== undefined ? root.currentObject.brand : "n/a" : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.model !== undefined ? root.currentObject.model : "n/a" : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.upc !== undefined ? root.currentObject.upc : "n/a" : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.price !== undefined ? "$" + root.currentObject.price.toFixed(2) : "n/a" : ""
                }

                M.Label {
                    type: "Body 1"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    text: enabled ? root.currentObject.quantity !== undefined ? root.currentObject.quantity.toLocaleString() : "n/a" : ""
                }
            }

            M.Label {
                Layout.margins: 24
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                text: enabled ? root.currentObject.description !== undefined ? root.currentObject.description : "n/a" : ""
                wrapMode: Text.Wrap
            }

            M.Divider {
                Layout.topMargin: 24
                Layout.fillWidth: true
            }

//            ChartView {
//                id: chart
//                title: "Test Chart"
//                Layout.fillWidth: true
//                Layout.preferredHeight: width / (16/9)
//                legend.alignment: Qt.AlignBottom
//                antialiasing: true

//                property var model: [
//                    { x: 0, y: 0 },
//                    { x: 1.1, y: 3.2 },
//                    { x: 1.9, y: 2.4 },
//                    { x: 2.1, y: 2.1 },
//                    { x: 2.9, y: 2.9 }
//                ]

//                Component.onCompleted: {
//                    model.forEach( function (x) {series.append(x.x, x.y)} )
//                }

//                SplineSeries {
//                        id: series

//                }
//            }
        }
    }
}
