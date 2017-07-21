import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M

ListView {
    id: root
    clip: true

    property string title: "Object Table"
    property var columns: []
    property Item headerTools
    property color headerBackgroundColor: Material.background

    signal rowsRemoved()
    signal rowClicked(int index)

    // Header
    headerPositioning: ListView.OverlayHeader
    header: Rectangle {
        id: headerBackground
        z: 10
        width: parent.width
        color: headerBackgroundColor
        height: 64 + 56

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Title
            RowLayout {
                id: headerLayout
                height: 64
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                Component.onCompleted: {
                    if (root.headerTools !== null) {
                        root.headerTools.parent = headerLayout
                        root.headerTools.Layout.rightMargin = 14
                    }
                }

                M.Label {
                    type: "Headline"
                    text: root.title
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 24
                }

                Item {Layout.fillWidth: true}
            }

            // Column headers
            RowLayout {
                height: 56
                spacing: 0
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 24

                MinusButton {
                    enabled: model.length > 0
                    onClicked: {
                        root.model.clear()
                        rowsRemoved()
                    }
                }

                Repeater {
                    model: root.columns
                    delegate: M.Label {
                        type: "Column Header"
                        text: modelData.name
                        elide: Text.ElideRight
                        Layout.preferredWidth: modelData.width
                        Layout.leftMargin: index < 2 ? 24 : 56
                        horizontalAlignment: "alignment" in modelData ? modelData["alignment"] : index === 0 ? Text.AlignLeft : Text.AlignRight
                    }
                }

                Item {Layout.fillWidth: true}
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

    // Row delegate
    delegate: Item {
        id: rowDelegate
        width: parent.width
        height: 48

        property var rowObject: index >= 0 ? root.model.getObject(index) : null

        Rectangle {
            anchors.fill: parent
            color: Material.theme === Material.Light ? "black" : "white"
            opacity: rowMouseArea.containsMouse ? 0.08 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutCubic
                }
            }

        }

        MouseArea {
            id: rowMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.rowClicked(index)
        }

        RowLayout {
            spacing: 0
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: 24
                rightMargin: 24
                verticalCenter: parent.verticalCenter
            }

            MinusButton {
                onClicked: {
                    root.model.removeRow(index)
                    rowsRemoved()
                }
            }

            Repeater {
                model: root.columns
                delegate: M.Label {
                    type: "Body 1"
                    text: rowObject !== null ? rowObject[modelData.property] : ""
                    elide: Text.ElideRight
                    Layout.preferredWidth: modelData.width
                    Layout.leftMargin: index < 2 ? 24 : 56
                    horizontalAlignment: "alignment" in modelData ? modelData["alignment"] : index === 0 ? Text.AlignLeft : Text.AlignRight
                }
            }

            Item {Layout.fillWidth: true}
        }

        M.Divider {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }
    }
}
