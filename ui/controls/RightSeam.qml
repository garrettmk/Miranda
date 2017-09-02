import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


Item {
    id: root
    width: 2

    Rectangle {
        color: "white"
        opacity: 0.12
        width: 1
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.left
        }
    }

    Rectangle {
        color: "black"
        opacity: 0.12
        width: 1
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.right
        }
    }
}
