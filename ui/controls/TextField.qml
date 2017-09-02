import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


TextField {
    id: root
    hoverEnabled: true
    bottomPadding: 8
    topPadding: labelText ? 8 + 10 + 16 : 16

    property Item prefix
    property Item suffix
    property alias labelText: label.text
    property string helperText

    Component.onCompleted: {
        if (prefix !== null) {
            prefix.parent = root
            prefix.anchors.left = root.left
            prefix.anchors.bottom = root.bottom
            prefix.anchors.bottomMargin = bottomPadding
            leftPadding = prefix.width + 16

            label.anchors.leftMargin = leftPadding
        }

        if (suffix !== null) {
            suffix.parent = root
            suffix.anchors.right = root.right
            suffix.anchors.bottom = root.bottom
            suffix.anchors.bottomMargin = bottomPadding
            rightPadding = suffix.width + 16

            label.anchors.rightMargin = rightPadding
        }
    }

    state: acceptableInput ? "Valid" : "Invalid"
    states: [
        State {
            name: "Valid"
            PropertyChanges {
                target: backgroundRect
                color: root.activeFocus ? Material.accent : Material.foreground
            }
            PropertyChanges {
                target: label
                color: root.activeFocus ? Material.accent : Material.foreground
            }
        },
        State {
            name: "Invalid"
            PropertyChanges {
                target: backgroundRect
                color: Material.color(Material.Red, Material.Shade500)
            }
            PropertyChanges {
                target: label
                color: Material.color(Material.Red, Material.Shade500)
            }
        }
    ]

    background: Rectangle {
        id: backgroundRect
        implicitWidth: 100
        height: root.activeFocus || root.hovered ? 2 : 1
        color: root.activeFocus ? Material.accent : Material.foreground
        opacity: root.activeFocus ? 1.0 : 0.38
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on opacity { OpacityAnimator { duration: 100 } }

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }


    Label {
        id: label
        elide: Text.ElideRight
        color: root.activeFocus ? Material.accent : Material.foreground
        opacity: root.activeFocus ? 1 : 0.5
        Behavior on opacity { OpacityAnimator { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 100 } }
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        // Properties
        property string placeholder: ""         // A temporary placeholder for root.placeholderText

        // Smooth the transition between active and inactive states
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }

        state: root.activeFocus || root.text ? "Floating" : "Resting"
        states: [
            State {
                name: "Resting"
                PropertyChanges {
                    target: label
                    anchors.bottomMargin: root.bottomPadding
                    anchors.leftMargin: root.leftPadding
                    font.pixelSize: root.font.pixelSize
                }
            },
            State {
                name: "Floating"
                PropertyChanges {
                    target: label
                    anchors.bottomMargin: root.bottomPadding + root.contentHeight + 4
                    anchors.leftMargin: 0
                    font.pixelSize: 10
                }
            }
        ]

        // Disable the placeholder text when the label is resting
        onStateChanged: {
            if (state === "Resting") {
                label.placeholder = root.placeholderText
                root.placeholderText = ""
            } else {
                root.placeholderText = label.placeholder
            }
        }
    }

}
