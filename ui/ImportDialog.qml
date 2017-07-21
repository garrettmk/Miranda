import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Vendor 1.0


Dialog {
    id: dialog
    modal: true
    title: "Import Products"
    standardButtons: Dialog.Ok | Dialog.Cancel

    x: ApplicationWindow.window.width / 2 - width / 2
    y: ApplicationWindow.window.height / 2 - height / 2

    property alias vendor: vendorBox.currentVendor

    GridLayout {
        anchors {
            fill: parent
        }
        columns: 2
        columnSpacing: 32
        rowSpacing: 24

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
                Layout.fillWidth: true
                Layout.minimumWidth: 300
            }
            Button {
                text: "..."
                flat: true
                Layout.preferredWidth: height
                Layout.topMargin: 16
            }
        }

        M.SystemIcon {
            source: "icons/vendor.png"
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 30
        }

        VendorComboBox {
            id: vendorBox
            Layout.fillWidth: true
            Layout.topMargin: 16
        }

        M.SystemIcon {
            source: "icons/add_tag.png"
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 4
        }

        M.ChipEditor {
            Layout.fillWidth: true
        }

    }
}
