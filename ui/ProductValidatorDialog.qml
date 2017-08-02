import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import "controls" as M
import Product 1.0


Dialog {
    id: root
    modal: true
    title: "Validate Product"
    standardButtons:  Dialog.Apply | Dialog.Cancel

    x: ApplicationWindow.window.width / 2 - width / 2
    y: ApplicationWindow.window.height / 2 - height / 2

    padding: 24

    property alias product: validatorPanel.product

    onAccepted: validatorPanel.apply()

    ProductValidatorPanel {
        id: validatorPanel
        anchors.fill: parent
    }
}
