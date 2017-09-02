import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import "." as M

M.Label {
    type: "Body 1"
    elide: Text.ElideRight
    font.underline: link ? true : false

    property string link: ""

    MouseArea {
        enabled: link
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: Qt.openUrlExternally(link)
    }
}
