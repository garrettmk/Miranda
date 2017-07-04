import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M

Item {
    id: editor
    implicitWidth: flow.implicitWidth
    implicitHeight: flow.implicitHeight

    property alias model: repeater.model
    property alias delegate: repeater.delegate

    signal tagsChanged()
    signal tagClicked(string tag)

    // Methods
    function addTag(tag) {
        model.append({"tag": tag})
        tagsChanged()
    }

    function removeTag(index) {
        model.remove(index, 1)
        tagsChanged()
    }

    function clear() {
        model.clear()
        tagsChanged()
    }

    TextMetrics {
        id: textMetrics
        font.pointSize: textField.font.pointSize
        text: textField.text
    }

    // Body
    Flow {
        id: flow
        spacing: 5
        anchors.fill: parent

        Repeater {
            id: repeater
            model: ListModel {}
            delegate: M.TagButton {
                text: modelData
                onClicked: removeTag(index)
            }
        }

        TextField {
            id: textField
            visible: editor.enabled
            implicitWidth: Math.max(textMetrics.width, 35)
            onEditingFinished: {
                var trimmed_text = text.trim()
                if (trimmed_text !== "") {
                    editor.addTag(trimmed_text)
                }
                text = ""
            }
        }
    }
}
