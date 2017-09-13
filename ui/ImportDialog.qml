import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2 as Dialogs
import "controls" as M
import Vendor 1.0
import Product 1.0
import FileImportHelper 1.0
import Validator 1.0
import PriceValidator 1.0
import QuantityValidator 1.0
import RankValidator 1.0


M.CenteredModalDialog {
    id: dialog
    title: "Import Products"
    standardButtons: Dialog.NoButton

    width: 800
    height: width / (4/3)

    property alias vendor: vendorBox.currentVendor
    property FileImportHelper helper: FileImportHelper {
        tags: chipEditor.model
        vendor: dialog.vendor
    }

    Component.onCompleted: {
        helper.database = database
        helper.validators = validatorPanel.validators
    }

    onRejected: reset()

    function reset() {
        helper.close()
        view.currentIndex = 0
    }

    Dialogs.FileDialog {
        id: fileDialog
        onAccepted: filenameField.text = fileUrl.toString().replace(/^(file:\/{2})/, "")
    }

    SwipeView {
        id: view
        clip: true
        interactive: false
        currentIndex: 0
        anchors.fill: parent
        anchors.margins: 32

        // First page
        Item {
            SwipeView.onIsCurrentItemChanged: helper.running = false
            GridLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                columns: 2
                columnSpacing: 32
                rowSpacing: 0

                M.Label {
                    type: "Body 2"
                    text: "Choose a file:"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.columnSpan: 2
                }

                M.SystemIcon {
                    source: "icons/file.png"
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 4
                }

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    M.TextField {
                        id: filenameField
                        labelText: "Path or URL"
                        text: helper.filePath
                        Layout.fillWidth: true
                        enabled: !helper.running
                    }
                    Button {
                        text: "..."
                        flat: true
                        Layout.preferredWidth: height
                        Layout.alignment: Qt.AlignBottom
                        enabled: !helper.running

                        onClicked: fileDialog.open()
                    }
                }


                M.Label {
                    type: "Body 2"
                    text: "Import into vendor:"
                    opacity: Material.theme === Material.Light ? 0.54 : 0.70
                    Layout.columnSpan: 2
                    Layout.topMargin: 48
                    Layout.bottomMargin: 16
                }

                M.SystemIcon {
                    source: "icons/vendor.png"
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 14
                }

                VendorComboBox {
                    id: vendorBox
                    Layout.minimumWidth: 300
                    enabled: !helper.running
                    onActivated: helper.vendor = currentVendor
                }
            }
        }

        // Second page
        Item {
            SwipeView.onIsCurrentItemChanged: {
                if (SwipeView.isCurrentItem) {
                    helper.open(filenameField.text)
                    helper.running = true
                }
            }

            ColumnLayout {
                spacing: 24
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                M.Label {
                    type: "Body 1"
                    text: helper.message
                    Layout.alignment: Qt.AlignHCenter
                }

                ProgressBar {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    indeterminate: !helper.canImport && helper.running
                    from: 0
                    to: helper.objectsInFile
                    value: helper.canImport ? helper.objectsInFile : 0
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 32
                    enabled: helper.canImport
                    Layout.alignment: Qt.AlignHCenter
                    opacity: helper.canImport ? 1 : 0
                    Behavior on opacity { NumberAnimation {duration: 300} }

                    M.Label {
                        type: "Body 2"
                        text: "Options"
                        opacity: Material.theme === Material.Light ? 0.54 : 0.70
                        Layout.columnSpan: 2
                        Layout.bottomMargin: 16
                    }

                    M.SystemIcon {
                        source: "icons/add_tag.png"
                    }

                    M.ChipEditor {
                        id: chipEditor
                        Layout.fillWidth: true
                        onModelChanged: helper.tags = model
                    }

                    M.SystemIcon {
                        source: "icons/double_check.png"
                    }

                    ComboBox {
                        model: ["None", "Manual", "Automatic"]
                        currentIndex: 1
                        onActivated: validatorPanel.setValidationLevel(model[index])
                    }
                }
            }
        }

        // Third page
        Item {
            SwipeView.onIsCurrentItemChanged: {
                if (SwipeView.isCurrentItem) {
                    helper.running = true
                }
            }

            ColumnLayout {
                spacing: 0
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    M.Label {
                        type: "Body 2"
                        text: helper.complete ? helper.objectsInFile + " objects imported." : helper.currentProduct !== undefined ? helper.currentProduct.title : ""
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    M.LinkLabel {
                        type: "Caption"
                        visible: helper.currentProduct !== undefined && !helper.complete
                        text: helper.currentProduct !== undefined ? helper.currentProduct.detailPageUrl : "n/a"
                        link: helper.currentProduct !== undefined ? helper.currentProduct.detailPageUrl : ""
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        textFormat: Text.StyledText
                        linkColor: Material.foreground
                        onLinkActivated: Qt.openUrlExternally(link)
                        font.underline: true
                    }
                }

                ProgressBar {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    from: 0
                    to: helper.objectsInFile
                    value: helper.currentIndex + 1
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 24
                    opacity: helper.running ? 0 : 1.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }

                    ProductValidatorPanel {
                        id: validatorPanel
                        product: helper.currentProduct
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 16
                        text: "Apply"
                        onClicked: {
                            validatorPanel.apply()
                            database.saveObject(helper.currentProduct)
                            helper.running = true
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        count: view.count
        visible: !helper.complete
        currentIndex: view.currentIndex
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: buttonLayout.verticalCenter
        }
    }

    RowLayout {
        id: buttonLayout
        spacing: 8
        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        Button {
            id: prevButton
            text: "Previous"
            flat: true
            enabled: view.currentIndex > 0
            visible: !helper.complete
            onClicked: view.decrementCurrentIndex()
        }
        Button {
            id: nextButton
            visible: !helper.complete
            text: view.currentIndex == 1 ? "Import" : "Next"
            flat: true
            enabled: view.currentIndex == 0 ? filenameField.text && vendorBox.currentIndex : view.currentIndex == 1 ?  helper.canImport : false
            onClicked: view.incrementCurrentIndex()
        }
        Button {
            id: dismissButton
            text: helper.complete && view.currentIndex === 2 ? "Ok" : "Cancel"
            flat: true
            onClicked: text === "Ok" ? dialog.reset() : dialog.reject()
        }
    }
}
