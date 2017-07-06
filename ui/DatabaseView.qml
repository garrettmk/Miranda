import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M

Item {
    id: root

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        RowLayout {
            anchors.fill: parent

            M.IconToolButton {
                iconSource: "../icons/search.png"
            }

            TextField {
                Layout.preferredWidth: 400
                placeholderText: "Query document"
            }

            Item {Layout.fillWidth: true}

        }
    }

    Pane {
        Material.elevation: 2
        height: 400
        anchors {
            top: toolbar.bottom
            left: parent.left
            right: parent.right
            margins: 16
        }
        Label {
            anchors.centerIn: parent
            text: "No results."
        }
    }
}
