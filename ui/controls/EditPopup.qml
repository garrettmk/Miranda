import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import "." as M


Dialog {
    id: root
    dim: false
    focus: true
    modal: true
    header: null
    footer: null
    padding: 24
    topPadding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    standardButtons: Dialog.NoButton
    Material.theme: parent.Material.theme
    Material.foreground: parent.Material.foreground
    Material.accent: parent.Material.accent
}
