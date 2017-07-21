import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


Rectangle {
    id: background
    height: 48
    color: "transparent"
    state: "ActiveUnfocused"

    property string iconSource
    property string text

    signal clicked()

    states: [
        State {
            name: "ActiveUnfocused"
            PropertyChanges {
                target: background
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
            }
            PropertyChanges {
                target: textLabel
                color: Material.foreground
                opacity: 0.87
            }
        },
        State {
            name: "ActiveFocused"
            PropertyChanges {
                target: background
                opacity: Material.theme === Material.Light ? 0.87 : 1.0
                color: Material.theme === Material.Light ? "#0C000000" : "#0CFFFFFF"
            }
            PropertyChanges {
                target: textLabel
                color: Material.theme === Material.light ? Material.primary : Material.foreground
                opacity: 1.0
            }
        },
        State {
            name: "Inactive"
            PropertyChanges {
                target: background
                opacity: Material.theme === Material.Light ? 0.38 : 0.50
            }
            PropertyChanges {
                target: textLabel
                color: Material.foreground
                opacity: 0.54
            }
        }
    ]

    MouseArea {
        id: mouseArea
        enabled: background.state !== "Inactive"
        anchors.fill: parent
        hoverEnabled: true

        onContainsMouseChanged: {
            if (containsMouse) {
                background.color = Material.theme === Material.Light ? "#0C000000" : "#0CFFFFFF"
            } else if (background.state !== "ActiveFocused") {
                background.color = "transparent"
            }
        }

        onClicked: background.clicked()
    }


    SystemIcon {
        anchors {
            left: parent.left
            leftMargin: 16
            verticalCenter: parent.verticalCenter
        }
        source: iconSource
        state: background.state
    }

    Label {
        id: textLabel
        text: background.text
        anchors {
            left: parent.left
            leftMargin: 72
            right: parent.right
            rightMargin: 16
            verticalCenter: parent.verticalCenter
        }

        elide: Text.ElideRight
        font.pointSize: 14
        font.weight: Font.DemiBold
        opacity: 0.87
    }
}
