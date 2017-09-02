import QtQuick 2.7
import "." as M


M.TextField {
    id: root
    suffix: M.Label {
        type: "Body 1"
        text: "%"
        color: root.background.color
        opacity: root.activeFocus ? 1.0 : 0.5
        Behavior on opacity { OpacityAnimator { duration: 100 } }
    }
    validator: DoubleValidator {}
    horizontalAlignment: TextInput.AlignRight
}
