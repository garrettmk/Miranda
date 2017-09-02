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
            titleField.text = ""
            websiteField.text = ""
            sortFieldBox.currentIndex = 0
        } else {
            titleField.text = query.query.title !== undefined ? query.query.title : ""
            websiteField.text = query.query.website !== undefined ? query.query.website : ""

            if (query.sort.title !== undefined) {
                sortFieldBox.currentIndex = 1
                sortOrderBox.currentIndex = query.sort.title
            } else if (query.sort.website !== undefined) {
                sortFieldBox.currentIndex = 2
                sortOrderBox.currentIndex = query.sort.website
            } else {
                sortFieldBox.currentIndex = 0
            }
        }
    }

    function applyTo (query) {
        if (query !== null) {
            query.query.title = titleField.text ? titleField.text : undefined
            query.query.website = websiteField.text ? websiteField.text : undefined

            _clear_sorts(query)
            var sortIdx = sortFieldBox.currentIndex
            var sortDir = sortOrderBox.currentIndex

            if (sortIdx === 1)
                query.sort.title = sortDir
            else if (sortIdx === 2)
                query.sort.website = sortDir
        }
    }

    function _clear_sorts(query) {
        query.sort.title = undefined
        query.sort.website = undefined
    }

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
        }

        M.SystemIcon {
            source: "icons/title.png"
            Layout.topMargin: 30
        }

        M.TextField {
            id: titleField
            labelText: "Title"
            Layout.fillWidth: true
        }

        M.SystemIcon {
            source: "icons/web.png"
            Layout.topMargin: 30
        }

        M.TextField {
            id: websiteField
            labelText: "Website"
            Layout.fillWidth: true
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
            Layout.fillWidth: true
            Layout.topMargin: 24
            spacing: 0


            ComboBox {
                id: sortFieldBox
                model: ["None", "Title", "Website"]
                Layout.fillWidth: true
            }

            ComboBox {
                id: sortOrderBox
                enabled: sortFieldBox.currentIndex > 0
                model: ["Ascending", "Descending"]
                Layout.fillWidth: true
                Layout.leftMargin: 32

            }
        }
    }
}
