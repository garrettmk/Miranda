import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import "controls" as M


M.CenteredModalDialog {
    id: root
    title: "Operations Manager"
    standardButtons: Dialog.Ok

    topPadding: 24

    ColumnLayout {
        id: layout
        spacing: 0

        M.Label {
            type: "Subheading Light"
            text: "Actions"
        }

        RowLayout {
            Layout.margins: 8
            Layout.topMargin: 24
            spacing: 8

            M.IconToolButton {
                iconSource: "../icons/play.png"
                enabled: !application.operations.running
                onClicked: application.operations.start()
            }

            M.IconToolButton {
                iconSource: "../icons/pause.png"
                enabled: application.operations.running
                onClicked: application.operations.stop()
            }
        }

        RowLayout {
            Layout.topMargin: 32
            Layout.fillWidth: true

            M.Label {
                type: "Subheading Light"
                text: "Status Log"
                Layout.alignment: Qt.AlignBottom
            }

            Item { Layout.fillWidth: true }

            M.TinyIconButton {
                iconSource: "icons/delete.png"
                onClicked: statusLabel.text = ""
                Layout.alignment: Qt.AlignBottom
            }
        }

        M.Divider {
            Layout.topMargin: 24
            Layout.fillWidth: true
        }

        Flickable {
            clip: true
            Layout.topMargin: 24
            Layout.fillWidth: true
            Layout.fillHeight: true

            implicitWidth: 800
            implicitHeight: 400

            contentWidth: statusLabel.implicitWidth
            contentHeight: statusLabel.implicitHeight

            M.Label {
                id: statusLabel
                type: "Body 1"

                Connections {
                    target: application.operations
                    enabled: statusLabel.visible
                    onStatusMessageChanged: {
                        statusLabel.text = application.operations.statusMessage + "\n" + statusLabel.text
                    }
                }
            }
        }

        M.Divider {
            Layout.topMargin: 24
            Layout.fillWidth: true
        }
    }

}
