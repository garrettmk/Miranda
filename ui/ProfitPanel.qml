import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0
import ProfitRelationship 1.0


Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // Public
    property Product product

    // Private
    property ProfitRelationship rel: null
    property var header: null

    onProductChanged: {
        if (product !== null && product !== undefined) {
            var isMarket = database.isMarket(product.vendor)
            var q = database.newRelationshipQuery()

            if (isMarket)
                q.query.marketListing = product
            else
                q.query.supplierListing = product

            rel = database.getObject(q)
            if (rel === null) {
                rel = null
                header = null
            } else {
                header = isMarket ? database.getProductHeader(rel.supplierListing) : database.getProductHeader(rel.marketListing)
            }
        } else {
            rel = null
            header = null
        }
    }

    // Body
    GridLayout {
        id: layout
        columns: 3
        columnSpacing: 48
        rowSpacing: 0
        anchors.fill: parent

        GridLayout {
            flow: GridLayout.TopToBottom
            rows: 2
            rowSpacing: 4
            columnSpacing: 32
            Layout.columnSpan: 3

            M.SystemIcon {
                source: rel !== null ? database.isMarket(product.vendor) ? "icons/vendor.png" : "icons/market.png" : "icons/unavailable.png"
                Layout.rowSpan: 2
            }

            M.LinkLabel {
                id: titleLabel
                text: header !== null ? header["title"] : "n/a"
                link: header !== null && header["detail_page_url"] !== undefined ? header["detail_page_url"] : ""
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            M.Label {
                type: "Caption"
                text: header !== null ? header["vendor"] + " " + header["sku"] : "n/a"
            }
        }

        M.Divider {
            Layout.columnSpan: 3
            Layout.topMargin: 16
            Layout.bottomMargin: 16
            Layout.fillWidth: true
        }

        M.Label {
            type: "Caption"
            text: "Profit:"
            Layout.leftMargin: 56
        }

        M.Label {
            type: "Caption"
            text: "Margin:"
        }

        M.Label {
            type: "Caption"
            text: "ROI:"
            Layout.fillWidth: true
        }

        M.Label {
            type: "Display 2"
            text: rel !== null && rel.profit !== undefined ? "$" + rel.profit.toFixed(2) : "n/a"
            Layout.leftMargin: 56
        }

        M.Label {
            type: "Display 2"
            text: rel !== null && rel.margin !== undefined ? (rel.margin * 100).toFixed() + "%" : "n/a"
        }

        M.Label {
            type: "Display 2"
            text: rel !== null && rel.roi !== undefined ? (rel.roi * 100).toFixed() + "%" : "n/a"
        }
    }


}
