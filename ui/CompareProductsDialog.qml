import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M


Dialog {
    id: dialog
    modal: true
    header: null
    standardButtons: Dialog.Ok

    x: ApplicationWindow.window.width / 2 - width / 2
    y: ApplicationWindow.window.height / 2 - height / 2
    padding: 0

    implicitWidth: 1800
    implicitHeight: 800

    property alias model: table.model

    M.ObjectTable {
        id: table
        anchors.fill: parent
        title: "Compare " + (model !== null ? model.length : 0) + " products:"
        headerBackgroundColor: Material.theme === Material.Light ? Material.background : Material.color(Material.Grey, Material.Shade800)

        columns: [
            {name: "Title", property: "title", width: 450},
            {name: "SKU", property: "sku", width: 125, alignment: Text.AlignLeft},
            {name: "Brand", property: "brand", width: 125, alignment: Text.AlignLeft},
            {name: "Model", property: "model", width: 125, alignment: Text.AlignLeft},
            {name: "Category", property: "category", width: 150, alignment: Text.AlignLeft},
            {name: "Rank", property: "rank", width: 75},
            {name: "Price", property: "price", width: 75},
            {name: "Quantity", property: "quantity", width: 75}
        ]
    }
}
