import QtQuick 2.7
import "." as M

M.LabelWithEdit {
    id: root
    type: "Body 1"
    horizontalAlignment: Text.AlignRight
    prefix: M.Label { type: "Body 1"; text: root.prefixText; opacity: 0.5 }

    property string prefixText: "$"
    property alias editTextField: editTextField

    editTools: M.MoneyField {
        id: editTextField
        onAccepted: root.popup.accept()
    }

    onEditClicked: {
        editTextField.text = root.text
        editTextField.selectAll()
        editTextField.focus = true
    }
}
