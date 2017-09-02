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
            opTypeBox.currentIndex = 0
            nameField.text = ""
            scheduledBeforeField.text = ""
            activeBox.currentIndex = 0
        } else {
            opTypeBox.currentIndex = query.query.opType !== undefined ? opTypeBox.model.indexOf(query.query.opType) : 0
            nameField.text = query.query.name !== undefined ? query.query.name : ""
            scheduledBeforeField.text = query.query.scheduledBefore !== undefined ? query.query.scheduledBefore.toString() : ""
            activeBox.currentIndex = query.query.active !== undefined ? query.query.active + 1 : 0
        }
    }

    function applyTo(query) {
        if (query !== null) {
            query.query.opType = opTypeBox.currentIndex > 0 ? opTypeBox.currentText : undefined
            query.query.name = nameField.text ? nameField.text : undefined
            query.query.scheduledBefore = scheduledBeforeField.text ? new Date(scheduledBeforeField.text) : undefined
            query.query.active = activeBox.currentIndex > 0 ? activeBox.currentIndex - 1 : undefined
        }
    }

    function _clear_sorts(query) {

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
        }

        M.SystemIcon {
            source: "icons/category.png"
            Layout.topMargin: 30
        }

        ComboBox {
            id: opTypeBox
            model: ["All", "DummyOperation", "FindMarketMatches"]
            Layout.fillWidth: true
            Layout.topMargin: 16
        }

        M.SystemIcon {
            source: "icons/title.png"
            Layout.topMargin: 32
        }

        M.TextField {
            id: nameField
            Layout.fillWidth: true
            labelText: "Name"
        }

        M.SystemIcon {
            source: "icons/calendar.png"
            Layout.topMargin: 32
        }

        M.TextField {
            id: scheduledBeforeField
            labelText: "Scheduled Before"
            Layout.fillWidth: true
        }

        M.SystemIcon {
            source: "icons/priority.png"
            Layout.topMargin: 40
        }

        ComboBox {
            id: activeBox
            model: ["All", "Inactive", "Active"]
            Layout.fillWidth: true
            Layout.topMargin: 28
        }
    }
}
