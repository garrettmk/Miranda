import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M


ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true

    Material.theme: Material.Dark


    Column {
        anchors.centerIn: parent

        M.Label {
            type: "Body 1"
            text: application.datetimeProperty.toString()
        }

//        M.Label {
//            type: "Body 1"
//            text: application.variantProperty
//        }

//        M.Label {
//            type: "Body 1"
//            text: application.qdtProperty
//        }
    }

}
