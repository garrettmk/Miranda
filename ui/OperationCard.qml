import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Operation 1.0


ObjectCard {
    id: root

    mediaItem: Rectangle {
        anchors.fill: parent
        color: Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)

        StackLayout {
            anchors.fill: parent

            M.Label {
                type: "Body 1"
                text: "DummyOperation does not have any parameters."
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

    }

    headlineItem: ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.Label {
                type: "Headline"
                text: name !== undefined ? name : "unnamed"
                Layout.fillWidth: true
                Layout.rightMargin: 56
            }

            M.Label {
                type: "Headline"
                text: active ? "Active" : "Inactive"
            }
        }

        M.Label {
            type: "Body 2"
            text: pythonClassName
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
        }

        M.Label {
            type: "Caption"
            text: scheduled.toString()
        }
    }
}
