import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M


Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property alias model: list.model
    property alias headerItem: headerItem
    property alias header: headerItem.children

    default property alias columns: columnHolderItem.children
    property Item columnHolder: Item {id: columnHolderItem}

    ColumnLayout {
        id: layout
        spacing: 0
        anchors.fill: parent

        Item {
            id: headerItem
            visible: children.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Item {
                id: rowDelegate
                width: parent.width
                height: 48

                Component.onCompleted: {
                    for (var data in model) {
                        console.log(data)
                    }

                    var column, delegate
                    for (var i=0; i<root.columns.length; i++) {
                        column = columns[i]
                        delegate = column.delegate.createObject(rowLayout)
                        delegate.Layout.preferredWidth = column.columnWidth
                    }
                }

                RowLayout {
                    id: rowLayout
                    anchors.fill: parent

                }
            }

        }

        Item {
            id: footerItem
            visible: children.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: children.length === 1 ? children[0].implicitHeight : childrenRect.height
        }
    }
}
