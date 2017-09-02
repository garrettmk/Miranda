import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectQuery 1.0


Item {
    id: builder

    property ObjectQuery query: builderStack.children[typeBox.currentIndex].query
    property ObjectQuery queryQuery: ObjectQuery {
        objectType: "ObjectQuery"
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        M.Label {
            type: "Subheading"
            text: "Object type"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
        }

        ComboBox {
            id: typeBox
            model: ["Vendors", "Products", "Operations", "Opportunities"]
            Layout.fillWidth: true
            Layout.topMargin: 8
        }

        StackLayout {
            id: builderStack
            currentIndex: typeBox.currentIndex
            Layout.fillWidth: true
            Layout.topMargin: 32

            VendorQueryBuilder {}
            ProductQueryBuilder {}
            OperationQueryBuilder {}
            RelationshipQueryBuilder {}
        }
    }
}
