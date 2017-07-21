import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import ObjectQuery 1.0
import VendorQueryDocument 1.0
import VendorSortDocument 1.0
import QueryQueryDocument 1.0


Item {
    id: builder

    property ObjectQuery query: ObjectQuery {
        name: "All vendors"
        objectType: "Vendor"
        query: VendorQueryDocument {}
        sort: VendorSortDocument {
            title: Qt.AscendingOrder
        }
    }

    property ObjectQuery queryQuery: ObjectQuery {
        objectType: "ObjectQuery"
        query: QueryQueryDocument {
            objectType: "Vendor"
        }
    }

    function newQuery() {
        query = Qt.createQmlObject("import QtQuick 2.7; import ObjectQuery 1.0; import VendorQueryDocument 1.0; \
                                          ObjectQuery {objectType: \"Vendor\"; query: VendorQueryDocument {} }", builder)
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
            opacity: Material.theme === Material.Light ? 0.54 : 0.70
            text: "Query Properties"
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
            source: "icons/web.png"
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
        }

        M.TextField {
            labelText: "Website"
            Layout.leftMargin: 32
            Layout.fillWidth: true
            text: query.query.website
            onEditingFinished: query.query.website = text
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
                model: ["None", "Title", "Website"]
                Layout.fillWidth: true
                Layout.leftMargin: 32
                currentIndex: query.sort.title === undefined && query.sort.website === undefined ? 0 : query.website === undefined ? 1 : 2
                onActivated: {
                    if (currentIndex === 0) {
                        query.sort.title = null
                        query.sort.website = null
                    } else if (currentIndex === 1) {
                        query.sort.website = null
                        query.sort.title = sortOrderBox.currentIndex
                    } else {
                        query.sort.title = null
                        query.sort.website = sortOrderBox.currentIndex
                    }
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
