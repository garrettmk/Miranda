import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M


Drawer {
    id: drawer
    width: 400
    height: parent.height

    ColumnLayout {
        anchors.fill: parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ListModel {
                ListElement {
                    icon: "icons/database.png"
                    text: "Database Terminal"
                }

                ListElement {
                    icon: "icons/vendor.png"
                    text: "Vendors"
                }

                ListElement {
                    icon: "icons/product.png"
                    text: "Products"
                }

                ListElement {
                    icon: "icons/operation.png"
                    text: "Operations"
                }
            }

            delegate: Label {
                text: text
            }

        }
    }

}
