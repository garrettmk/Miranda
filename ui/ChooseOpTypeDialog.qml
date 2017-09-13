import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Operation 1.0


M.CenteredModalDialog {
    id: root
    title: "Choose Operation Type"
    standardButtons: Dialog.Ok | Dialog.Cancel

    property alias kind: typeBox.currentText

    // Body
    ColumnLayout {
        id: layout
        anchors.fill: parent

        ComboBox {
            id: typeBox
            model: ["DummyOperation", "FindMarketMatches", "UpdateProducts", "UpdateOpportunities"]
            Layout.fillWidth: true
        }
    }
}
