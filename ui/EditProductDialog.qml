import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0
import ObjectModel 1.0


Dialog {
    id: dialog
    modal: true
    title: "Edit Product"
    standardButtons: Dialog.Save | Dialog.Cancel

    x: ApplicationWindow.window.width / 2 - (width / 2)
    y: ApplicationWindow.window.height / 2 - (height / 2)
    implicitWidth: 900
    implicitHeight: 900
    leftPadding: 0
    rightPadding: 0

    property Product product
    property ObjectModel vendors

    // Methods
    onOpened: {
        vendors = database.getModel(database.newVendorQuery())
        var names = []
        for (var i=0; i<vendors.length; i++) {
            names.push(vendors.getObject(i).title)
        }
        vendorBox.model = names
    }

    onAccepted: {
        console.log(product)
        if (product !== null) {
            product.tags = chipEditor.model
            product.title = titleField.text
            product.detailPageUrl = detailPageUrlField.text
            product.imageUrl = imageUrlField.text
            if (!product.hasId) {
                product.vendor.ref = vendors.getObject(vendorBox.currentIndex)
            }
            product.sku = skuField.text
            product.category = categoryField.text
            product.rank = rankField.text
            product.feedback = feedbackField.text
            product.brand = brandField.text
            product.model = modelField.text
            product.upc = upcField.text
            product.price = priceField.text
            product.quantity = quantityField.text
            product.description = descriptionField.text
        }
    }

    // Body
    topPadding: 0

    M.ProductImage {
        id: imageBox
        source: imageUrlField.text

        implicitWidth: parent.width / 4
        implicitHeight: width

        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 16
        }
    }

    ColumnLayout {
        id: topLayout
        spacing: 0
        anchors {
            left: parent.left
            right: imageBox.left
            top: parent.top
            rightMargin: 32
        }

        GridLayout {
            columns: 3
            rowSpacing: 0
            columnSpacing: 0
            Layout.leftMargin: 32
            Layout.fillWidth: true

            M.SystemIcon {
                source: "icons/title.png"

                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 4
            }

            M.TextField {
                id: titleField
                labelText: "Title"
                text: product !== null ? product.title : ""

                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.SystemIcon {
                source: "icons/web.png"

                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 32
            }

            M.TextField {
                id: detailPageUrlField
                labelText: "Detail page URL"
                text: product !== null ? product.detailPageUrl : ""
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.TextField {
                id: imageUrlField
                labelText: "Image URL"
                text: product !== null ? product.imageUrl : ""
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.SystemIcon {
                source: "icons/vendor.png"

                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 32
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 32
                currentIndex: product !== null && !product.hasId

                M.TextField {
                    labelText: "Vendor"
                    text: vendorBox.currentText
                    readOnly: true
                }

                Item {
                    ComboBox {
                        id: vendorBox
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: 12
                        }
                    }
                }
            }

            M.TextField {
                id: skuField
                labelText: "SKU"
                text: product !== null ? product.sku : ""
                Layout.fillWidth: true
                Layout.leftMargin: 32
            }

            M.SystemIcon {
                source: "icons/tag.png"

                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 32
            }

            M.ChipEditor {
                id: chipEditor
                model: product !== null ? product.tags : []
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 28
                Layout.leftMargin: 32
           }
        }
    }

    TabBar {
        id: tabbar
        y: Math.max(topLayout.y + topLayout.height, imageBox.y + imageBox.height) + 32
        anchors {
            left: parent.left
            right: parent.right
        }

        background: Rectangle {
            color: "transparent"
        }

        TabButton {
            text: "Specifications"
        }

        TabButton {
            text: "Description"
        }

        TabButton {
            text: "Associations"
        }

        TabButton {
            text: "Matches"
        }
    }

    StackLayout {
        currentIndex: tabbar.currentIndex
        anchors {
            top: tabbar.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            leftMargin: 32
            rightMargin: 32
        }

        Item {
            GridLayout {
                columns: 4
                rowSpacing: 0
                columnSpacing: 0
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                M.SystemIcon {
                    source: "icons/feedback.png"

                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 4
                }

                M.TextField {
                    id: categoryField
                    labelText: "Category"
                    text: product !== null ? product.category : ""
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: rankField
                    labelText: "Rank"
                    text: product !== null ? product.rank.toLocaleString() : ""
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: feedbackField
                    labelText: "Feedback"
                    text: product !== null ? product.feedback.toLocaleString() : ""
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.SystemIcon {
                    source: "icons/features.png"

                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 4
                }

                M.TextField {
                    id: brandField
                    labelText: "Brand"
                    text: product !== null ? product.brand : ""
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: modelField
                    labelText: "Model"
                    text: product !== null ? product.model : ""
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: upcField
                    labelText: "UPC"
                    text: product !== null ? product.upc : ""
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.SystemIcon {
                    source: "icons/money.png"

                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 4
                }

                M.TextField {
                    id: priceField
                    labelText: "Price"
                    text: product !== null ? product.price.toLocaleString() : "0.00"
                    prefix: Label {text: "$"; opacity: Material.theme === Material.Light ? 0.38 : 0.50}
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: quantityField
                    labelText: "Quantity"
                    text: product !== null ? product.quantity.toLocaleString() : "0"
                    Layout.leftMargin: 32
                    Layout.fillWidth: true
                }
            }
        }

        TextArea {
            id: descriptionField
            text: product !== null ? product.description : ""
            placeholderText: "Product description"
        }
    }
}
