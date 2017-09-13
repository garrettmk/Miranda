import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import QtCharts 2.2
import Product 1.0
import ProductHistory 1.0


Item {
    id: root

    property Product product
    property ProductHistory _history

    onProductChanged: {
        var hist = database.getObject(database.newProductHistoryQuery(product))
        if (hist !== undefined)
            _history = hist
        else
            _history = null

        showHistory()
    }

    function showHistory() {
        rankSeries.removePoints(0, rankSeries.count)
        priceSeries.removePoints(0, priceSeries.count)

        if (_history !== null) {
            _history.setDateRange(xAxis.min, xAxis.max)
            _history.rankPoints.forEach( function(p) { rankSeries.append(p.x, p.y) } )
            rankAxis.min = _history.minRank !== undefined ? _history.minRank * 0.95 : 0
            rankAxis.max = _history.maxRank !== undefined ? _history.maxRank * 1.05 : 500000
            rankAxis.applyNiceNumbers()
            avgRankLabel.text = _history.averageRank !== undefined ? _history.averageRank.toLocaleString() : "n/a"

            _history.pricePoints.forEach( function(p) { priceSeries.append(p.x, p.y) } )
            priceAxis.min = _history.minPrice !== undefined ? _history.minPrice * 0.95 : 0
            priceAxis.max = _history.maxPrice !== undefined ? _history.maxPrice * 1.05 : 100
            priceAxis.applyNiceNumbers()
        } else {
            rankAxis.min = 0
            rankAxis.max = 500000
            priceAxis.min = 0
            priceAxis.max = 100
            avgRankLabel.text = ""
        }

        rankAxis.tickCount = 6
        priceAxis.tickCount = 6
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ChartView {
            id: chartView
            legend.visible: false
            antialiasing: true
            backgroundColor: "transparent"
            localizeNumbers: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }

            Material.theme: parent.Material.theme
            Material.background: parent.Material.background
            Material.foreground: parent.Material.foreground
            Material.accent: parent.Material.accent
            Material.primary: parent.Material.primary

            DateTimeAxis {
                id: xAxis
                min: new Date(Date.now() - 86400000)
                max: new Date()
                color: Material.theme === Material.Dark ? "#12000000" : "#12FFFFFF"
                gridLineColor: color
                labelsColor: Material.theme === Material.Dark ? "#B3000000" : "#B3FFFFFF"
                format: "h:mm ap"
            }

            ValueAxis {
                id: rankAxis
                min: 0
                max: 500000
                tickCount: 6
                labelFormat: "%.0g"
                color: Material.theme === Material.Dark ? "#12000000" : "#12FFFFFF"
                gridLineColor: color
                labelsColor: Material.theme === Material.Dark ? "#B3000000" : "#B3FFFFFF"
            }

            ValueAxis {
                id: priceAxis
                min: 0
                max: 100
                tickCount: 6
                labelFormat: "$%.2f"
                color: rankAxis.color
                gridLineColor: rankAxis.gridLineColor
                labelsColor: rankAxis.labelsColor
            }

            SplineSeries {
                id: priceSeries
                name: "Price"
                axisX: xAxis
                axisYRight: priceAxis
                color: Material.color(Material.Green, Material.ShadeA200)
                width: 3
                pointsVisible: true
            }


            SplineSeries {
                id: rankSeries
                name: "Rank"
                axisX: xAxis
                axisY: rankAxis
                color: Material.color(Material.Blue, Material.ShadeA200)
                width: 3
                pointsVisible: true
            }
        }

        RowLayout {
            spacing: 32
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.leftMargin: 24

            ComboBox {
                id: timePeriodBox
                enabled: _history !== null
                model: ["24 hours", "1 week", "1 month", "All"]
                onActivated: {
                    var min_time, max_time

                    if (index === 0){
                        min_time = new Date(Date.now() - 86400000)
                        max_time = new Date()
                        xAxis.format = "h:mm ap"
                    } else if (index === 1) {
                        min_time = new Date(Date.now() - 604800000)
                        max_time = new Date()
                        xAxis.format = "ddd h:mm ap"
                    } else if (index === 2) {
                        min_time = new Date(Date.now() - 2678400000)
                        max_time = new Date()
                        xAxis.format = "MMM dd"
                    } else if (index === 3) {
                        min_time = undefined
                        max_time = undefined
                    }

                    _history.setDateRange(min_time, max_time)
                    showHistory()

                    if (min_time === undefined) {
                        xAxis.min = _history.minDateTime
                        xAxis.max = _history.maxDateTime
                    } else {
                        xAxis.min = min_time
                        xAxis.max = max_time
                    }
                }

            }

            M.Label {
                type: "Body 2 Light"
                text: "Average Rank:"
            }

            M.Label {
                id: avgRankLabel
                type: "Body 1"
            }
        }
    }
}
