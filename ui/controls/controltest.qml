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

    M.Card {
        id: labelCard
        anchors.centerIn: parent
        contentWidth: labelGrid.implicitWidth + 48
        contentHeight: labelGrid.implicitHeight + 48

        MouseArea {
            anchors.fill: parent
            onClicked: labelCard.raised = !labelCard.raised


            GridLayout {
                id: labelGrid
                columns: 2
                columnSpacing: 50
                anchors.centerIn: parent

                Q.Label {text: "Display 4"}
                M.Label {type: "Display 4"; text: "Light 112"}

                Q.Label {text: "Display 3"}
                M.Label {type: "Display 3"; text: "Regular 56"}

                Q.Label {text: "Display 2"}
                M.Label {type: "Display 2"; text: "Regular 45"}

                Q.Label {text: "Display 1"}
                M.Label {type: "Display 1"; text: "Regular 34"}

                Q.Label {text: "Headline"}
                M.Label {type: "Headline"; text: "Regular 24"}

                Q.Label {text: "Title"}
                M.Label {type: "Title"; text: "Medium 20"}

                Q.Label {text: "Subheading"}
                M.Label {type: "Subheading"; text: "Regular 15"}

                Q.Label {text: "Body 2"}
                M.Label {type: "Body 2"; text: "Medium 13"}

                Q.Label {text: "Body 1"}
                M.Label {type: "Body 1"; text: "Regular 13"}

                Q.Label {text: "Caption"}
                M.Label {type: "Caption"; text: "Regular 12"}

                Q.Label {text: "Button"}
                M.Label {type: "Button"; text: "MEDIUM 14"}
            }
        }
    }
}
