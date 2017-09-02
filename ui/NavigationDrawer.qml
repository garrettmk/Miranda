import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M


Drawer {
    id: drawer
    width: 300
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            height: 56
            Layout.fillWidth: true
            color: "transparent"
        }

        M.Divider {Layout.fillWidth: true}

        M.NavItem {
            text: "Database"
            iconSource: "../icons/database.png"
            Layout.fillWidth: true
            state: "ActiveFocused"
        }

        M.NavItem {
            text: "Vendors"
            iconSource: "../icons/vendor.png"
            Layout.fillWidth: true
        }

        M.NavItem {
            text: "Products"
            iconSource: "../icons/product.png"
            Layout.fillWidth: true
        }

        M.NavItem {
            text: "Operations"
            iconSource: "../icons/operation.png"
            Layout.fillWidth: true
        }

        M.NavItem {
            text: "Opportunities"
            iconSource: "../icons/money.png"
            Layout.fillWidth: true
        }

        Item {Layout.fillHeight: true}
    }

}
