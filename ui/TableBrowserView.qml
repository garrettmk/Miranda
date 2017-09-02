import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import ObjectQuery 1.0


Item {
    id: root

    // Properties
    property alias title: titleLabel.text
    property alias columns: table.columns
    property color mainToolBarColor
    property color sideToolBarColor
    property color addNewButtonColor

    property var currentObject: table.currentIndex > -1 && model !== null ? model.getObject(table.currentIndex) : null

    // Components provided by subclasses
    property alias mainToolButtons: mainToolButtonsHolder.children
    property alias tableRowDelegate: table.delegate
    property Item sidePanel
    property Item sideToolBar
    property var actionOnSelectedMenu

    // Components exposed to subclasses
    property ObjectModel model
    property alias table: table
    property alias addNewButton: addNewButton
    property alias addNewButtonVisible: addNewButton.visible
    signal addNewButtonClicked()
    property alias queryDialog: queryDialog

    // Used internally
    property int _increment: width / 12

    // Methods
    Component.onCompleted: {
        if (sidePanel !== null) {
            sidePanel.parent = sidePanelHolder
        }

        if (sideToolBar !== null) {
            sideToolBar.parent = _sideToolBar
            sideToolBar.anchors.fill = _sideToolBar
        }
    }

    // Dialogs
    QueryDialog {
        id: queryDialog
        onAccepted: {
            if (model !== null && model !== undefined)
                model.setParent(undefined)

            console.log(currentQuery)
            model = database.getModel(currentQuery)
            model.setParent(root)
            queryNameLabel.text = currentQuery.name
        }
    }

    // Body
    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            clip: true
            Layout.fillHeight: true
            Layout.preferredWidth: 8 * _increment

            // Main toolbar
            ToolBar {
                id: mainToolBar
                z: 20
                implicitHeight: 128
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                Material.primary: mainToolBarColor !== null ? mainToolBarColor : Material.primary

                // Top buttons
                RowLayout {
                    spacing: 8
                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 8
                    }

                    M.IconToolButton {
                        iconSource: "../icons/search.png"
                        onClicked: queryDialog.open()
                    }

                    Item {
                        id: mainToolButtonsHolder
                        implicitWidth: children.length ? children[0].implicitWidth : 0
                        implicitHeight: children.length ? children[0].implicitHeight : 0
                    }
                }

                // Title
                RowLayout {
                    spacing: 8
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        leftMargin: 92
                        bottomMargin: 24
                    }

                    M.Label {
                        id: titleLabel
                        type: "Display 1"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    M.SystemIcon {
                        source: "icons/arrow_right.png"
                        visible: queryNameLabel.text
                        Layout.alignment: Qt.AlignVCenter
                        sourceSize {
                            width: 48
                            height: 48
                        }
                    }

                    M.Label {
                        id: queryNameLabel
                        type: "Display 1"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            M.FloatingActionButton {
                z: 30
                id: addNewButton
                iconSource: "icons/add.png"
                Material.primary: addNewButtonColor !== null ? addNewButtonColor : Material.accent
                anchors {
                    right: parent.right
                    rightMargin: 24
                    verticalCenter: mainToolBar.bottom
                }
                onClicked: root.addNewButtonClicked()
            }

            // Table
            ListView {
                id: table
                model: root.model
                anchors {
                    top: mainToolBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                property bool selectAll: false
                property var selectedIndices: []
                property var columns: []

                // Table header
                headerPositioning: ListView.OverlayHeader
                header: Rectangle {
                    z: 10
                    color: Material.background
                    width: parent.width
                    height: 64
                    implicitWidth: headerLayout.implicitWidth + 80 + 24
                    Component.onCompleted: table.implicitWidth = implicitWidth

                    property alias actionButton: actionOnSelectedButton

                    RowLayout {
                        id: headerLayout
                        spacing: 0
                        anchors {
                            left: parent.left
                            leftMargin: 24
                            rightMargin: 24
                            verticalCenter: parent.verticalCenter
                        }

                        M.IconToolButton {
                            id: actionOnSelectedButton
                            iconSource: "../icons/dots_horizontal.png"
                            enabled: table.selectedIndices.length && root.actionOnSelectedMenu !== null
                            onClicked: {
                                if (root.actionOnSelectedMenu !== null) {
                                    root.actionOnSelectedMenu.x = mapToGlobal(0, 0).x
                                    root.actionOnSelectedMenu.y = mapToGlobal(0, 0).y
                                    root.actionOnSelectedMenu.open()
                                }
                            }
                        }

                        Repeater {
                            model: table.columns
                            delegate: M.Label {
                                type: "Column Header"
                                text: modelData.name
                                elide: Text.ElideRight
                                Layout.preferredWidth: modelData.width
                                Layout.leftMargin: index === 0 ? 20 : index < 2 ? 24 : 56
                                horizontalAlignment: "alignment" in modelData ? modelData["alignment"] : Qt.AlignLeft
                            }
                        }
                    }

                    M.Divider {
                        width: parent.width
                        anchors.bottom: parent.bottom
                    }
                }
            }

            M.RightSeam {
                anchors {
                    top: parent.top
                    left: parent.right
                    bottom: parent.bottom
                }
            }
        }

        // Side pane
        ColumnLayout {
            clip: true
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            ToolBar {
                id: _sideToolBar
                z: 20
                Layout.fillWidth: true
                Layout.preferredHeight: mainToolBar.height
                Material.primary: sideToolBarColor !== null ? sideToolBarColor : Material.primary
            }

            Item {
                id: sidePanelHolder
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Side panel gets parented here
            }
        }
    }
}
