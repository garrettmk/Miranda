import QtQuick 2.7
import QtQuick.Controls 2.1

ToolButton {
    text: "      "
    property string iconSource
    Image {
        anchors {
            fill: parent
            margins: 10
        }
        source: iconSource
    }
}
