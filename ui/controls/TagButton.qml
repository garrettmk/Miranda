import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3

ToolButton {
    id: control
    font.capitalization: Font.MixedCase

    background: Rectangle {
        implicitHeight: font.pixelSize + 10
        id: bgRect
        color: Qt.lighter(Material.background)
        radius: 3
        layer.enabled: true
        layer.effect: DropShadow {
            samples: 7
            radius: 3
            verticalOffset: 2
            color: Qt.rgba(0, 0, 0, 0.3)
        }
    }

    contentItem: Row {
        id: contentsRow
        spacing: 5
        Label {
            id: closeButton
            text: "✕"
            font.pointSize: control.font.pointSize - 2
            color: Material.foreground
            opacity: closeMouseArea.containsMouse ? 0.75 : 0.25
            Behavior on opacity {NumberAnimation {duration: 100; easing.type: Easing.Linear}}

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        Label {
            id: label
            text: control.text
            font: control.font
            color: Material.foreground
        }
    }
}
