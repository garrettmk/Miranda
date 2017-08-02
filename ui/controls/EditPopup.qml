import QtQuick 2.7
import QtQuick.Controls 2.1
import "." as M


Dialog {
    id: root
    dim: false
    focus: true
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    header: null
    footer: null
    standardButtons: Dialog.NoButton
    padding: 24
    topPadding: 8

    property alias text: textField.text
    property alias labelText: textField.labelText

    onOpened: textField.selectAll()

    M.TextField {
        id: textField
        implicitWidth: 150
        onAccepted: root.accept()
    }
}
