import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Label {
    opacity: 0
    property string type: "Body 1"

    Component.onCompleted: {
        if (type === "Display 4") {
            font.pointSize = 112
            font.weight = Font.Light
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Display 3") {
            font.pointSize = 56
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Display 2") {
            font.pointSize = 45
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Display 1") {
            font.pointSize = 34
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Headline") {
            font.pointSize = 24
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.87 : 1.0
        } else if (type === "Title") {
            font.pointSize = 20
            font.weight = Font.DemiBold
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.87 : 1.0
        } else if (type === "Subheading") {
            font.pointSize = 16
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.87 : 1.0
        } else if (type === "Subheading Light") {
            font.pointSize = 16
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Body 2") {
            font.pointSize = 14
            font.weight = Font.DemiBold
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.87 : 1.0
        } else if (type === "Body 2 Light") {
            font.pointSize = 14
            font.weight = Font.DemiBold
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Body 1") {
            font.pointSize = 14
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.87 : 1.0
        } else if (type === "Caption") {
            font.pointSize = 12
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Button") {
            font.pointSize = 14
            font.weight = Font.DemiBold
            font.capitalization = Font.AllUppercase
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.87 : 1.0
        } else if (type === "Column Header") {
            font.pointSize = 14
            font.weight = Font.DemiBold
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else if (type === "Chip") {
            font.pointSize = 13
            font.weight = Font.Normal
            if (opacity === 0) opacity = Material.theme === Material.Light ? 0.54 : 0.70
        } else {
            console.log("Unrecognized label type: " + type)
        }
    }
}
