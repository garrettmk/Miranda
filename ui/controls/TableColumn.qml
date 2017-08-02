import QtQuick 2.7
import QtQuick.Controls 2.1
import "." as M


Item {
    id: root

    property string title
    property int columnWidth: 100
    property int alignment: Qt.AlignLeft
    property Component delegate
}
