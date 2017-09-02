import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M


Item {
    id: root
    width: parent.width //layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
    height: 48

    default property alias fields: layout.children

    property bool highlighted: false
    property alias checked: checkBox.checked
    property alias checkEnabled: checkBox.enabled

    signal clicked()

    Rectangle {
        id: background
        anchors.fill: parent
        color: Material.theme === Material.Light ? "black" : "white"
        opacity: root.ListView.isCurrentItem ? 0.12 : highlighted ? 0.08 : 0
        Behavior on opacity { OpacityAnimator { duration: 100 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: highlighted = containsMouse
        onClicked: root.clicked()
    }

    RowLayout {
        id: layout
        spacing: 0
        anchors {
            left: parent.left
            leftMargin: 24
            rightMargin: 24
            verticalCenter: parent.verticalCenter
        }

        Component.onCompleted: {
            var columns = root.ListView.view.columns
            var child
            var align
            var columnData

            for (var i=0; i<children.length-1; i++) {
                child = children[i + 1]
                columnData = columns[i]

                align = "alignment" in columnData ? columnData.alignment : Qt.AlignLeft
                child.Layout.preferredWidth = columnData.width
                child.Layout.alignment = align
                child.Layout.leftMargin = i < 2 ? 24 : 56
            }
        }

        CheckBox {
            id: checkBox
            Layout.preferredWidth: implicitWidth + 2
            checked: root.ListView.view.selectAll || root.ListView.view.selectedIndices.indexOf(index) > -1
            enabled: !root.ListView.view.selectAll
            onClicked: {
                var selected = root.ListView.view.selectedIndices
                if (checked) {
                    selected.push(index)
                    root.ListView.view.selectedIndices = selected
                } else {
                    var idx = root.ListView.view.selectedIndices.indexOf(index)
                    selected.splice(idx, 1)
                    root.ListView.view.selectedIndices = selected
                }
            }
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
