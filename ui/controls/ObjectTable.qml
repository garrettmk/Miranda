import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M

ListView {
    id: root
    clip: true

    property variant title: null
    property var columns: []
    property Item headerTools
    property color headerBackgroundColor: Material.background

    signal rowsRemoved()
    signal rowClicked(int index)

    property var selectedIndices: []
    property bool selectAll: false

    // Header
    headerPositioning: ListView.OverlayHeader
    header: Rectangle {
        z: 10
        id: headerBackground
        color: headerBackgroundColor
        height: headerLayout.implicitHeight
        width: parent.width
        implicitWidth: headerLayout.implicitWidth

        Component.onCompleted: {
            root.implicitWidth = implicitWidth
        }

        ColumnLayout {
            id: headerLayout
            spacing: 0
            anchors.fill: parent

            // Title
            RowLayout {
                id: titleLayout
                Layout.preferredHeight: root.title !== null || root.headerTools !== null ? 64 : 0
                Layout.fillWidth: true
                Layout.leftMargin: 32
                Layout.rightMargin: 32

                Component.onCompleted: {
                    if (root.headerTools !== null) {
                        root.headerTools.parent = headerToolsItem
                    }
                }

                M.Label {
                    type: "Headline"
                    visible: root.title !== null
                    text: root.title !== null ? root.title : ""
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { visible: root.title !== null; Layout.fillWidth: true }

                Item {
                    id: headerToolsItem
                    Layout.rightMargin: 14
                    implicitWidth: children.length === 1 ? children[0].implicitWidth : childrenRect.width
                    implicitHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // Column headers
            RowLayout {
                Layout.preferredHeight: 56
                spacing: 0
                Layout.leftMargin: 24
                Layout.rightMargin: 24

                CheckBox {
                    enabled: model !== undefined && model.length > 0
                    onCheckedChanged: root.selectAll = checked
                }

                Repeater {
                    model: root.columns
                    delegate: M.Label {
                        type: "Column Header"
                        text: modelData.name
                        elide: Text.ElideRight
                        Layout.preferredWidth: modelData.width
                        Layout.leftMargin: index < 2 ? 24 : 56
                        horizontalAlignment: "alignment" in modelData ? modelData["alignment"] : Qt.AlignLeft
                    }
                }
            }
        }

        M.Divider {
            width: parent.width
            anchors.bottom: parent.bottom
        }
    }

    footerPositioning: ListView.OverlayFooter
    footer: M.Divider { width: root.width }
}
