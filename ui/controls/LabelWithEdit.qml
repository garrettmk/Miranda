import QtQuick 2.7
import QtQuick.Controls 2.1
import "." as M

M.AffixedLabel {
    id: root
    verticalAlignment: Text.AlignVCenter

    property alias editTools: editPopup.contentData
    property alias popup: editPopup

    signal editClicked()
    signal editAccepted()

    suffix: M.TinyIconButton {
        id: editButton
        iconSource: "../icons/edit.png"
        onClicked: { editClicked(); editPopup.open() }
    }

    M.EditPopup {
        id: editPopup
        onAccepted: editAccepted()
    }
}
