import QtQuick 2.7
import QtQuick.Controls 2.1
import "." as M


Button {
    id: root
    padding: 0

    property alias iconSource: image.source

    contentItem: M.SystemIcon {
        id: image
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        sourceSize {
            width: 18
            height: 18
        }

        state: root.pressed ? "ActiveFocused" : root.hovered ? "ActiveUnfocused" : "Inactive"
    }

    background: Item {
        implicitWidth: 18
        implicitHeight: 18
    }
}
