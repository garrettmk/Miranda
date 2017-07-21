import QtQuick 2.7
import QtQuick.Controls.Material 2.1


Rectangle {
    id: background
    radius: 2
    color: "white"

    property string source

    Image {
        id: image
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width)
        height: Math.min(implicitHeight, parent.height)
        source: background.source
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    SystemIcon {
        Material.theme: Material.Light
        source: "../icons/unavailable_black.png"
        anchors.centerIn: parent
        visible: image.status !== Image.Ready
    }
}
