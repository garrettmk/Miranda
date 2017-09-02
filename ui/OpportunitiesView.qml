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

    Component.onCompleted: model = database.getModel(database.newOpportunityQuery())

    columns: [
        {name: "Title", width: 450},
        {name: "Vendor", width: 125},
        {name: "SKU", width: 100},
        {name: "Profit ($)", width: 75, alignment: Qt.AlignRight},
        {name: "Margin (%)", width: 75, alignment: Qt.AlignRight},
        {name: "ROI (%)", width: 75, alignment: Qt.AlignRight}
    ]

    actionOnSelectedMenu: Menu {
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

    tableRowDelegate: M.TableRow {
        onClicked: table.currentIndex = index
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
            text: header !== null ? header["sku"] : "n/a"
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

    sidePanel: Flickable {
        clip: true
        anchors.fill: parent
        contentWidth: width
        contentHeight: oppPanel.implicitHeight

        OpportunityPanel {
            id: oppPanel
            currentOpp: root.currentObject
            width: parent.width
        }
    }
}
