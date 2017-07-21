import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0


ObjectCard {
    id: card

    property string vendorName

    mediaItem: Rectangle {
        color: Material.theme === Material.Light ? "white" : Material.color(Material.Grey, Material.Shade800)
        anchors.fill: parent

        Rectangle {
            id: tabDrawer
            color: Qt.rgba(Material.primary.r, Material.primary.g, Material.primary.b, 0.5)
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            height: mediaTabs.implicitHeight
            width: height
            z: 20

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }

            state: drawerMouseArea.containsMouse || mediaTabs.hovered ? "Open" : "Closed"
            states: [
                State {
                    name: "Closed"
                    PropertyChanges {
                        target: tabDrawer
                        width: tabDrawer.height
                    }
                    PropertyChanges {
                        target: drawerButton
                        visible: true
                    }
                    PropertyChanges {
                        target: mediaTabs
                        visible: false
                    }
                },
                State {
                    name: "Open"
                    PropertyChanges {
                        target: tabDrawer
                        width: tabDrawer.parent.width
                    }
                    PropertyChanges {
                        target: drawerButton
                        visible: false
                    }
                    PropertyChanges {
                        target: mediaTabs
                        visible: true
                    }
                }
            ]

            MouseArea {
                id: drawerMouseArea
                hoverEnabled: true
                anchors.fill: parent
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                M.SystemIcon {
                    id: drawerButton
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.margins: 4
                    source: "icons/arrow_left.png"
                }

                TabBar {
                    id: mediaTabs
                    background: Rectangle {color: "transparent"}
                    Layout.fillWidth: true

                    TabButton {
                        text: "Image"
                    }

                    TabButton {
                        text: "Details"
                    }

                    TabButton  {
                        text: "Desc"
                    }

                    TabButton {
                        text: "Matches"
                    }
                }
            }
        }

        StackLayout {
            anchors.fill: parent
            currentIndex: mediaTabs.currentIndex
            onCurrentIndexChanged: if (currentIndex > 0) children[currentIndex].active = true

            M.ProductImage {
                anchors.fill: parent
                source: imageUrl
            }

            Loader {
                focus: true
                active: false
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
                                text: "Food Equipment Company"
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: sku
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: category
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: rank
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: feedback
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
                                text: brand
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: model
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: upc
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: "$" + price.toLocaleString()
                            }

                            M.Label {
                                type: "Body 1"
                                opacity: Material.theme === Material.Light ? 0.54 : 0.70
                                text: quantity.toLocaleString()
                            }
                        }
                    }
                }
            }

            // Description tab
            Loader {
                focus: true
                active: false
                sourceComponent: Item {
                    TextArea {
                        anchors.fill: parent
                        anchors.margins: 24
                        readOnly: true
                        text: description
                    }
                }
            }

            // Matched Products
            Loader {
                focus: true
                active: false
                sourceComponent: Item {
                    M.Label {
                        anchors.centerIn: parent
                        type: "Caption"
                        text: "Not yet implemented. :("
                    }
                }
            }

            // History
            Loader {
                focus: true
                active: false
                sourceComponent: Item {
                    M.Label {
                        anchors.centerIn: parent
                        type: "Caption"
                        text: "Not yet implemented. :("
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
                text: "<a href=\'" + detailPageUrl + "\'>" + title + "</a>"
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.rightMargin: 56

                onLinkActivated: Qt.openUrlExternally(link)
            }

            M.Label {
                type: "Headline"
                text: "$" + price.toLocaleString()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            M.Label {
                type: "Body 1"
                text: vendorName + ": " + sku
                opacity: Material.theme === Material.Light ? 0.54 : 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.rightMargin: 56
            }

            M.Label {
                type: "Body 1"
                text: "per " + quantity.toLocaleString()
            }
        }

        M.Label {
            type: "Body 1"
            text: "Rank: " + rank.toLocaleString() + " in " + (category ? category : "Uncategorized")
            opacity: Material.theme === Material.Light ? 0.54 : 0.7
            elide: Text.ElideRight
        }
    }


    actionItem: TabBar {
        id: tabbar
        enabled: dropdownState === "Down"
        visible: enabled
        opacity: enabled ? 1 : 0
        background: Rectangle {color: "transparent"}

        TabButton {
            text: "Specs"
        }

        TabButton {
            text: "Desc"
        }

        TabButton {
            text: "Matches"
        }

        TabButton {
            text: "History"
        }
    }

    actionMenu: Menu {
        MenuItem {
            text: "Edit"
        }
    }
}
