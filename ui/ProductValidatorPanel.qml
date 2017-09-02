import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0
import PriceValidator 1.0
import QuantityValidator 1.0
import RankValidator 1.0


Item {
    id: panel
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property var product
    property PriceValidator priceValidator: PriceValidator {}
    property QuantityValidator quantValidator: database.newQuantityValidator()
    property RankValidator rankValidator: RankValidator {}
    property var validators: [priceValidator, quantValidator, rankValidator]

    onProductChanged: {
        if (validators) {
            for (var i=0; i<validators.length; i++) {
                validators[i].product = product
                validatorRows.itemAt(i).saveGuess = false
            }
        }
    }

    function apply() {
        var use, save
        for (var i=0; i<validators.length; i++) {
            use = validatorRows.itemAt(i).useGuess
            save = validatorRows.itemAt(i).saveGuess
            if (save) validators[i].saveGuess()
            if (use) validators[i].apply()
        }
        database.saveObject(quantValidator.map)
    }

    function setValidationLevel(level) {
        if (level === "None")
            for (var i=0; i<validators.length; i++)
                validators[i].enabled = false
        else if (level === "Manual"){
            for (var i=0; i<validators.length; i++) {
                validators[i].enabled = true
                validators[i].alwaysApply = false
            }
        } else if (level === "Automatic") {
            for (var i=0; i<validators.length; i++) {
                validators[i].enabled = true
                validators[i].alwaysApply = true
            }
        }
    }

    Component.onCompleted: setValidationLevel("Manual")

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        property var columns: [
            {title: "Auto", width: 25},
            {title: "Property", width: 100},
            {title: "Current Value", width: 125},
            {title: "Guessed Value", width: 100},
            {title: "Use", width: 25},
            {title: "Save", width: 25},
        ]

        // Header
        Item {
            Layout.preferredHeight: 56
            Layout.preferredWidth: headerLayout.implicitWidth

            Component.onCompleted: panel.implicitWidth = headerLayout.implicitWidth

            RowLayout {
                id: headerLayout
                spacing: 0
                anchors.fill: parent

                Repeater {
                    model: layout.columns
                    delegate: M.Label {
                        type: "Caption"
                        text: modelData.title
                        Layout.leftMargin: index === 2 || index === 3 || index === 4 ? 56 : 24
                        Layout.rightMargin: index === layout.columns.length - 1 ? 24 : 0
                        Layout.alignment: index === 1 ? Qt.AlignLeft | Qt.AlignVCenter : Qt.AlignRight | Qt.AlignVCenter
                        Layout.preferredWidth: modelData.width
                    }
                }
            }

            M.Divider {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }
        }

        // Validator rows
        Repeater {
            id: validatorRows
            model: validators
            delegate: Item {
                id: validatorRowDelegate
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                property alias useGuess: useCheck.checked
                property alias saveGuess: saveCheck.checked

                M.Divider {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                }

                RowLayout {
                    id: rowLayout
                    anchors.fill: parent
                    spacing: 0

                    CheckBox {
                        checked: modelData.alwaysApply
                        onCheckedChanged: modelData.alwaysApply = checked
                        Layout.leftMargin: 24
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.preferredWidth: layout.columns[0].width
                    }

                    M.Label {
                        type: "Body 1"
                        text: "'" + modelData.propertyName  + "'"
                        Layout.leftMargin: 24
                        Layout.preferredWidth: layout.columns[1].width
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }

                    M.LabelWithEdit {
                        id: currentValueLabel
                        Layout.leftMargin: 56
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: layout.columns[2].width
                        Layout.preferredHeight: parent.height

                        text: modelData.currentValue !== undefined ? typeof modelData.currentValue === "string" ? "'" + modelData.currentValue + "'" : modelData.currentValue : ""
                        elide: Text.ElideRight
                        color: modelData !== undefined ? modelData.isValid ? Material.color(Material.Green, Material.Shade500) : Material.color(Material.Red, Material.Shade500) : Material.foreground
                        Behavior on color { ColorAnimation { duration: 100 } }

                        editTools: M.TextField {
                            id: editCurrentValueField
                            labelText: "Current Value"
                            onAccepted: currentValueLabel.popup.accept()
                        }

                        onEditClicked: { editCurrentValueField.text = text; editGuessField.selectAll(); editCurrentValueField.focus = true }
                        onEditAccepted: modelData.setCurrentValueWithEval(editCurrentValueField.text)
                    }

                    M.LabelWithEdit {
                        id: guessLabel
                        Layout.leftMargin: 56
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: layout.columns[3].width
                        Layout.preferredHeight: parent.height

                        text: modelData.guess !== undefined ? typeof modelData.guess === "string" ? "'" + modelData.guess + "'" : modelData.guess : "None"
                        color: modelData !== undefined ? modelData.guessIsValid ? Material.color(Material.Green, Material.Shade500) : Material.color(Material.Red, Material.Shade500) : Material.foreground
                        Behavior on color { ColorAnimation { duration: 100 } }

                        editTools: M.TextField {
                            id: editGuessField
                            labelText: "Guessed Value"
                            onAccepted: guessLabel.popup.accept()
                        }

                        onEditClicked: { editGuessField.text = text; editGuessField.selectAll(); editGuessField.focus = true }
                        onEditAccepted: modelData.setGuessWithEval(editGuessField.text)
                    }

                    CheckBox {
                        id: useCheck
                        Layout.leftMargin: 56
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.preferredWidth: layout.columns[4].width
                    }

                    CheckBox {
                        id: saveCheck
                        Layout.leftMargin: 24
                        Layout.rightMargin: 24
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.preferredWidth: layout.columns[5].width
                    }
                }
            }
        }
    }
}
