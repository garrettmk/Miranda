import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


Label {
    height: 48
    leftPadding: 16
    rightPadding: 16
    verticalAlignment: Text.AlignVCenter
    font.weight: Font.Medium
    color: Material.theme === Material.Light ? "black" : "white"
    opacity: 0.54
}
