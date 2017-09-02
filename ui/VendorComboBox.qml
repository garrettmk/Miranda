import QtQuick 2.7
import QtQuick.Controls 2.1
import ObjectModel 1.0


ComboBox {
    property ObjectModel vendorsModel: database.getModel(database.newVendorQuery())
    property var currentVendor: null

    Component.onCompleted: onVisibleChanged()

    onCurrentIndexChanged: {
        if (currentIndex === 0) {
            if (currentVendor !== null)
                currentVendor = null
        } else {
            var vend = vendorsModel.getObject(currentIndex - 1)
            if (currentVendor !== vend)
                currentVendor = vend
        }
    }

    onCurrentVendorChanged: {        
        if (currentVendor === undefined || currentVendor === null) {
            if (currentIndex > 0)
                currentIndex = 0
        } else if (vendorsModel.contains(currentVendor)) {
            var idx = vendorsModel.matchObject(currentVendor) + 1
            if (currentIndex !== idx)
                currentIndex = idx
        } else if (typeof currentVendor === "string" || typeof currentVendor === "object") {
            currentVendor = database.getVendor(currentVendor)
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
