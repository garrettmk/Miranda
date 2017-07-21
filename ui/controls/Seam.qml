import QtQuick 2.7
import QtQuick.Controls.Material 2.1


Item {
    id: root
    implicitWidth: 2

    Row {
        spacing: 0
        anchors.fill: parent

        Rectangle {
            height: parent.height
            color: "black"
            opacity: 0.12
            width: 1
        }

        Rectangle {
            height: parent.height
            color: "white"
            opacity: 0.12
            width: 1
        }
    }
}
