import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import MapObject 1.0


TableBrowserView {
    id: root
    title: "Database"

    Material.primary: Material.color(Material.Orange, Material.Shade500)
    Material.accent: Material.color(Material.Blue, Material.Shade500)

    mainToolBarColor: Material.primary
    sideToolBarColor: Material.color(Material.Orange, Material.Shade800)
    addNewButtonColor: Material.color(Material.Orange, Material.ShadeA200)
    addNewButtonVisible: false

    columns: [
        {name: "ObjectId", width: 400},
        {name: "Object Type", width: 150}
    ]

    tableRowDelegate: M.TableRow {
        onClicked: table.currentIndex = index

        M.Label {
            type: "Body 1"
            text: "ObjectId('" + id + "')"
        }

        M.Label {
            type: "Body 1"
            text: pythonClassName
        }
    }

    sideToolBar: Item {
        M.Label {
            anchors.fill: parent
            anchors.margins: 24
            type: "Headline"
            text: root.currentObject !== null ? "ObjectId('" + root.currentObject.id + "')" : ""
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.Wrap
        }
    }

    sidePanel: Flickable {
        clip: true
        anchors.fill: parent
        anchors.margins: 24
        contentWidth: width
        contentHeight: documentLabel.implicitHeight

        M.Label {
            id: documentLabel
            width: parent.width
            type: "Body 1"
            text: currentObject !== null ? currentObject.currentDocumentText : ""
            wrapMode: Text.Wrap
            font.family: "Courier"
            padding: 24
        }
    }
}
