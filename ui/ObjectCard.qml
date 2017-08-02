import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M


M.Card {
    id: card
    width: parent !== null ? parent.width : layout.implicitWidth
    contentHeight: layout.implicitHeight
    color: Material.primary
    borderColor: "transparent"
    raised: selected

    property alias selected: selectButton.checked

    signal selectButtonClicked()

    // Components provided by subclasses
    property alias mediaItem: mediaItemHolder.children
    property alias headlineItem: headlineItemHolder.children
    property alias actionItem: actionItemHolder.children
    property QtObject actionMenu

    Component.onCompleted: {
        if (actionMenu !== null) {
            actionMenu.parent = actionMenuButton
        }
    }

    // Body
    ColumnLayout {
        id: layout
        spacing: 0
        anchors {
            fill: parent
            margins: 0
        }

        // Media item
        Item {
            id: mediaItemHolder
            clip: true
            Layout.fillWidth: true
            Layout.preferredHeight: width / (16/9)

            // Media item gets parented here
        }

        // Headline item
        Item {
            id: headlineItemHolder
            implicitHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height
            Layout.fillWidth: true
            Layout.topMargin: 24
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16

            // Headline item gets parented here
        }

        // Action area
        RowLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.margins: 8

            CheckBox {
                id: selectButton
                onClicked: selectButtonClicked()
            }

            Item {
                id: actionItemHolder
                Layout.fillWidth: true
                implicitHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height
            }

            M.IconToolButton {
                id: actionMenuButton
                visible: actionMenu !== null
                iconSource: "../icons/dots_vertical.png"
                onClicked: actionMenu.open()
            }
        }
    }

}
