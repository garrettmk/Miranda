import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Operation 1.0


M.CenteredModalDialog {
    id: root
    title: "Edit Operation"
    standardButtons: Dialog.Save | Dialog.Cancel

    property Operation operation

    onOperationChanged: {
        if (operation !== null) {
            nameField.text = operation.name !== undefined ? operation.name : ""
            scheduledField.text = operation.scheduled !== undefined ? operation.scheduled.toString() : ""
            activeSwitch.checked = operation.active

            if (operation.repeat === undefined)
                repeatBox.currentIndex = 0
            else if (operation.repeat === 1)
                repeatBox.currentIndex = 1
            else if (operation.repeat === 3)
                repeatBox.currentIndex = 2
            else if (operation.repeat === 6)
                repeatBox.currentIndex = 3
            else if (operation.repeat === 24)
                repeatBox.currentIndex = 4

            if (operation.pythonClassName === "FindMarketMatches") {
                vendorBox.currentVendor = operation.productQuery.query.vendor
            } else if (operation.pythonClassName === "UpdateProducts") {
                updateProductsTags.model = operation.productQuery.query.tags
            }

        } else {
            root.title = "n/a"
            nameField.text = ""
            scheduledField.text = ""
            repeatBox.currentIndex = 0
            activeSwitch.checked = false
        }
    }

    // Methods
    onAccepted: {
        operation.name = nameField.text ? nameField.text : undefined
        operation.scheduled = scheduledField.text ? new Date(scheduledField.text) : undefined
        operation.active = activeSwitch.checked

        if (repeatBox.currentIndex === 0)
            operation.repeat = undefined
        else if (repeatBox.currentIndex === 1)
            operation.repeat = 1
        else if (repeatBox.currentIndex === 2)
            operation.repeat = 3
        else if (repeatBox.currentIndex === 3)
            operation.repeat = 6
        else if (repeatBox.currentIndex === 4)
            operation.repeat = 24

        var kind = operation.pythonClassName
        if (kind === "FindMarketMatches") {
            operation.productQuery.query.vendor = vendorBox.currentVendor
        } else if (kind === "UpdateProducts") {
            operation.productQuery.query.tags = updateProductsTags.model
        }
    }

    onRejected: operation = null

    // Body
    ColumnLayout {
        id: layout
        spacing: 0
        anchors.fill: parent

        GridLayout {
            columns: 2
            rowSpacing: 0
            columnSpacing: 32
            Layout.fillWidth: true

            M.SystemIcon {
                source: "icons/title.png"
                Layout.topMargin: 30
            }

            M.TextField {
                id: nameField
                labelText: "Name"
                autoScroll: false
                Layout.fillWidth: true
            }

            M.SystemIcon {
                source: "icons/calendar.png"
                Layout.topMargin: 30
            }

            M.TextField {
                id: scheduledField
                labelText: "Scheduled"
                Layout.fillWidth: true
            }

            M.SystemIcon {
                source: "icons/reload.png"
                Layout.topMargin: 30
            }

            ComboBox {
                id: repeatBox
                model: ["Never", "Hourly", "Every 3 hours", "Every 6 hours", "Daily"]
                Layout.topMargin: 24
            }

            M.SystemIcon {
                source: "icons/priority.png"
                Layout.topMargin: 30
            }

            Switch {
                id: activeSwitch
                text: checked ? "Active" : "Inactive"
                leftPadding: 0
                Layout.topMargin: 28
            }
        }

        M.Divider {
            Layout.fillWidth: true
            Layout.topMargin: 24
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 24
            Layout.bottomMargin: 24

            currentIndex: operation !== null ? ["DummyOperation", "FindMarketMatches"].indexOf(operation.pythonClassName) : 0

            // DummyOperation
            M.Label {
                type: "Body 1"
                text: "DummyOperation does not have any editable parameters."
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // FindMarketMatches
            GridLayout {
                anchors.top: parent.top
                width: parent.width
                columns: 2
                columnSpacing: 32

                M.Label {
                    type: "Body 1"
                    text: "Vendor:"
                    Layout.alignment: Qt.AlignRight
                }

                VendorComboBox {
                    id: vendorBox
                }

                M.Label {
                    type: "Body 1"
                    text: "Tags"
                    Layout.alignment: Qt.AlignRight
                }

                M.ChipEditor {
                    id: chipEditor
                    Layout.fillWidth: true
                }
            }

            // UpdateProducts
            GridLayout {
                anchors.top: parent.top
                width: parent.width
                columns: 2
                columnSpacing: 32

                M.Label {
                    type: "Body 1"
                    text: "Update listings with tags:"
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                }

                M.ChipEditor {
                    id: updateProductsTags
                    Layout.fillWidth: true
                }
            }
        }
    }

}
