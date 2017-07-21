import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0


Dialog {
    id: dialog
    title: "Connect to Database"
    standardButtons: Dialog.Ok | Dialog.Cancel

    property alias uri: uriField.text
    property alias dbName: dbNameField.text

    Settings {
        category: "DBConnectionDialog"
        property alias uri: dialog.uri
        property alias dbName: dialog.dbName
    }

    GridLayout {
        columns: 2
        columnSpacing: 16
        anchors.centerIn: parent

        Label {
            text: "Database URI:"
        }
        TextField {
            id: uriField
            placeholderText: "mongodb://localhost:27017"
            Layout.minimumWidth: 400
            Layout.fillWidth: true
        }

        Label {
            text: "Database name:"
        }
        TextField {
            id: dbNameField
            placeholderText: "miranda"
            Layout.fillWidth: true
        }
    }

}
