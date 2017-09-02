import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M


Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    function show(query) {
        if (query === null) {
            marketVendorBox.currentVendor = null
            supplierVendorBox.currentVendor = null
            minProfitField.text =  ""
            minMarginField.text = ""
            minROIField.text = ""
            sortByBox.currentIndex = 0
            sortDirectionBox.currentIndex = 0
        } else {
            marketVendorBox.currentVendor = query.query.marketVendor
            supplierVendorBox.currentVendor = query.query.supplierVendor
            minProfitField.text = query.query.minProfit !== undefined ? query.query.minProfit.toFixed(2) : ""
            minMarginField.text = query.query.minMargin !== undefined ? query.query.minMargin * 100 : ""
            minROIField.text = query.query.minROI !== undefined ? query.query.minROI * 100 : ""

            if (query.sort.marketVendor !== undefined) {
                sortByBox.currentIndex = 1
                sortDirectionBox.currentIndex = query.sort.marketVendor
                return
            }

            if (query.sort.supplierVendor !== undefined) {
                sortByBox.currentIndex = 2
                sortDirectionBox.currentIndex = query.sort.marketVendor
                return
            }

            if (query.sort.profit !== undefined) {
                sortByBox.currentIndex = 3
                sortDirectionBox.currentIndex = query.sort.profit
                return
            }

            if (query.sort.margin !== undefined) {
                sortByBox.currentIndex = 4
                sortDirectionBox.currentIndex = query.sort.margin
                return
            }

            if (query.sort.roi !== undefined) {
                sortByBox.currentIndex = 5
                sortDirectionBox.currentIndex = query.sort.roi
                return
            }

            sortByBox.currentIndex = 0
            sortDirectionBox.currentIndex = 0
        }
    }

    function applyTo(query) {
        if (query !== null) {
            query.query.marketVendor = marketVendorBox.currentVendor !== null && marketVendorBox.currentvendor !== undefined ? marketVendorBox.currentVendor : undefined
            query.query.supplierVendor = supplierVendorBox.curentVendor !== null && supplierVendorBox.currentVendor !== undefined ? supplierVendorBox.currentVendor : undefined
            query.query.minProfit = minProfitField.text ? parseFloat(minProfitField.text) : undefined
            query.query.minMargin = minMarginField.text ? parseFloat(minMarginField.text) / 100 : undefined
            query.query.minROI   = minROIField.text ? parseFloat(minROIField.text) / 100 : undefined

            _clear_sorts(query)
            var sortIdx = sortByBox.currentIndex
            var sortDir = sortDirectionBox.currentIndex

            if (sortIdx === 1)
                query.sort.marketVendor = sortDir
            else if (sortIdx === 2)
                query.sort.supplierVendor = sortDir
            else if (sortIdx === 3)
                query.sort.profit = sortDir
            else if (sortIdx === 4)
                query.sort.margin = sortDir
            else if (sortIdx === 5)
                query.sort.roi = sortDir
        }
    }

    function _clear_sorts(query) {
        query.sort.marketVendor = undefined
        query.sort.supplierVendor = undefined
        query.sort.profit = undefined
        query.sort.margin = undefined
        query.sort.roi = undefined
    }

    // Body
    GridLayout {
        id: layout
        columns: 2
        columnSpacing: 32
        rowSpacing: 0
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        M.Label {
            type: "Subheading"
            text: "Query Parameters"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            Layout.columnSpan: 2
//            Layout.topMargin: 48
        }

        M.SystemIcon {
            source: "icons/market.png"
            Layout.topMargin: 30
        }

        VendorComboBox {
            id: marketVendorBox
            Layout.fillWidth: true
            Layout.topMargin: 24
        }

        M.SystemIcon {
            source: "icons/vendor.png"
            Layout.topMargin: 6
        }

        VendorComboBox {
            id: supplierVendorBox
            Layout.fillWidth: true
        }

        M.SystemIcon {
            source: "icons/money.png"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 32

            M.MoneyField {
                id: minProfitField
                labelText: "Min. Profit ($)"
                Layout.fillWidth: true
            }

            M.PercentField {
                id: minMarginField
                labelText: "Min. Margin (%)"
                Layout.fillWidth: true
            }

            M.PercentField {
                id: minROIField
                labelText: "Min. ROI (%)"
                Layout.fillWidth: true
            }
        }

        M.Label {
            type: "Subheading"
            text: "Sort Options"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            Layout.columnSpan: 2
            Layout.topMargin: 48
        }

        M.SystemIcon {
            source: "icons/sort.png"
            Layout.topMargin: 30
        }

        RowLayout {
            spacing: 32
            Layout.fillWidth: true
            Layout.topMargin: 24

            ComboBox {
                id: sortByBox
                model: ["None", "Marketplace", "Supplier", "Profit", "Margin", "ROI"]
                Layout.fillWidth: true
            }

            ComboBox {
                id: sortDirectionBox
                enabled: sortByBox.currentIndex > 0
                model: ["Ascending", "Descending"]
                Layout.fillWidth: true
            }
        }
    }
}
