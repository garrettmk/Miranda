import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import "controls" as M
import Product 1.0


M.CenteredModalDialog {
    id: root
    title: "Validate Product"
    standardButtons:  Dialog.Save | Dialog.Cancel
    padding: 24

    property alias product: validatorPanel.product

    onAccepted: { validatorPanel.apply(); database.saveObject(product); product = null }
    onRejected: { product = null }

    ProductValidatorPanel {
        id: validatorPanel
    }
}
