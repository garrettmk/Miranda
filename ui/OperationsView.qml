import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0


TableBrowserView {
    id: root
    title: "Operations"

    Material.primary: Material.color(Material.Blue, Material.Shade500)
    Material.accent: Material.color(Material.Orange, Material.Shade500)

    mainToolBarColor: Material.primary
    sideToolBarColor: Material.color(Material.Blue, Material.Shade800)
    addNewButtonColor: Material.color(Material.Blue, Material.ShadeA200)

    queryDialog.onlyShow: "Operations"

    Component.onCompleted: model = database.getParentedModel(database.newOperationQuery(), root)

    columns: [
        {name: "Name", width: 300},
        {name: "Type", width: 200},
        {name: "Active", width: 75},
        {name: "Repeat", width:75}
    ]

    onAddNewButtonClicked: chooseOpTypeDialog.open()

    actionOnSelectedMenu: Menu {
        MenuItem {
            text: "Activate"
            onTriggered: {
                var obj
                var selected = table.selectedIndices
                for (var i=0; i<selected.length; i++) {
                    obj = model.getObject(selected[i])
                    obj.active = true
                    database.saveObject(obj)
                }
            }
        }

        MenuItem {
            text: "Deactivate"
            onTriggered: {
                var obj
                var selected = table.selectedIndices
                for (var i=0; i<selected.length; i++) {
                    obj = model.getObject(selected[i])
                    obj.active = false
                    database.saveObject(obj)
                }
            }
        }

        MenuItem {
            text: "Reschedule..."
        }

        MenuItem {
            text: "Delete..."
            onTriggered: confirmDeleteDialog.open()
        }
    }

    // Dialogs
    ChooseOpTypeDialog {
        id: chooseOpTypeDialog
        onAccepted: {
            var op = Qt.createQmlObject("import QtQuick 2.7; import " + kind + " 1.0;" + kind + " {}", editOperationDialog)
            editOperationDialog.operation = op
            editOperationDialog.open()
        }
    }

    EditOperationDialog {
        id: editOperationDialog
        onAccepted: {
            database.saveObject(operation)
            operation = null
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

    OperationsManagerDialog {
        id: operationsManagerDialog
    }

    mainToolButtons: M.IconToolButton {
        iconSource: "../icons/operation.png"
        onClicked: operationsManagerDialog.open()
    }

    tableRowDelegate: M.TableRow {
        onClicked: table.currentIndex = index

        M.Label {
            type: "Body 1"
            text: name !== undefined ? name : "n/a"
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: pythonClassName
            elide: Text.ElideRight
        }

        M.Label {
            type: "Body 1"
            text: active ? "Yes" : "No"
        }

        M.Label {
            type: "Body 1"
            text: repeat !== undefined ? repeat + " hours" : "No"
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
                editOperationDialog.operation = root.currentObject
                editOperationDialog.open()
            }
        }

        M.Label {
            type: "Headline"
            text: root.currentObject !== null ? root.currentObject.name !== undefined ? root.currentObject.name : "n/a" : ""
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
        enabled: root.currentObject !== null
        anchors.top: parent.top
        width: parent.width
        spacing: 0

        GridLayout {
            Layout.margins: 24
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 32
            rowSpacing: 8

            M.Label {
                type: "Body 2 Light"
                text: "Type:"
                Layout.alignment: Qt.AlignRight
            }

            M.Label {
                type: "Body 1"
                text: enabled ? root.currentObject.pythonClassName : ""
                Layout.fillWidth: true
            }

            M.Label {
                type: "Body 2 Light"
                text: "Scheduled:"
                Layout.alignment: Qt.AlignRight
            }

            Row {
                spacing: 8
                M.Label {
                    type: "Body 1"
                    text: enabled ? root.currentObject.scheduled.toString() : ""
                }

                M.TinyIconButton {
                    iconSource: "icons/timer.png"
                    onClicked: root.currentObject.scheduled = new Date()
                }
            }

            M.Label {
                type: "Body 2 Light"
                text: "Repeat:"
                Layout.alignment: Qt.AlignRight
            }

            M.Label {
                type: "Body 1"
                text: enabled ? root.currentObject.repeat !== undefined ? "Every " + root.currentObject.repeat + " hours" : "No" : ""
            }

            M.Label {
                type: "Body 2 Light"
                text: "Active:"
                Layout.alignment: Qt.AlignRight
            }

            M.Label {
                type: "Body 1"
                text: enabled ? root.currentObject.active ? "Yes" : "No" : ""
            }
        }

        M.Divider { Layout.fillWidth: true }

        StackLayout {
            Layout.topMargin: 24
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: enabled ? pageNames.indexOf(root.currentObject.pythonClassName) : 0

            property var pageNames: ["none", "FindMarketMatches", "UpdateProducts", "UpdateOpportunities"]

            Item {
                // Blank item when no operation is selected
            }

            // FindMarketMatches
            Item {
                GridLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: 24
                        rightMargin: 24
                    }

                    columns: 2
                    columnSpacing: 32

                    M.Label {
                        type: "Body 2 Light"
                        text: "Completed:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.Label {
                        id: completionLabel
                        type: "Body 1"
                        Connections {
                            target: root
                            onCurrentObjectChanged: {
                                if (root.currentObject !== null) {
                                    var stamped = database.queryCount(root.currentObject.stampedQuery())
                                    var total = database.queryCount(root.currentObject.objectQuery)
                                    completionLabel.text = stamped.toLocaleString() + "/" + total.toLocaleString() + " (" + (stamped/total*100).toFixed(1) + "%)"
                                } else {
                                    completionLabel.text = ""
                                }
                            }
                        }
                    }

                    M.Label {
                        type: "Body 2 Light"
                        text: "Vendor:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.Label {
                        type: "Body 1"
                        text: enabled && root.currentObject.objectQuery.query.vendor !== undefined ? database.getVendorName(root.currentObject.objectQuery.query.vendor) : "n/a"
                        Layout.fillWidth: true
                    }
                }
            }

            // UpdateProducts
            Item {
                GridLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: 24
                        rightMargin: 24
                    }

                    columns: 2
                    columnSpacing: 32

                    M.Label {
                        type: "Body 2 Light"
                        text: "Tags"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.ChipEditor {
                        readOnly: true
                        model: enabled && root.currentObject.objectQuery.query.tags !== undefined ? root.currentObject.objectQuery.query.tags : []
                        Layout.fillWidth: true
                    }

                    M.Label {
                        type: "Body 2 Light"
                        text: "Log:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.Label {
                        type: "Body 1"
                        text: enabled ? root.currentObject.log ? "Yes" : "No" : "n/a"
                    }
                }
            }

            // UpdateOpportunities
            Item {
                GridLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: 24
                        rightMargin: 24
                    }

                    columns: 2
                    columnSpacing: 32

                    M.Label {
                        type: "Body 2 Light"
                        text: "Completed:"
                        Layout.alignment: Qt.AlignRight
                    }

                    Row {
                        spacing: 8
                        Layout.fillWidth: true

                        M.Label {
                            id: updateOppsCompletionLabel
                            type: "Body 1"

                            function refresh() {
                                if (root.currentObject !== null) {
                                    var stamped = database.queryCount(root.currentObject.stampedQuery())
                                    var total = database.queryCount(root.currentObject.objectQuery)
                                    updateOppsCompletionLabel.text = stamped.toLocaleString() + "/" + total.toLocaleString() + " (" + (stamped/total*100).toFixed(1) + "%)"
                                } else {
                                    updateOppsCompletionLabel.text = ""
                                }
                            }

                            Connections {
                                target: root
                                onCurrentObjectChanged: updateOppsCompletionLabel.refresh()
                            }
                        }

                        M.TinyIconButton {
                            iconSource: "icons/delete.png"
                            enabled: root.currentObject !== null
                            onClicked: { database.clearOpLogs(root.currentObject); updateOppsCompletionLabel.refresh() }
                        }
                    }

                    M.Label {
                        type: "Body 2 Light"
                        text: "Min. Rank:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.Label {
                        type: "Body 1"
                        text: enabled ? root.currentObject.objectQuery.query.minMarketRank !== undefined ? root.currentObject.objectQuery.query.minMarketRank : "n/a" : ""
                    }

                    M.Label {
                        type: "Body 2 Light"
                        text: "Max. Rank:"
                        Layout.alignment: Qt.AlignRight
                    }

                    M.Label {
                        type: "Body 1"
                        text: enabled ? root.currentObject.objectQuery.query.maxMarketRank !== undefined ? root.currentObject.objectQuery.query.maxMarketRank : "n/a" : ""
                    }
                }
            }
        }
    }
}
