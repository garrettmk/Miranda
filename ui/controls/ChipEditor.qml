import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M

Item {
    id: editor
    implicitWidth: flow.implicitWidth
    implicitHeight: flow.implicitHeight

    property var model: []
    property bool readOnly: false
    property alias delegate: repeater.delegate

    // Methods
    function addChip(chip) {
        model = model.concat([chip])
    }

    function removeChip(index) {
        var newModel = model.slice()
        newModel.splice(index, 1)
        model = newModel
    }

    function clear() {
        model = []
    }

    TextMetrics {
        id: textMetrics
        font.pointSize: textField.font.pointSize
        text: textField.text ? textField.text : textField.labelText
    }

    // Body
    Flow {
        id: flow
        spacing: 8
        anchors.fill: parent

        Repeater {
            id: repeater
            model: editor.model
            delegate: M.Chip {
                text: modelData
                readOnly: editor.readOnly
                onDeleted: removeChip(index)
            }
        }

        M.TextField {
            id: textField
            labelText: "Add tag"
            visible: !editor.readOnly
            topPadding: 6
            implicitWidth: textMetrics.width + 16
            onAccepted: {
                var trimmed_text = text.trim()
                if (trimmed_text !== "") {
                    editor.addChip(trimmed_text)
                }
                text = ""
            }
        }
    }
}
