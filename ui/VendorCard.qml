import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Vendor 1.0


ObjectCard {
    id: card

    mediaItem: M.ProductImage {
        anchors.fill: parent
        source: imageUrl
    }

    headlineItem: RowLayout {
        anchors {
            top: parent.top
            left:parent.left
            right: parent.right
        }

        ColumnLayout {
            Layout.fillWidth: true

            M.Label {
                type: "Headline"
                text: title
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.rightMargin: 56
            }

            M.Label {
                type: "Body 2"
                text: website
                elide: Text.ElideRight
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.fillWidth: true
                Layout.rightMargin: 56
            }
        }


        GridLayout {
            columns: 2

            M.Label {
                type: "Body 2"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                text: "Avg. shipping: "
            }

            M.Label {
                type: "Body 1"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                text: shippingRate + "%"
                Layout.alignment: Qt.AlignBottom
            }

            M.Label {
                type: "Body 2"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                text: "Sales tax: "
            }

            M.Label {
                type: "Body 1"
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                text: salesTax ? "Yes" : "No"
                Layout.alignment: Qt.AlignBottom
            }
        }
    }
}
