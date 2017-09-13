import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


Rectangle {
    id: background
    radius: 2
    color: "white"

    property alias source: image.source
    property int padding: 8

    Material.theme: Material.Light

    Image {
        id: image
        asynchronous: true
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width - padding)
        height: Math.min(implicitHeight, parent.height - padding)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: image.status === Image.Loading
    }

    SystemIcon {
        Material.theme: Material.Light
        source: "../icons/unavailable_black.png"
        anchors.centerIn: parent
        visible: image.status === Image.Null || image.status === Image.Error
    }
}
