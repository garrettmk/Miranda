import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Rectangle {
    color: Material.theme === Material.Light ? "black" : "white"
    opacity: 0.12

    property int orientation: Qt.Horizontal

    Component.onCompleted: {
        if (orientation === Qt.Horizontal) {
            height = 1
        } else {
            width = 1
        }
    }
}
