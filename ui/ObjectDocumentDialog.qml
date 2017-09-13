import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import MapObject 1.0


M.CenteredModalDialog {
    id: root
    title: "Object Document Viewer"
    standardButtons: Dialog.Ok
    topPadding: 24

    implicitWidth: 800
    implicitHeight: width

    property MapObject currentObject

    Flickable {
        clip: true
        anchors.fill: parent
        contentWidth: documentLabel.implicitWidth
        contentHeight: documentLabel.implicitHeight

        M.Label {
            id: documentLabel
            type: "Body 1"
            text: currentObject !== null ? currentObject.currentDocumentText : ""
            font.family: "Courier"
        }
    }
}
