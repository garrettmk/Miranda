import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import "controls" as M


M.CenteredModalDialog {
    id: root
    title: "Edit Tags"
    standardButtons: Dialog.Ok | Dialog.Cancel

    contentWidth: 450
    contentHeight: layout.implicitHeight
    padding: 24

    property alias adding: addRemoveBox.currentIndex
    property alias tags: chipEditor.model

    GridLayout {
        id: layout
        columns: 2
        columnSpacing: 32
        rowSpacing: 30
        anchors.fill: parent

        M.SystemIcon {
            source: "icons/edit.png"
        }

        ComboBox {
            id: addRemoveBox
            model: ["Remove", "Add"]
            currentIndex: 0
        }

        M.SystemIcon {
            source: "icons/tag.png"
        }

        M.ChipEditor {
            id: chipEditor
            Layout.fillWidth: true
        }
    }
}
