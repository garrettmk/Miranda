import QtQuick 2.7
import QtQuick.Controls 2.1

ToolButton {
    id: root
    text: "      "
    property string iconSource

    SystemIcon {
        anchors.centerIn: parent
        source: iconSource
        state: root.pressed ? "ActiveFocused" : root.enabled ? "ActiveUnfocused" : "Inactive"
    }
}
