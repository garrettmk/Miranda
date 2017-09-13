import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import ProfitRelationship 1.0


TableBrowserView {
    id: root
    title: "Opportunities"

    Material.primary: Material.color(Material.Green, Material.Shade500)
    Material.accent: Material.color(Material.Yellow, Material.Shade500)

    mainToolBarColor: Material.primary
    sideToolBarColor: Material.color(Material.Green, Material.Shade800)
    addNewButtonColor: Material.color(Material.Green, Material.ShadeA200)

    queryDialog.onlyShow: "Opportunities"
    addNewButtonVisible: false

    Component.onCompleted: model = database.getParentedModel(database.newOpportunityQuery(), root)

    columns: [
        {name: "Title", width: 450},
        {name: "Vendor", width: 125},
        {name: "Rank", width: 100},
        {name: "Profit ($)", width: 75, alignment: Qt.AlignRight},
        {name: "Margin (%)", width: 75, alignment: Qt.AlignRight},
        {name: "ROI (%)", width: 75, alignment: Qt.AlignRight}
    ]

    actionOnSelectedMenu: Menu {
        MenuItem {
            text: "Edit market tags..."
            onTriggered: { editTagsDialog.applyToMarkets = true; editTagsDialog.open() }
        }

        MenuItem {
            text: "Edit supplier tags..."
            onTriggered: { editTagsDialog.applyToMarkets = false; editTagsDialog.open() }
        }

        MenuItem {
            text: "Delete..."
            onTriggered: confirmDeleteDialog.open()
        }
    }

    M.CenteredModalDialog {
        id: confirmDeleteDialog
        title: "Confirm Delete"
        standardButtons: Dialog.Yes | Dialog.No

        M.Label {
            id: messageLabel
            type: "Body 1"
            text: "Are you sure you want to delete the selected operations?"
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

    EditTagsDialog {
        id: editTagsDialog
        title: applyToMarkets ? "Edit market tags" : "Edit supplier tags"
        property bool applyToMarkets: true

        onAccepted: {
            var obj
            var selected = table.selectedIndices
            for (var i=0; i<selected.length; i++) {
                obj = applyToMarkets ? model.getObject(selected[i]).marketListing : model.getObject(selected[i].supplierListing)
                obj = database.getReferencedObject(obj)
                if (adding)
                    obj.addTags(tags)
                else
                    obj.removeTags(tags)

                database.saveObject(obj)
            }
            tags = []
        }
    }

    tableRowDelegate: M.TableRow {
        onClicked: {
            if (root.currentObject !== null && root.currentObject.modified)
                database.saveObject(root.currentObject)

            table.currentIndex = index
        }
        property var header: index >= 0 ? database.getProductHeader(marketListing) : null

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
            text: marketListing.rank !== undefined ? marketListing.rank.toLocaleString() : "n/a"
            elide: Text.ElideRight
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

    sideToolBar: Item {
        Row {
            spacing: 8
            anchors {
                top: parent.top
                right: parent.right
                margins: 8
            }

            M.IconToolButton {
                iconSource: "../icons/remove.png"
                enabled: root.currentObject !== null
                onClicked: {
                    var obj = root.currentObject
                    model.removeRow(table.currentIndex)
                    database.deleteObject(obj)
                    obj.destroy()
                    if (model.length > 0 && table.currentIndex >= model.length)
                        table.currentIndex = model.length - 1
                    else if (model.length > 0)
                        root.currentObject = Qt.binding( function() { return (table.currentIndex > -1 && model !== null ? model.getObject(table.currentIndex) : null) })
                }
            }
        }

        M.Label {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 8
            }
            type: "Caption"
            text: root.currentObject !== null && root.currentObject.similarityScore !== undefined ? (root.currentObject.similarityScore * 100).toFixed() + "%" : "n/a"
        }
    }

    sidePanel: Flickable {
        clip: true
        anchors.fill: parent
        contentWidth: width
        contentHeight: sideLayout.implicitHeight

        ColumnLayout {
            id: sideLayout
            width: parent.width
            spacing: 32

            OpportunityPanel {
                id: oppPanel
                currentOpp: root.currentObject
                Layout.fillWidth: true
            }

            M.Divider {
                Layout.fillWidth: true
            }

            ProductHistoryChart {
                Layout.fillWidth: true
                Layout.preferredHeight: width / (16/9)
                product: root.currentObject !== null && root.currentObject.marketListing.ref !== undefined ? root.currentObject.marketListing.ref : null
            }
        }
    }
}
