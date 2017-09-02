import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0
import PriceValidator 1.0
import QuantityValidator 1.0
import RankValidator 1.0


ObjectCard {
    id: card

    property string vendorName
    property alias interactive: mediaItemView.interactive

    mediaItem: Rectangle {
        color: Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)
        anchors.fill: parent

        SwipeView {
            id: mediaItemView
            anchors.fill: parent

            M.ProductImage {
                source: imageUrl
            }

            Loader {
                focus: true
                active: active || SwipeView.isCurrentItem
                sourceComponent: Item {
                    ColumnLayout {
                        spacing: 0
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 0
                        }

                        M.ChipEditor {
                            id: chipEditor
                            model: tags
                            readOnly: true
                            Layout.fillWidth: true
                            Layout.margins: 24
                        }

                        M.Divider {Layout.fillWidth: true}

                        GridLayout {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.margins: 24
                            rows: 5
                            flow: GridLayout.TopToBottom
                            columnSpacing: 32
                            rowSpacing: 8

                            // Column 1
                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Vendor:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "SKU:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Category:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Rank:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Feedback:"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: vendorName
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: sku !== undefined ? sku : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: category !== undefined ? category : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: rank !== undefined ? rank.toLocaleString() : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: feedback !== undefined ? feedback : "n/a"
                            }

                            // Column 2
                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Brand:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Model:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "UPC:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Price:"
                            }

                            M.Label {
                                type: "Body 2"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                Layout.alignment: Qt.AlignRight
                                text: "Quantity:"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: brand !== undefined ? brand : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: model !== undefined ? model : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: upc !== undefined ? upc : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: price !== undefined ? "$" + price.toLocaleString() : "n/a"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: quantity !== undefined ? quantity.toLocaleString() : "n/a"
                            }
                        }
                    }
                }
            }

            // Description tab
            Loader {
                focus: true
                active: active || SwipeView.isCurrentItem
                sourceComponent: Item {
                    id: descriptionItem
                    state: "Locked"
                    states: [
                        State {
                            name: "Locked"
                            PropertyChanges {
                                target: descFlickable
                                interactive: false
                                contentWidth: width
                                contentHeight: height
                                contentX: 0
                                contentY: 0
                            }
                        },
                        State {
                            name: "Unlocked"
                            PropertyChanges {
                                target: descFlickable
                                interactive: true
                                contentWidth: descriptionText.contentWidth
                                contentHeight: descriptionText.contentHeight
                            }
                        }
                    ]
                    Flickable {
                        id: descFlickable
                        interactive: false
                        anchors.fill: parent
                        anchors.margins: 48
                        rightMargin: 48

                        Label {
                            id: descriptionText
                            anchors.fill: parent
                            text: description !== undefined ? description : "n/a"
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                        }
                    }
                    M.IconToolButton {
                        iconSource: descriptionItem.state === "Locked" ? "../icons/lock_closed.png" : "../icons/lock_open.png"
                        onClicked: descriptionItem.state === "Locked" ? descriptionItem.state = "Unlocked" : descriptionItem.state = "Locked"
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                        }
                    }

                    Connections {
                        target: card.ListView.view
                        onMovingVerticallyChanged: if (card.ListView.view.movingVertically) descriptionItem.state = "Locked"
                    }
                }
            }
        }

        PageIndicator {
            id: pageIndicator
            count: mediaItemView.count
            currentIndex: mediaItemView.currentIndex
            opacity: mediaItemView.interactive
            Behavior on opacity { OpacityAnimator { duration: 100 } }

            anchors {
                bottom: mediaItemView.bottom
                horizontalCenter: mediaItemView.horizontalCenter
            }

            delegate: Rectangle {
                implicitWidth: 8
                implicitHeight: 8
                radius: 4
                color: Material.primary
                opacity: index === pageIndicator.currentIndex ? 0.95 : pressed ? 1.0 : 0.45
                Behavior on opacity {
                    OpacityAnimator {
                        duration: 100
                    }
                }
            }
        }


    }

    headlineItem: ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.Label {
                type: "Headline"
                textFormat: Text.StyledText
                linkColor: Material.foreground
                text: title !== undefined ? detailPageUrl !== undefined ? "<a href=\'" + detailPageUrl + "\'>" + title + "</a>" : title : "n/a"
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.rightMargin: 56

                onLinkActivated: Qt.openUrlExternally(link)
            }

            M.Label {
                type: "Headline"
                text: price !== undefined ? "$" + price.toFixed(2) : "n/a"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.Label {
                type: "Body 1"
                text: sku !== undefined ? vendorName + ": " + sku : vendorName + ": n/a"
                opacity: Material.theme === Material.Light ? 0.54 : 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.rightMargin: 56
            }

            M.Label {
                type: "Body 1"
                text: quantity !== undefined ? "per " + quantity.toLocaleString() : "n/a"
            }
        }

        M.Label {
            type: "Body 1"
            text: "Rank: " + (rank !== undefined ? rank.toLocaleString() : "n/a") + " in " + (category !== undefined ? category : "Uncategorized")
            opacity: Material.theme === Material.Light ? 0.54 : 0.7
            elide: Text.ElideRight
        }
    }
}
