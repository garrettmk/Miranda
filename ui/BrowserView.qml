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

    // Components provided by subclasses
    property Item queryBuilder
    property Item comparisonTool
    property alias cardDelegate: cardList.delegate

    // Components exposed to users/subclasses
    property ObjectModel model
    property alias cardListView: cardList

    // Used internally
    property int increment: width / 12
    property ObjectModel queryModel: database.getModel(queryBuilder.queryQuery)

    // Signals
    signal newItemClicked()

    // Methods
    Component.onCompleted: {
        if (queryBuilder !== null) {
            queryBuilder.parent = queryBuilderHolder
            queryBuilder.anchors.fill = queryBuilderHolder
        }

        if (comparisonTool !== null) {
            comparisonTool.parent = compToolHolder
            comparisonTool.anchors.fill = compToolHolder
        }

        queryModel.insert(0, queryBuilder.query)
        queryBox.currentIndex = 0
        searchButton.onClicked()
    }

    // Dialogs
    Dialog {
        id: saveQueryDialog
        title: "Save Query"
        standardButtons: Dialog.Save | Dialog.Cancel

        width: 300
        x: ApplicationWindow.window.width / 2 - width / 2
        y: ApplicationWindow.window.height / 2 - height / 2

        RowLayout {
            anchors.fill: parent
            spacing: 24

            M.SystemIcon {
                source: "icons/title.png"
            }

            M.TextField {
                id: queryNameField
                Layout.fillWidth: true
                labelText: "Title"
            }
        }

        onAccepted: {
            queryBuilder.query.name = queryNameField.text
            database.saveObject(queryBuilder.query)
        }
    }

    // Toolbar
    ToolBar {
        id: toolBar
        z: 10
        implicitHeight: 128
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        RowLayout {
            width: cardList.x - anchors.leftMargin - 24
            anchors {
                left: parent.left
                leftMargin: 48
                bottom: parent.bottom
            }

            ComboBox {
                id: queryBox
                model: queryModel
                textRole: "name"
                background: Rectangle {color: "transparent"}
                Layout.fillWidth: true
                onActivated: {
                    queryBuilder.query = queryModel.getObject(index)
                    searchButton.onClicked()
                }
            }

            M.IconToolButton {
                id: searchButton
                iconSource: "../icons/search.png"
                onClicked: model = database.getModel(queryBuilder.query)
            }

            M.IconToolButton {
                iconSource: "../icons/dots_vertical.png"
                onClicked: queryMenu.open()

                Menu {
                    id: queryMenu

                    MenuItem {
                        id: newQueryMenuItem
                        text: "New..."
                        onTriggered: {
                            queryBuilder.newQuery()
                            queryModel.append(queryBuilder.query)
                            queryBox.currentIndex = queryModel.length - 1
                        }
                    }

                    MenuItem {
                        text: queryBuilder.query.hasId ? "Save" : "Save As..."
                        enabled: queryBox.currentIndex > 0
                        onTriggered: {
                            if (queryBuilder.query.hasId) {
                                database.saveObject(queryBuilder.query)
                            } else {
                                saveQueryDialog.open()
                            }
                        }
                    }

                    MenuItem {
                        text: "Delete"
                        enabled: queryBox.currentIndex > 0
                        onTriggered: {
                            var idx = queryBox.currentIndex
                            if (idx > 0) {
                                database.deleteObject(queryBuilder.query)
                                queryModel.removeRow(idx)
                                queryBox.currentIndex = idx - 1
                                queryBox.onActivated(idx - 1)
                            }
                        }
                    }
                }
            }
        }
    }

    // Title
    M.Label {
        id: titleLabel
        z: 30
        type: "Display 1"
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 24
            topMargin: 24
        }
    }

    // Query builder
    Item {
        id: queryBuilderHolder
        width: increment * 3
        anchors {
            left: parent.left
            top: toolBar.bottom
            bottom: parent.bottom
            leftMargin: 48
            topMargin: 48
        }

        // queryBuilder gets parented here
    }

    // Result cards
    ListView {
        id: cardList
        z: 20
        model: root.model
        width: increment * 4
        spacing: 24
        displayMarginBeginning: 500
        displayMarginEnd: 500
        anchors {
            top: parent.top
            left: queryBuilderHolder.right
            bottom: parent.bottom
            topMargin: 56
            leftMargin: 48
            bottomMargin: 300
        }
    }

    // New item FAB
    M.FloatingActionButton {
        z: 20
        iconSource: "icons/add.png"
        anchors {
            verticalCenter: toolBar.bottom
            left: cardList.right
            leftMargin: 24
        }
        onClicked: newItemClicked()
    }

    // Comparison tool
    Item {
        id: compToolHolder
        anchors {
            left: cardList.right
            right: parent.right
            top: toolBar.bottom
            bottom: parent.bottom
            topMargin: 48
            bottomMargin: 48
            rightMargin: 48
            leftMargin: 48
        }
    }
}
