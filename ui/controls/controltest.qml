import QtQuick 2.7
import QtQuick.Controls 2.1 as Q
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "." as M


Q.ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true

    Material.theme: Material.Dark

    ListModel {
        id: tableModel

        ListElement {
            title: "Row One"
            category: "Cat 1"
            price: 15.99
        }

        ListElement {
            title: "Row Two"
            category: "Cat 21"
            price: 16.99
        }

        ListElement {
            title: "Row Three"
            category: "Cat 3"
            price: 17.99
        }
    }

    M.Card {
        id: labelCard
        anchors.centerIn: parent
        contentWidth: table.implicitWidth + 48
        contentHeight: table.implicitHeight + 48

        M.Table {
            id: table
            model: tableModel
            implicitWidth: 500
            implicitHeight: 500

            M.TableColumn {
                title: "Title"
                role: "title"
                columnWidth: 200
                delegate: M.Label {text: columnData}
            }
            M.TableColumn {
                title: "Two"
                role: "category"
                columnWidth: 200
                delegate: M.Label {text: columnData}
            }

        }
    }
}
