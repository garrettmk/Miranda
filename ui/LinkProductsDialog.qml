import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0
import ObjectQuery 1.0
import ObjectModel 1.0


Dialog {
    id: root
    clip: true
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel

    x: ApplicationWindow.window.width / 2 - width / 2
    y: ApplicationWindow.window.height / 2 - height / 2
    contentWidth: table.implicitWidth
    contentHeight: contentWidth / (16/9)
    padding: 0

    Material.theme: parent.Material.theme
    Material.primary: parent.Material.primary
    Material.foreground: parent.Material.foreground
    Material.accent: parent.Material.accent


    // Body
    M.ObjectTable {
        id: table
        model: product.matchedProducts
        enabled: product !== undefined && product !== null
        Layout.fillWidth: true
        Layout.fillHeight: true
        headerBackgroundColor: Material.theme === Material.Light ? Material.background : Material.color(Material.Grey, Material.Shade800)
        columns: [
            {name: "Listing", width: 450},
            {name: "Vendor", width: 125},
            {name: "SKU", width: 125},
            {name: "Brand", width: 100},
            {name: "Model", width: 100},
            {name: "Price", width: 50, alignment: Qt.AlignRight},
            {name: "Quantity", width: 50, alignment: Qt.AlignRight},
        ]

        delegate: M.TableRow {
            M.Label {
                type: "Body 1"
                text: ref.detailPageUrl !== undefined ? "<a href=\'" + ref.detailPageUrl + "\'>" + ref.title + "</a>" : ref.title
                elide: Text.ElideRight
                onLinkActivated: Qt.openUrlExternally(link)
                linkColor: Material.foreground
            }
            M.Label {
                type: "Body 1"
                text: ref !== undefined ? database.getNameOfVendor(ref.vendor) : "n/a"
                elide: Text.ElideRight
            }
            M.Label {
                type: "Body 1"
                text: ref.sku !== undefined ? ref.sku : "n/a"
                elide: Text.ElideRight
            }
            M.Label {
                type: "Body 1"
                text: ref.brand !== undefined ? ref.brand : "n/a"
                elide: Text.ElideRight
            }
            M.Label {
                type: "Body 1"
                text: ref.model !== undefined ? ref.model : "n/a"
                elide: Text.ElideRight
            }
            M.Label {
                type: "Body 1"
                text: ref.price !== undefined ? ref.price : "n/a"
                elide: Text.ElideRight
            }
            M.Label {
                type: "Body 1"
                text: ref.quantity !== undefined ? ref.quantity : "n/a"
                elide: Text.ElideRight
            }
        }
    }
}
