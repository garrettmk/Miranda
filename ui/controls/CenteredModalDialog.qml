import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


Dialog {
    modal: true
    padding: 24

    Material.theme: parent.Material.theme
    Material.primary: parent.Material.primary
    Material.foreground: parent.Material.foreground
    Material.background: parent.Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)
    Material.accent: parent.Material.accent

    onAboutToShow: {
        x = mapFromItem(ApplicationWindow.overlay, ApplicationWindow.window.width / 2 - width / 2, 0).x
        y = mapFromItem(ApplicationWindow.overlay, 0, ApplicationWindow.window.height / 2 - height / 2).y
    }
}
