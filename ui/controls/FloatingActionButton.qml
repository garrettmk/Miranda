import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


RoundButton {
    id: button
    radius: 28
    width: 56
    height: 56
    Material.elevation: 12

    property alias iconSource: icon.source

    SystemIcon {
        id: icon
        anchors.centerIn: parent
    }

    Component.onCompleted: background.color = Material.accent
}
