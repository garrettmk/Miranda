import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "controls" as M
import Product 1.0
import ObjectModel 1.0
import GetMatchingProductForId 1.0
import GetCompetitivePricingForASIN 1.0
import GetMyFeesEstimate 1.0
import ItemLookup 1.0


M.CenteredModalDialog {
    id: root
    title: "Edit Product"
    standardButtons: Dialog.Save | Dialog.Cancel

    implicitWidth: 900
    implicitHeight: 800
    leftPadding: 0
    rightPadding: 0

    property Product product

    onProductChanged: {
        if (product !== null && product !== undefined) {
            titleField.text = product.title !== undefined ? product.title : ""
            detailPageUrlField.text = product.detailPageUrl !== undefined ? product.detailPageUrl : ""
            imageUrlField.text = product.imageUrl !== undefined ? product.imageUrl : ""
            vendorBox.currentVendor = product.vendor
            skuField.text = product.sku !== undefined ? product.sku : ""
            chipEditor.model = product.tags
            categoryField.text = product.category !== undefined ? product.category : ""
            rankField.text = product.rank !== undefined ? product.rank : ""
            feedbackField.text = product.feedback !== undefined ? (product.feedback * 100).toFixed() + "%" : ""
            brandField.text = product.brand !== undefined ? product.brand : ""
            modelField.text = product.model !== undefined ? product.model : ""
            upcField.text = product.upc !== undefined ? product.upc : ""
            priceField.text = product.price !== undefined ? product.price.toFixed(2) : ""
            quantityField.text = product.quantity !== undefined ? product.quantity : ""
            marketFeesField.text = product.marketFees !== undefined ? product.marketFees.toFixed(2) : ""
            descriptionField.text = product.description !== undefined ? product.description : ""
        } else {
            titleField.text = ""
            detailPageUrlField.text = ""
            imageUrlField.text = ""
            vendorBox.currentIndex = 0
            skuField.text = ""
            chipEditor.model = []
            categoryField.text = ""
            rankField.text = ""
            feedbackField.text = ""
            brandField.text = ""
            modelField.text = ""
            upcField.text = ""
            priceField.text = ""
            quantityField.text = ""
            marketFeesField.text = ""
            descriptionField.text = ""
        }
    }

    onAccepted: {
        if (product !== null & product !== undefined) {
            product.title = titleField.text ? titleField.text : undefined
            product.detailPageUrl = detailPageUrlField.text ? detailPageUrlField.text : undefined
            product.imageUrl = imageUrlField.text ? imageUrlField.text : undefined
            product.vendor.ref = vendorBox.currentVendor
            product.sku = skuField.text ? skuField.text : undefined
            product.tags = chipEditor.model
            product.category = categoryField.text ? categoryField.text : undefined
            product.rank = rankField.text ? parseInt(rankField.text) : undefined
            product.feedback = feedbackField.text ? parseFloat(feedbackField.text) / 100 : undefined
            product.brand = brandField.text ? brandField.text : undefined
            product.model = modelField.text ? modelField.text : undefined
            product.upc = upcField.text ? upcField.text : undefined
            product.price = priceField.text ? parseFloat(priceField.text) : undefined
            product.quantity = quantityField.text ? parseInt(quantityField.text) : undefined
            product.marketFees = marketFeesField.text ? parseFloat(marketFeesField.text) : undefined
            product.description = descriptionField.text ? descriptionField.text : undefined
        }
    }

    property GetMatchingProductForId getMatchingProductForId: GetMatchingProductForId {
        onSucceededChanged: {
            if (succeeded) {
                titleField.text = products[0]["title"]
                detailPageUrlField.text = product[0]["detail_page_url"]
                imageUrlField.text = products[0]["image_url"]
                categoryField.text = products[0]["category"]
                rankField.text = products[0]["rank"]
                brandField.text = products[0]["brand"]
                modelField.text = products[0]["model"]
                priceField.text = products[0]["price"]
                descriptionField.text = products[0]["description"]
            }
        }
    }

    property GetCompetitivePricingForASIN getCompetitivePricingForASIN: GetCompetitivePricingForASIN {
        onSucceededChanged: {
            if (succeeded) {
                var price = prices[0]

                if (price["landed_price"] !== undefined)
                    priceField.text = price["landed_price"]
                else if (price["listing_price"] !== undefined)
                    priceField.text = price["listing_price"] + price["shipping"]
            }
        }
    }

    property GetMyFeesEstimate getMyFeesEstimate: GetMyFeesEstimate {
        onSucceededChanged: {
            if (succeeded) {
                marketFeesField.text = feeTotals[0]["market_fees"].toFixed(2)
            }
            else
                marketFeesField.text = ""
        }
    }

    property ItemLookup itemLookup: ItemLookup {
        onSucceededChanged: {
            if (succeeded) {
                var data = products[0]
                titleField.text = data["title"]
                detailPageUrlField.text = data["detail_page_url"]
                imageUrlField.text = data["image_url"]
                rankField.text = data["rank"]
                brandField.text = data["brand"]
                modelField.text = data["model"]
                priceField.text = data["price"]
                descriptionField.text = data["description"]
            }
        }
    }

    // Body
    M.ProductImage {
        id: imageBox
        source: imageUrlField.text

        implicitWidth: parent.width / 4
        implicitHeight: width

        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 24
        }
    }

    GridLayout {
        id: topLayout
        columns: 3
        rowSpacing: 0
        columnSpacing: 32
        anchors {
            top: parent.top
            left: parent.left
            right: imageBox.left
            rightMargin: 32
            leftMargin: 24
        }

        M.SystemIcon {
            source: "icons/title.png"
            Layout.topMargin: 30
        }

        M.TextField {
            id: titleField
            labelText: "Title"
            autoScroll: false

            Layout.columnSpan: 2
            Layout.fillWidth: true
        }

        M.SystemIcon {
            source: "icons/web.png"
            Layout.topMargin: 30
        }

        M.TextField {
            id: detailPageUrlField
            labelText: "Detail page URL"
            autoScroll: false
            Layout.fillWidth: true
        }

        M.TextField {
            id: imageUrlField
            labelText: "Image URL"
            autoScroll: false
            Layout.fillWidth: true
        }

        M.SystemIcon {
            source: "icons/vendor.png"
            Layout.topMargin: 32
        }

        StackLayout {
            Layout.fillWidth: true
            currentIndex: product !== null && !product.hasId

            M.TextField {
                labelText: "Vendor"
                text: vendorBox.currentText
                readOnly: true
            }

            Item {
                VendorComboBox {
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
            Layout.fillWidth: true
            suffix: M.TinyIconButton {
                enabled: vendorBox.currentText == "Amazon"
                iconSource: "icons/amazon.png"
                onClicked: amzApiMenu.open()

                Menu {
                    id: amzApiMenu

                    MenuItem {
                        text: "ItemLookup"
                        onTriggered: {
                            itemLookup.asins = [skuField.text]
                            application.amazonPA.enqueue(itemLookup)
                        }
                    }

                    MenuItem {
                        text: "GetMatchingProductForId"
                        onTriggered: {
                            getMatchingProductForId.asins = [skuField.text]
                            application.amazonMWS.enqueue(getMatchingProductForId)
                        }
                    }

                    MenuItem {
                        text: "GetCompetitivePricingForASIN"
                        onTriggered: {
                            getCompetitivePricingForASIN.asins = [skuField.text]
                            application.amazonMWS.enqueue(getCompetitivePricingForASIN)
                        }
                    }

                }
            }
        }

        M.SystemIcon {
            source: "icons/tag.png"
            Layout.topMargin: 30
        }

        M.ChipEditor {
            id: chipEditor
            model: product !== null ? product.tags : []
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 36
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
    }

    StackLayout {
        currentIndex: tabbar.currentIndex
        anchors {
            top: tabbar.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            margins: 24
        }

        Item {
            GridLayout {
                columns: 4
                rowSpacing: 0
                columnSpacing: 32
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                M.SystemIcon {
                    source: "icons/feedback.png"
                    Layout.topMargin: 30
                }

                M.TextField {
                    id: categoryField
                    labelText: "Category"
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: rankField
                    labelText: "Rank"
                    Layout.fillWidth: true
                    validator: IntValidator {
                        bottom: 0
                    }
                }

                M.TextField {
                    id: feedbackField
                    labelText: "Feedback"
                    Layout.fillWidth: true
                }

                M.SystemIcon {
                    source: "icons/features.png"
                    Layout.topMargin: 30
                }

                M.TextField {
                    id: brandField
                    labelText: "Brand"
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: modelField
                    labelText: "Model"
                    Layout.fillWidth: true
                }

                M.TextField {
                    id: upcField
                    labelText: "UPC"
                    Layout.fillWidth: true
                }

                M.SystemIcon {
                    source: "icons/money.png"
                    Layout.topMargin: 30
                }

                M.TextField {
                    id: priceField
                    labelText: "Price"
                    prefix: M.Label {type: "Body 1"; text: "$"; opacity: 0.50}
                    Layout.fillWidth: true
                    validator: DoubleValidator {
                        bottom: 0
                        decimals: 2
                    }
                }

                M.TextField {
                    id: quantityField
                    labelText: "Quantity"
                    Layout.fillWidth: true
                    validator: IntValidator { bottom: 1 }
                }

                M.TextField {
                    id: marketFeesField
                    labelText: "Market Fees"
                    Layout.fillWidth: true
                    prefix: M.Label { type: "Body 1"; text: "$"; opacity: Material.theme === Material.Light ? 0.38 : 0.50 }
                    suffix: M.TinyIconButton {
                        iconSource: "icons/wand.png"
                        onClicked: {
                            getMyFeesEstimate.asins = [skuField.text]
                            getMyFeesEstimate.prices = [parseFloat(priceField.text)]
                            application.amazonMWS.enqueue(getMyFeesEstimate)
                        }
                    }
                    validator: DoubleValidator {
                        bottom: 0
                        decimals: 2
                    }
                }
            }
        }

        TextArea {
            id: descriptionField
            placeholderText: "Product description"
            wrapMode: Text.Wrap
        }
    }
}
