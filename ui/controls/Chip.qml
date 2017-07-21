import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M


Item {
    id: root
    implicitHeight: 32
    implicitWidth: layout.implicitWidth

    property bool readOnly: false
    property alias text: label.text

    signal deleted()

    Rectangle {
        id: background
        color: Material.theme === Material.Light ? "black" : "white"
        opacity: 0.12
        anchors.fill: parent
        radius: height / 2
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        M.Label {
            id: label
            type: "Chip"
            Layout.leftMargin: 12
            Layout.rightMargin: readOnly ? 12 : 0
            Layout.alignment: Qt.AlignVCenter
        }

        Button {
            id: deleteButton
            visible: !readOnly
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 4
            Layout.rightMargin: 4

            implicitHeight: 24
            implicitWidth: 24

            hoverEnabled: true
            background: SystemIcon {
                anchors.fill: parent
                source: "../icons/delete.png"
                state: deleteButton.pressed ? "ActiveFocused" : deleteButton.hovered ? "ActiveUnfocused" : "Inactive"
            }

            onClicked: root.deleted()
        }
    }
}
