import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


Pane {
    id: card
    padding: 0
    Material.elevation: raised ? 8 : 2

    property bool raised: false
    property alias color: bgrect.color
    property color borderColor: Material.theme === Material.Light ? "transparent" : "#25FFFFFF"

    Behavior on Material.elevation {
        NumberAnimation {
            duration: 150
            easing.type: Easing.InOutQuart
        }
    }

    default property alias content: bgrect.children

    Rectangle {
        id: bgrect
        anchors.fill: parent
        radius: 2
        color: Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)
        border {
            width: color === "transparent" ? 0 : 1
            color: borderColor
        }
    }
}
