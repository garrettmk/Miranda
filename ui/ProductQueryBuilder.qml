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
            textSearchField.text = ""
            vendorBox.currentVendor = null
            titleField.text = ""
            brandField.text = ""
            modelField.text = ""
            categoryField.text = ""
            minRankField.text = ""
            maxRankField.text = ""
            feedbackField.text = ""
            sortFieldBox.currentIndex = 0
            tagsEditor.model = []
        } else {
            textSearchField.text = query.query.textSearch !== undefined ? query.query.textSearch : ""
            vendorBox.currentVendor = query.query.vendor
            titleField.text = query.query.title !== undefined ? query.query.title : ""
            brandField.text = query.query.brand !== undefined ? query.query.brand : ""
            modelField.text = query.query.model !== undefined ? query.query.model : ""
            categoryField.text = query.query.category !== undefined ? query.query.category : ""
            minRankField.text = query.query.minRank !== undefined ? query.query.minRank : ""
            maxRankField.text = query.query.maxRank !== undefined ? query.query.maxRank : ""
            feedbackField.text = query.query.feedback !== undefined ? query.query.feedback : ""
            tagsEditor.model = query.query.tags !== undefined ? query.query.tags : []

            if (query.sort.title !== undefined) {
                sortFieldBox.currentIndex = 1
                sortOrderBox.currentIndex = query.sort.title
                return
            }

            if (query.sort.brand !== undefined) {
                sortFieldBox.currentIndex = 2
                sortOrderBox.currentIndex = query.sort.brand
                return
            }

            if (query.sort.model !== undefined) {
                sortFieldBox.currentIndex = 3
                sortOrderBox.currentIndex = query.sort.model
                return
            }

            if (query.sort.category !== undefined) {
                sortFieldBox.currentIndex = 4
                sortOrderBox.currentIndex = query.sort.category
                return
            }

            if (query.sort.rank !== undefined) {
                sortFieldBox.currentIndex = 5
                sortOrderBox.currentIndex = query.sort.rank
                return
            }

            if (query.sort.feedback !== undefined) {
                sortFieldBox.currentIndex = 6
                sortOrderBox.currentIndex = query.sort.feedback
                return
            }

            sortFieldBox.currentIndex = 0
        }
    }

    function applyTo(query) {
        if (query !== null) {
            query.query.textSearch = textSearchField.text ? textSearchField.text : undefined
            query.query.vendor = vendorBox.currentIndex ? vendorBox.currentVendor : undefined
            query.query.title = titleField.text ? titleField.text : undefined
            query.query.brand = brandField.text ? brandField.text : undefined
            query.query.model = modelField.text ? modelField.text : undefined
            query.query.category = categoryField.text ? categoryField.text : undefined
            query.query.minRank = minRankField.text ? parseInt(minRankField.text) : undefined
            query.query.maxRank = maxRankField.text ? parseInt(maxRankField.text) : undefined
            query.query.feedback = feedbackField.text ? parseFloat(feedbackField.text) : undefined
            query.query.tags = tagsEditor.model.length ? tagsEditor.model : undefined

            _clear_sorts(query)
            var sortIdx = sortFieldBox.currentIndex
            var sortDir = sortOrderBox.currentIndex

            if (sortIdx === 1)
                query.sort.title = sortDir
            else if (sortIdx === 2)
                query.sort.brand = sortDir
            else if (sortIdx === 3)
                query.sort.model = sortDir
            else if (sortIdx === 4)
                query.sort.category = sortDir
            else if (sortIdx === 5)
                query.sort.rank = sortDir
            else if (sortIdx === 6)
                query.sort.feedback = sortDir
        }
    }

    function _clear_sorts(query) {
        query.sort.title = undefined
        query.sort.brand = undefined
        query.sort.model = undefined
        query.sort.category = undefined
        query.sort.rank = undefined
        query.sort.feedback = undefined
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
            type: "Subheading Light"
            text: "Query Parameters"
            Layout.columnSpan: 2
        }

        M.SystemIcon {
            source: "icons/text.png"
            Layout.topMargin: 30
        }

        M.TextField {
            id: textSearchField
            Layout.fillWidth: true
            labelText: "Text Search"
        }

        M.SystemIcon {
            source: "icons/vendor.png"
            Layout.topMargin: 30
        }

        VendorComboBox {
            id: vendorBox
            Layout.fillWidth: true
            Layout.topMargin: 24
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
            source: "icons/features.png"
            Layout.topMargin: 30
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.TextField {
                id: brandField
                labelText: "Brand"
                Layout.fillWidth: true
            }

            M.TextField {
                id: modelField
                labelText: "Model"
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }
        }

        M.SystemIcon {
            source: "icons/feedback.png"
            Layout.topMargin: 32
        }

        M.TextField {
            id: categoryField
            labelText: "Category"
            Layout.fillWidth: true
        }

        M.SystemIcon {
            source: "icons/tag.png"
            Layout.topMargin: 30
        }

        M.ChipEditor {
            id: tagsEditor
            Layout.topMargin: 30
            Layout.fillWidth: true
        }

        Item {Layout.preferredWidth: 1}

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.TextField {
                id: minRankField
                labelText: "Min Rank"
                Layout.fillWidth: true
            }

            M.TextField {
                id: maxRankField
                labelText: "Max Rank"
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.TextField {
                id: feedbackField
                labelText: "Feedback"
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }
        }

        M.Label {
            type: "Subheading Light"
            text: "Sort Options"
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
                model: ["None", "Title", "Brand", "Model", "Category", "Rank", "Feedback"]
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
