import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import Vendor 1.0


BrowserView {
    id: root
    title: "Vendors"
    Material.primary: Material.color(Material.Purple, Material.Shade700)
    Material.accent: Material.color(Material.Green, Material.Shade500)

    property ObjectModel selectionModel: ObjectModel {}

    // Dialogs
    EditVendorDialog {
        id: editVendorDialog

        onAccepted: {
            if (!model.contains(vendor)) {
                model.insert(0, vendor)
            }

            database.saveObject(vendor)
            vendor = null
        }

        onRejected: {
            if (!model.contains(vendor)) {
                vendor.destroy()
            }

            vendor = null
        }
    }

    ImportDialog {
        id: importDialog
        Material.theme: parent.Material.theme
        Material.primary: parent.Material.primary
        Material.accent: parent.Material.accent
    }

    // View body
    queryBuilder: VendorQueryBuilder {}

    // Card delegate
    cardDelegate: VendorCard {
        id: vendorCard
        property Vendor vendor: index >= 0 ? root.model.getObject(index) : null
        selected: selectionModel.contains(vendor)
        Material.theme: root.Material.theme
        Material.primary: Material.color(Material.Purple, Material.Shade600)
        Material.accent: root.Material.accent

        onSelectButtonClicked: {
            if (!selected) {
                selectionModel.removeRow(selectionModel.matchObject(vendor))
            } else {
                selectionModel.append(vendor)
            }
            selected = Qt.binding(function() {return selectionModel.contains(vendor)})
        }


        property var conn: Connections {
            target: selectionModel
            onModelReset: vendorCard.selected = Qt.binding(function() {return selectionModel.contains(vendor)})
            onRowsRemoved: vendorCard.selected = Qt.binding(function() {return selectionModel.contains(vendor)})
        }

        actionMenu: Menu {
            MenuItem {
                text: "Edit"
                onTriggered: {
                    editVendorDialog.vendor = vendor
                    editVendorDialog.open()
                }
            }
            MenuItem {
                text: "Import..."
                onTriggered: {
                    importDialog.vendor = vendor
                    importDialog.open()
                }
            }
        }
    }

    // Comparison tool
    toolArea: M.ObjectTable {
        id: selectionTable
        title: "(" + model.length + ") selected:"
        model: selectionModel

        columns: [
            {name: "Title", property: "title", width: 200},
            {name: "Website", property: "website", width: 175, alignment: Text.AlignLeft}
        ]

        headerTools: M.IconToolButton {
            enabled: selectionModel.length > 0
            iconSource: "../icons/dots_vertical.png"
            onClicked: selectionTableMenu.open()

            Menu {
                id: selectionTableMenu
                MenuItem {
                    text: "Delete"
                    enabled: selectionModel.length > 0
                    onTriggered: {
                        database.deleteModel(selectionModel)

                        var idx = 0
                        for (var i=0; i<selectionModel.length; i++) {
                            idx = root.model.matchObject(selectionModel.getObject(i))
                            root.model.removeRow(idx)
                        }

                        selectionModel.clear()
                    }
                }
            }
        }

        onRowClicked: {
            var idx = root.model.matchObject(selectionModel.getObject(index))
            cardListView.positionViewAtIndex(idx, ListView.Beginning)
        }
    }

    // New vendor action
    onNewItemClicked: {
        var vnd = Qt.createQmlObject("import QtQuick 2.7; import Vendor 1.0; Vendor {}", editVendorDialog)
        editVendorDialog.vendor = vnd
        editVendorDialog.open()
    }
}
