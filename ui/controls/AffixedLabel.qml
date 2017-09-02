import QtQuick 2.7
import QtQuick.Controls 2.1
import "." as M

M.Label {
    id: root
    leftPadding: prefixItem.width ? prefixItem.width + 16 : 0
    rightPadding: suffixItem.width ? suffixItem.width + 16 : 0

    property Item prefix
    property Item suffix

    Component.onCompleted: {
        if (prefix !== null)
            prefix.parent = prefixItem

        if (suffix !== null)
            suffix.parent = suffixItem
    }

    Item {
        id: prefixItem
        implicitWidth: children.length === 1 ? children[0].implicitWidth : childrenRect.width
        implicitHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: suffixItem
        implicitWidth: children.length === 1 ? children[0].implicitWidth : childrenRect.width
        implicitHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }
}
