import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import "." as M

M.TextField {
    readOnly: true
    color: Material.theme === Material.Light ? "#8A000000" : "#AAFFFFFF"
    //background: null
}
