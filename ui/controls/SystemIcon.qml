import QtQuick 2.7
import QtQuick.Controls.Material 2.1

Image {
    id: root
    sourceSize {
        width: 24
        height: 24
    }

    state: "ActiveUnfocused"
    states: [
        State {
            name: "ActiveUnfocused"
            PropertyChanges {
                target: root
                opacity: Material.theme === Material.Light ? 0.54 : 0.70
            }
        },
        State {
            name: "ActiveFocused"
            PropertyChanges {
                target: root
                opacity: Material.theme === Material.Light ? 0.87 : 1.0
            }
        },
        State {
            name: "Inactive"
            PropertyChanges {
                target: root
                opacity: Material.theme === Material.Light ? 0.38 : 0.50
            }
        }
    ]
}
