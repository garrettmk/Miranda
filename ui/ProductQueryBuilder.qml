import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectQuery 1.0
import ProductQueryDocument 1.0
import ProductSortDocument 1.0
import QueryQueryDocument 1.0


Item {
    id: builder

    property ObjectQuery query: ObjectQuery {
        name: "All products"
        objectType: "Product"
        query: ProductQueryDocument {}
        sort: ProductSortDocument {}
    }

    property ObjectQuery queryQuery: ObjectQuery {
        objectType: "ObjectQuery"
        query: QueryQueryDocument {
            objectType: "Product"
        }
    }

    function newQuery() {
        query = database.newProductQuery()
    }

    GridLayout {
        columns: 2
        columnSpacing: 0
        rowSpacing: 0
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        M.Label {
            type: "Subheading"
            text: "Query Properties"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/save.png"
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            labelText: "Query name"
            Layout.leftMargin: 32
            Layout.fillWidth: true
            text: query.name
            onEditingFinished: query.name = text
        }

        M.Label {
            type: "Subheading"
            text: "Query Parameters"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            Layout.columnSpan: 2
            Layout.topMargin: 48
        }

        M.SystemIcon {
            source: "icons/vendor.png"
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 30
        }

        VendorComboBox {
            id: vendorBox
            Layout.fillWidth: true
            Layout.leftMargin: 32
            Layout.topMargin: 16
            currentVendor: query.query.vendor
            onActivated: query.query.vendor = currentVendor
        }

        M.SystemIcon {
            source: "icons/title.png"
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            labelText: "Title"
            Layout.leftMargin: 32
            Layout.fillWidth: true
            text: query.query.title
            onEditingFinished: query.query.title = text
        }

        M.SystemIcon {
            source: "icons/features.png"
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.TextField {
                labelText: "Brand"
                text: query.query.brand
                onEditingFinished: query.query.brand = text
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.TextField {
                labelText: "Model"
                text: query.query.model
                onEditingFinished: query.query.model = text
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }
        }

        M.SystemIcon {
            source: "icons/feedback.png"
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            labelText: "Category"
            text: query.query.category
            onEditingFinished: query.query.category = text
            Layout.fillWidth: true
            Layout.leftMargin: 32
        }

        Item {Layout.preferredWidth: 1}

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.TextField {
                labelText: "Min Rank"
                text: query.query.minRank
                onEditingFinished: query.query.minRank = text
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.TextField {
                labelText: "Max Rank"
                text: query.query.maxRank
                onEditingFinished: query.query.maxRank = text
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.TextField {
                labelText: "Feedback"
                text: query.query.feedback
                onEditingFinished: query.query.feedback = text
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }
        }

        M.Label {
            type: "Subheading"
            text: "Sort Options"
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            Layout.columnSpan: 2
            Layout.topMargin: 48
        }

        RowLayout {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.topMargin: 24
            spacing: 0

            M.SystemIcon {
                source: "icons/sort.png"
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 8
            }

            ComboBox {
                id: sortFieldBox
                model: ["None", "Title", "Brand", "Model", "Category", "Rank", "Feedback"]
                Layout.fillWidth: true
                Layout.leftMargin: 32
                currentIndex: query.sort.title !== undefined ? 1 : query.sort.brand !== undefined ? 2 : query.sort.model !== undefined ? 3 : query.sort.category !== undefined ? 4 : query.sort.rank !== undefined ? 5 : query.sort.feedback !== undefined ? 6 : 0
                onActivated: {
                    clearFilters()
                    var order = sortOrderBox.currentIndex

                    if (currentIndex === 1) {
                        query.sort.title = order
                    } else if (currentIndex === 2) {
                        query.sort.brand = order
                    } else if (currentIndex === 3) {
                        query.sort.model = order
                    } else if (currentIndex === 4) {
                        query.sort.category = order
                    } else if (currentIndex === 5) {
                        query.sort.rank = order
                    } else if (currentIndex === 6) {
                        query.sort.feedback = order
                    }
                }

                function clearFilters() {
                    query.sort.title = null
                    query.sort.brand = null
                    query.sort.model = null
                    query.sort.category = null
                    query.sort.rank = null
                    query.sort.feedback = null
                }
            }

            ComboBox {
                id: sortOrderBox
                enabled: sortFieldBox.currentIndex > 0
                model: ["Ascending", "Descending"]
                Layout.fillWidth: true
                Layout.leftMargin: 32
                onActivated: {
                    if (sortFieldBox.currentIndex === 0) {
                        query.sort.title = currentIndex
                    } else {
                        query.sort.website = currentIndex
                    }
                }
            }
        }
    }
}
