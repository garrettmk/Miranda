import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import MapObject 1.0


ObjectCard {
    id: card

    mediaItem: Rectangle {
        id: mediaItem
        anchors.fill: parent
        color: Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)

        state: "Locked"
        states: [
            State {
                name: "Locked"
                PropertyChanges {
                    target: mediaFlickable
                    interactive: false
                    contentWidth: width
                    contentHeight: height
                    contentX: 0
                    contentY: 0
                }
            },
            State {
                name: "Unlocked"
                PropertyChanges {
                    target: mediaFlickable
                    interactive: true
                    contentWidth: documentText.implicitWidth
                    contentHeight: documentText.implicitHeight
                }
            }
        ]

        Flickable {
            id: mediaFlickable
            interactive: false
            anchors.fill: parent
            anchors.margins: 48
            rightMargin: 48

            Label {
                id: documentText
                anchors.fill: parent
                text: currentDocumentText
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                font {
                    family: "Courier"
                }
            }
        }

        M.IconToolButton {
            iconSource: mediaItem.state === "Locked" ? "../icons/lock_closed.png" : "../icons/lock_open.png"
            onClicked: mediaItem.state === "Locked" ? mediaItem.state = "Unlocked" : mediaItem.state = "Locked"
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
        }

        Connections {
            target: card.ListView.view
            onMovingVerticallyChanged: if (card.ListView.view.movingVertically) mediaItem.state = "Locked"
        }
    }

    headlineItem: ColumnLayout {
        M.Label {
            type: "Headline"
            text: id
        }
        M.Label {
            type: "Body 2"
            text: pythonClassName
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
        }
    }
}
