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
    property var _currentBuilder

    onCurrentQueryChanged: { console.log(currentQuery); _currentBuilder.show(currentQuery) }

    onAccepted: _currentBuilder.applyTo(currentQuery)

    Component.onCompleted: {
        var idx
        if (onlyShow) {
            idx = typeBox.model.indexOf(onlyShow)
            typeBox.visible = false
        } else
            idx = 0

        typeBox.currentIndex = idx
//        loadSavedQueries()
//        savedList.currentIndex = 0
    }

    function loadSavedQueries() {
        console.log("loadSavedQueries")
        var ot
        var idx = typeBox.currentIndex

        if (idx === 0)
            ot = "Product"
        else if (idx === 1)
            ot = "Vendor"
        else if (idx === 2)
            ot = "ProfitRelationship"
        else if (idx === 3)
            ot = "Operation"

        console.log(ot)
        queryQuery.query.objectType = ot

        var oldModel = savedList.model
        console.log("oldModel: " + oldModel)
        if (oldModel !== undefined && oldModel !== null)
            oldModel.destroy()

        console.log("getting query model")
        savedList.model = database.getModel(queryQuery)
        savedList.model.setParent(savedList)

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

                onCurrentIndexChanged: {
                    console.log(currentIndex, model)
                    if (savedList.currentIndex > -1) {
                        console.log("Getting object...")
                        root.currentQuery = model.getObject(currentIndex)
                    } else
                        root.currentQuery = null
                }

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
                    }
                }

                Button {
                    text: "Save"
                    flat: true
                    enabled: currentQuery !== null && currentQuery !== undefined
                    onClicked: database.saveObject(currentQuery)
                }

                Button {
                    text: "Delete"
                    flat: true
                    enabled: currentQuery !== null && currentQuery !== undefined
                    onClicked: {
                        var row = savedList.currentIndex
                        database.deleteObject(currentQuery)
                        savedList.model.removeRow(row)
                        savedList.currentIndex -= 1
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
                    text: enabled ? currentQuery.name : "n/a"
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                    onEditingFinished: {
                        if (text)
                            currentQuery.name = text
                        text = Qt.binding(function () {if (currentQuery !== null) return currentQuery.name; else return "n/a"})
                    }
                }
            }


            StackLayout {
                id: builderStack
                currentIndex: typeBox.currentIndex
                onCurrentIndexChanged: root._currentBuilder = children[currentIndex]
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
