import QtQuick 2.7
import QtQuick.Controls 2.1

ToolButton {
    text: "      "
    property string iconSource

    SystemIcon {
        anchors.centerIn: parent
        source: iconSource
    }
}
