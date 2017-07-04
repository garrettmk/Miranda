import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import cupi.ui 1.0 as QP
import "controls" as M


Dialog {
    id: dialog
    title: "Import Product Data"
    standardButtons: Dialog.Ok | Dialog.Cancel

    GridLayout {
        anchors.centerIn: parent
        columns: 2

        Label {
            Layout.alignment: Qt.AlignRight
            text: "File:"
        }
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: filenameField
                Layout.fillWidth: true
                Layout.minimumWidth: 300
            }
            ToolButton {
                text: "..."
            }
        }

        Label {
            Layout.alignment: Qt.AlignRight
            text: "Vendor:"
        }
        ComboBox {
            id: vendorBox
            model: ["Tom's Hardware", "Ace's Spades", "Dewie, Cheatum & Howe"]
        }

        Label {
            Layout.alignment: Qt.AlignRight
            text: "Tag imports:"
        }

        M.TagEditor {
            Layout.fillWidth: true
        }

    }


}
