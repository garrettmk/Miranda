import QtQuick 2.7
import QtQuick.Controls 2.1

Button {
    id: control
    implicitWidth: 18
    implicitHeight: 18
    hoverEnabled: true
    background: SystemIcon {
        anchors.fill: parent
        source: "../icons/minus.png"
        state: control.pressed ? "ActiveFocused" : control.hovered ? "ActiveUnfocused" : "Inactive"
    }
}
