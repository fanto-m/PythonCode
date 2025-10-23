// components/ItemSuppliersDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: itemSuppliersDialog
    title: "Поставщики товара"
    modal: true
    width: 550
    height: 550

    property string currentArticle: ""
    property int supplierCount: 0

    // Основной контент
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // --- Информационная панель ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "📦"
                    font.pixelSize: 24
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Label {
                        text: "Артикул: " + currentArticle
                        font.bold: true
                        font.pointSize: 11
                    }
                    Label {
                        text: "Поставщиков: " + supplierCount
                        font.pointSize: 10
                        color: "#6c757d"
                    }
                }
            }
        }

        // --- ComboBox для выбора поставщика ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: supplierCount > 0

            Label {
                text: "Выберите\nпоставщика:"
                font.bold: true
                Layout.preferredWidth: 150
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: supplierComboBox
                Layout.fillWidth: true
                model: itemSuppliersModel
                textRole: "company"

                background: Rectangle {
                    color: "white"
                    border.color: supplierComboBox.pressed ? "#007bff" : "#ced4da"
                    border.width: 1
                    radius: 4
                }

                onCurrentIndexChanged: {
                    updateSupplierDetails()
                }

                delegate: ItemDelegate {
                    width: supplierComboBox.width
                    contentItem: Text {
                        text: {
                            var companyText = model.company || "Не указана"
                            var nameText = model.name || ""
                            return nameText ? (companyText + " - " + nameText) : companyText
                        }
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font.pixelSize: 12
                    }
                    highlighted: supplierComboBox.highlightedIndex === index
                }

                displayText: {
                    if (currentIndex >= 0 && supplierCount > 0) {
                        var supplier = itemSuppliersModel.get(currentIndex)
                        return supplier.company || "Не указана"
                    }
                    return "Выберите поставщика"
                }
            }
        }

        // --- Детальная информация о выбранном поставщике ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
            border.color: "#dee2e6"
            border.width: 1
            radius: 4
            visible: supplierCount > 0

            ScrollView {
                anchors.fill: parent
                anchors.margins: 15
                clip: true

                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 12

                    // ID
                    Label {
                        text: "ID:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#495057"
                    }
                    Label {
                        id: idLabel
                        text: "-"
                        Layout.fillWidth: true
                        font.pixelSize: 14
                    }

                    // ФИО
                    Label {
                        text: "ФИО:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#495057"
                    }
                    Label {
                        id: nameLabel
                        text: "-"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                    }

                    // Компания
                    Label {
                        text: "Компания:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#495057"
                    }
                    Label {
                        id: companyLabel
                        text: "-"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        font.bold: true
                    }

                    // Email
                    Label {
                        text: "Email:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#495057"
                    }
                    Label {
                        id: emailLabel
                        text: "-"
                        Layout.fillWidth: true
                        font.pixelSize: 14
                        color: (emailLabel.text !== "-" && emailLabel.text !== "") ? "#007bff" : "black"
                        font.underline: emailLabel.text !== "-" && emailLabel.text !== ""

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: (emailLabel.text !== "-" && emailLabel.text !== "") ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: emailLabel.text !== "-" && emailLabel.text !== ""
                            hoverEnabled: true
                            onEntered: {
                                if (enabled) emailLabel.color = "#0056b3"
                            }
                            onExited: {
                                if (enabled) emailLabel.color = "#007bff"
                            }
                            onClicked: {
                                if (emailLabel.text !== "-" && emailLabel.text !== "") {
                                    Qt.openUrlExternally("mailto:" + emailLabel.text)
                                }
                            }
                        }
                    }

                    // Телефон
                    Label {
                        text: "Телефон:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#495057"
                    }
                    Label {
                        id: phoneLabel
                        text: "-"
                        Layout.fillWidth: true
                        font.pixelSize: 14
                        color: (phoneLabel.text !== "-" && phoneLabel.text !== "") ? "#007bff" : "black"
                        font.underline: phoneLabel.text !== "-" && phoneLabel.text !== ""

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: (phoneLabel.text !== "-" && phoneLabel.text !== "") ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: phoneLabel.text !== "-" && phoneLabel.text !== ""
                            hoverEnabled: true
                            onEntered: {
                                if (enabled) phoneLabel.color = "#0056b3"
                            }
                            onExited: {
                                if (enabled) phoneLabel.color = "#007bff"
                            }
                            onClicked: {
                                if (phoneLabel.text !== "-" && phoneLabel.text !== "") {
                                    Qt.openUrlExternally("tel:" + phoneLabel.text)
                                }
                            }
                        }
                    }

                    // Сайт
                    Label {
                        text: "Сайт:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#495057"
                    }
                    Label {
                        id: websiteLabel
                        text: "-"
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAnywhere
                        font.pixelSize: 14
                        color: {
                            var hasWebsite = websiteLabel.text !== "-" && websiteLabel.text.trim() !== ""
                            return hasWebsite ? "#007bff" : "black"
                        }
                        font.underline: websiteLabel.text !== "-" && websiteLabel.text.trim() !== ""

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: {
                                var hasWebsite = websiteLabel.text !== "-" && websiteLabel.text.trim() !== ""
                                return hasWebsite ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                            hoverEnabled: true
                            onEntered: {
                                var hasWebsite = websiteLabel.text !== "-" && websiteLabel.text.trim() !== ""
                                if (hasWebsite) websiteLabel.color = "#0056b3"
                            }
                            onExited: {
                                var hasWebsite = websiteLabel.text !== "-" && websiteLabel.text.trim() !== ""
                                if (hasWebsite) websiteLabel.color = "#007bff"
                            }
                            onClicked: {
                                var urlText = websiteLabel.text.trim()
                                if (urlText !== "-" && urlText !== "") {
                                    var url = urlText
                                    if (!url.startsWith("http://") && !url.startsWith("https://")) {
                                        url = "https://" + url
                                    }
                                    console.log("Opening URL:", url)
                                    Qt.openUrlExternally(url)
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- Сообщение если нет поставщиков ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 4
            visible: supplierCount === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "📭"
                    font.pixelSize: 48
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Нет привязанных поставщиков"
                    font.italic: true
                    font.pointSize: 12
                    color: "#6c757d"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    // Кнопки в footer
    footer: DialogButtonBox {
        Button {
            text: "Закрыть"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            background: Rectangle {
                color: parent.down ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "white")
                radius: 4
                border.color: "#ced4da"
                border.width: 1
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 12
                color: "#495057"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        onRejected: itemSuppliersDialog.close()
    }

    // --- Функция обновления деталей ---
    function updateSupplierDetails() {
        console.log("updateSupplierDetails called, currentIndex:", supplierComboBox.currentIndex, "count:", supplierCount)

        if (supplierComboBox.currentIndex >= 0 && supplierCount > 0) {
            var supplier = itemSuppliersModel.get(supplierComboBox.currentIndex)
            console.log("Supplier data:", JSON.stringify(supplier))

            idLabel.text = (supplier.id !== undefined && supplier.id !== null && supplier.id !== -1)
                ? String(supplier.id) : "-"
            nameLabel.text = supplier.name || "-"
            companyLabel.text = supplier.company || "-"
            emailLabel.text = supplier.email || "-"
            phoneLabel.text = supplier.phone || "-"
            websiteLabel.text = supplier.website || "-"
        } else {
            idLabel.text = "-"
            nameLabel.text = "-"
            companyLabel.text = "-"
            emailLabel.text = "-"
            phoneLabel.text = "-"
            websiteLabel.text = "-"
        }
    }

    // --- Функция открытия диалога ---
    function openFor(article) {
        console.log("Opening suppliers dialog for article:", article)
        currentArticle = article

        itemSuppliersModel.setArticle(article)
        supplierUpdateTimer.restart()
        open()
    }

    // Timer to handle async model updates
    Timer {
        id: supplierUpdateTimer
        interval: 50
        repeat: false
        onTriggered: {
            supplierCount = itemSuppliersModel.rowCount()
            console.log("Supplier count updated:", supplierCount)

            if (supplierCount > 0) {
                supplierComboBox.currentIndex = 0
                updateSupplierDetails()
            }
        }
    }

    // Update count when dialog becomes visible
    onVisibleChanged: {
        if (visible) {
            supplierCount = itemSuppliersModel.rowCount()
            console.log("Dialog visible, supplier count:", supplierCount)
            if (supplierCount > 0) {
                updateSupplierDetails()
            }
        }
    }
}