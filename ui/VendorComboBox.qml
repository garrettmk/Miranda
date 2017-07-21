import QtQuick 2.7
import QtQuick.Controls 2.1
import ObjectModel 1.0


ComboBox {
    property ObjectModel vendorsModel: database.getModel(database.newVendorQuery())
    property var currentVendor: null

    Component.onCompleted: onVisibleChanged()

    onCurrentIndexChanged: {
        if (currentIndex === 0) {
            currentVendor = null
        } else {
            currentVendor = vendorsModel.getObject(currentIndex - 1)
        }
    }

    onCurrentVendorChanged: {
        var idx = 0

        if (typeof currentVendor === "string") {
            idx = vendorsModel.matchOne("id", currentVendor)
            currentIndex = idx + 1
        } else if (typeof currentVendor === "object") {
            idx = vendorsModel.matchObject(currentVendor)
            if (idx != currentIndex - 1)
                currentIndex = idx + 1
        }
    }

    onVendorsModelChanged: {
        var names = ["None"]

        for (var i=0; i<vendorsModel.length; i++) {
            names.push(vendorsModel.getObject(i).title)
        }

        model = names
    }

    onVisibleChanged: {
        if (visible) {
            var current = currentVendor
            vendorsModel = database.getModel(database.newVendorQuery())
            var idx = vendorsModel.matchObject(current)
            currentIndex = idx + 1
        }
    }
}
