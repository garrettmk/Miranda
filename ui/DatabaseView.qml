import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import MapObject 1.0


BrowserView {
    id: root
    title: "Database"
    Material.primary: Material.color(Material.Orange, Material.Shade700)
    Material.accent: Material.color(Material.Blue, Material.Shade500)

    property ObjectModel selectionModel: ObjectModel {}

    // View body
    queryBuilder: DatabaseQueryBuilder {}

    cardDelegate: DocumentCard {
        id: documentCard
        property MapObject object: index >= 0 ? ListView.view.model.getObject(index) : null
        selected: selectionModel.contains(object)
        Material.theme: root.Material.theme
        Material.primary: Material.color(Material.Orange, Material.Shade600)
        Material.accent: root.Material.accent

        onSelectButtonClicked: {
            if (!selected) {
                selectionModel.removeRow(selectionModel.matchObject(object))
            } else {
                selectionModel.append(object)
            }
            selected = Qt.binding(function() {return selectionModel.contains(object)})
        }

        property var conn: Connections {
            target: selectionModel
            onModelReset: documentCard.selected = Qt.binding(function() {return selectionModel.contains(object)})
            onRowsRemoved: documentCard.selected = Qt.binding(function() {return selectionModel.contains(object)})
        }

        actionMenu: Menu {
            MenuItem {
                text: "Copy id"
                onTriggered: application.setClipboardText(id)
            }
        }
    }

    comparisonTool: M.ObjectTable {
        id: selectionTable
        title: model.length + " selected"
        model: selectionModel

        columns: [
            {name: "_id", property: "id", width: 400}
        ]

        headerTools: M.IconToolButton {
            enabled: selectionModel.length > 0
            iconSource: "../icons/dots_vertical.png"
            onClicked: selectionTableMenu.open()

            Menu {
                id: selectionTableMenu

                MenuItem {
                    text: "Update..."
                }

                MenuItem {
                    text: "Delete..."
                }
            }
        }

        onRowClicked: {
            var idx = root.model.matchObject(selectionModel.getObject(index))
            cardListView.positionViewAtIndex(idx, ListView.beginning)
        }
    }
}
