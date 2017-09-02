import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0


Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property Product product: null

    signal editProductClicked()
    signal validateProductClicked()

    // Body
    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        M.ProductImage {
            Layout.fillWidth: true
            Layout.preferredHeight: (width * 2) / (16/9)
            source: product !== null ? product.imageUrl : ""

            Row {
                spacing: 8
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    margins: 8
                }

                M.TinyIconButton {
                    Material.theme: Material.Light
                    iconSource: "icons/edit_dark.png"
                    onClicked: editProductClicked()
                }

                M.TinyIconButton {
                    Material.theme: Material.Light
                    iconSource: "icons/double_check_dark.png"
                    onClicked: validateProductClicked()
                }
            }
        }

        M.LinkLabel {
            type: "Body 2"
            text: product !== null ? product.title !== undefined ? product.title : "n/a" : ""
            link: product !== null && product.detailPageUrl !== undefined ? product.detailPageUrl : ""
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.margins: 16
            Layout.preferredHeight:
        }
    }
}
