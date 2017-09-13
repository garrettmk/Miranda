import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectModel 1.0
import ObjectQuery 1.0
import QueryQueryDocument 1.0


M.CenteredModalDialog {
    id: root
    title: "Search"
    standardButtons: Dialog.Ok | Dialog.Cancel

    property string onlyShow

    property ObjectQuery queryQuery: ObjectQuery {
        objectType: "ObjectQuery"
        query: QueryQueryDocument {}
    }

    property ObjectQuery currentQuery
    property var _currentBuilder: builderStack.children[builderStack.currentIndex]

    onCurrentQueryChanged: { _currentBuilder.show(currentQuery); queryNameField.text = currentQuery.name }
    onAccepted: _currentBuilder.applyTo(currentQuery)

    Component.onCompleted: {
        if (onlyShow) {
            typeBox.currentIndex = typeBox.model.indexOf(onlyShow)
        }
        loadSavedQueries()
    }

    function loadSavedQueries() {
        var kind
        var idx = typeBox.currentIndex

        if (idx === 0)
            kind = "Product"
        else if (idx === 1)
            kind = "Vendor"
        else if (idx === 2)
            kind = "ProfitRelationship"
        else if (idx === 3)
            kind = "Operation"

        queryQuery.query.objectType = kind

        var oldModel = savedList.model
        savedList.model = database.getParentedModel(queryQuery, savedList)
        if (oldModel !== undefined && oldModel !== null)
            oldModel.destroy()

        if (savedList.model.length)
            savedList.currentIndex = 0
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 32

        ColumnLayout {
            spacing: 0
            Layout.fillHeight: true
            Layout.preferredWidth: 400

            M.Label {
                visible: typeBox.visible
                type: "Subheading"
                text: "Object Type"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
            }

            ComboBox {
                id: typeBox
                model: ["Products", "Vendors", "Opportunities", "Operations"]
                Layout.fillWidth: true
                Layout.topMargin: 20
                onActivated: loadSavedQueries()
            }

            M.Label {
                type: "Subheading"
                text: "Saved Queries"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.topMargin: typeBox.visible ? 48 : 0
            }

            M.Divider {
                Layout.fillWidth: true
                Layout.topMargin: 24
            }

            ListView {
                id: savedList
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                onCurrentIndexChanged: currentIndex > -1 ? root.currentQuery = savedList.model.getObject(currentIndex) : null

                delegate: Item {
                    width: parent.width
                    height: 48

                    Rectangle {
                        anchors.fill: parent
                        color: Material.theme === Material.Light ? "black" : "white"
                        opacity: savedList.currentIndex === index ? 0.12 : delegateMouseArea.containsMouse ? 0.08 : 0
                        Behavior on opacity { OpacityAnimator { duration: 100 } }
                    }

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: savedList.currentIndex = index
                    }

                    M.Label {
                        type: "Body 1"
                        text: name
                        anchors {
                            left: parent.left
                            leftMargin: 32
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    M.Divider {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                    }
                }
            }

            M.Divider {
                Layout.fillWidth: true
                Layout.topMargin: 8
            }

            RowLayout {
                Layout.topMargin: 16
                Layout.fillWidth: true
                spacing: 8

                Button {
                    text: "New"
                    flat: true
                    onClicked: {
                        var typeIdx = typeBox.currentIndex
                        var q

                        if (typeIdx === 0)
                            q = database.newProductQuery()
                        else if (typeIdx === 1)
                            q = database.newVendorQuery()
                        else if (typeIdx === 2)
                            q = database.newOpportunityQuery()
                        else if (typeIdx === 3)
                            q = database.newOperationQuery()

                        savedList.model.append(q)
                        savedList.currentIndex = savedList.model.length - 1
                        queryNameField.focus = true
                    }
                }

                Button {
                    text: "Save"
                    flat: true
                    enabled: currentQuery !== null && currentQuery !== undefined
                    onClicked: { _currentBuilder.applyTo(currentQuery); database.saveObject(currentQuery) }
                }

                Button {
                    text: "Delete"
                    flat: true
                    enabled: currentQuery !== null && currentQuery !== undefined
                    onClicked: {
                        var row = savedList.currentIndex
                        database.deleteObject(currentQuery)
                        savedList.model.removeRow(row)
                        savedList.currentIndex = -1
                    }
                }
            }

        }

        M.Divider {
            orientation: Qt.Vertical
            Layout.fillHeight: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            M.Label {
                type: "Subheading"
                text: "Query Properties"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                M.SystemIcon {
                    source: "icons/save.png"
                    Layout.topMargin: 30
                }

                M.TextField {
                    id: queryNameField
                    enabled: currentQuery !== null
                    labelText: "Query name"
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                    onAccepted: currentQuery.name = text
                }
            }


            StackLayout {
                id: builderStack
                currentIndex: typeBox.currentIndex
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 24

                property var builders: ["Product", "Vendor", "ProfitRelationship", "Operation"]

                ProductQueryBuilder {}
                VendorQueryBuilder {}
                OpportunityQueryBuilder {}
                OperationQueryBuilder {}
            }

        }


    }

}
