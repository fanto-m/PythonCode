// ItemSuppliersDialog.qml - Диалог просмотра поставщиков товара
// Расположение: qml/components/dialogs/items/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Поставщики товара"
    modal: true
    width: 700
    height: 500
    anchors.centerIn: parent

    // === СВОЙСТВА ===
    property string currentArticle: ""
    property int supplierCount: 0

    // === ЗАГОЛОВОК ===
    header: Item {
        height: 50

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 8
            color: "white"
            radius: Theme.smallRadius

            AppLabel {
                text: root.title
                level: "h3"
                anchors.centerIn: parent
                enterDelay: 0
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                height: 1
                color: Theme.inputBorder
            }
        }
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    contentItem: Rectangle {
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // --- Информационная панель ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Theme.backgroundColor
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius

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

                        AppLabel {
                            text: "Артикул: " + currentArticle
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        AppLabel {
                            text: "Поставщиков: " + supplierCount
                            level: "caption"
                            enterDelay: 0
                        }
                    }
                }
            }

            // --- ComboBox для выбора поставщика ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: supplierCount > 0

                AppLabel {
                    text: "Выберите поставщика:"
                    level: "body"
                    font.bold: true
                    Layout.preferredWidth: 160
                    enterDelay: 0
                }

                AppComboBox {
                    id: supplierComboBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    model: itemSuppliersModel
                    textRole: "company"

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
                            font: Theme.defaultFont
                            color: Theme.textColor
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        highlighted: supplierComboBox.highlightedIndex === index

                        background: Rectangle {
                            color: highlighted ? Theme.accentColor : "white"
                            opacity: highlighted ? 0.3 : 1
                        }
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
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius
                visible: supplierCount > 0

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true

                    GridLayout {
                        width: parent.width
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10

                        // ID
                        AppLabel {
                            text: "ID:"
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        AppLabel {
                            id: idLabel
                            text: "-"
                            Layout.fillWidth: true
                            level: "body"
                            enterDelay: 0
                        }

                        // ФИО
                        AppLabel {
                            text: "ФИО:"
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        AppLabel {
                            id: nameLabel
                            text: "-"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            level: "body"
                            enterDelay: 0
                        }

                        // Компания
                        AppLabel {
                            text: "Компания:"
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        AppLabel {
                            id: companyLabel
                            text: "-"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        // Email
                        AppLabel {
                            text: "Email:"
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        Text {
                            id: emailLabel
                            text: "-"
                            Layout.fillWidth: true
                            font.family: Theme.defaultFont.family
                            font.pixelSize: Theme.defaultFont.pixelSize
                            font.underline: text !== "-" && text !== ""
                            color: (text !== "-" && text !== "") ? Theme.highlightColor : Theme.textColor

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: (emailLabel.text !== "-" && emailLabel.text !== "") ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: emailLabel.text !== "-" && emailLabel.text !== ""
                                hoverEnabled: true
                                onEntered: if (enabled) emailLabel.color = Qt.darker(Theme.highlightColor, 1.2)
                                onExited: if (enabled) emailLabel.color = Theme.highlightColor
                                onClicked: {
                                    if (emailLabel.text !== "-" && emailLabel.text !== "") {
                                        Qt.openUrlExternally("mailto:" + emailLabel.text)
                                    }
                                }
                            }
                        }

                        // Телефон
                        AppLabel {
                            text: "Телефон:"
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        Text {
                            id: phoneLabel
                            text: "-"
                            Layout.fillWidth: true
                            font.family: Theme.defaultFont.family
                            font.pixelSize: Theme.defaultFont.pixelSize
                            font.underline: text !== "-" && text !== ""
                            color: (text !== "-" && text !== "") ? Theme.highlightColor : Theme.textColor

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: (phoneLabel.text !== "-" && phoneLabel.text !== "") ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: phoneLabel.text !== "-" && phoneLabel.text !== ""
                                hoverEnabled: true
                                onEntered: if (enabled) phoneLabel.color = Qt.darker(Theme.highlightColor, 1.2)
                                onExited: if (enabled) phoneLabel.color = Theme.highlightColor
                                onClicked: {
                                    if (phoneLabel.text !== "-" && phoneLabel.text !== "") {
                                        Qt.openUrlExternally("tel:" + phoneLabel.text)
                                    }
                                }
                            }
                        }

                        // Сайт
                        AppLabel {
                            text: "Сайт:"
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        Text {
                            id: websiteLabel
                            text: "-"
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAnywhere
                            font.family: Theme.defaultFont.family
                            font.pixelSize: Theme.defaultFont.pixelSize
                            property bool hasWebsite: text !== "-" && text.trim() !== ""
                            font.underline: hasWebsite
                            color: hasWebsite ? Theme.highlightColor : Theme.textColor

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: websiteLabel.hasWebsite ? Qt.PointingHandCursor : Qt.ArrowCursor
                                hoverEnabled: true
                                onEntered: if (websiteLabel.hasWebsite) websiteLabel.color = Qt.darker(Theme.highlightColor, 1.2)
                                onExited: if (websiteLabel.hasWebsite) websiteLabel.color = Theme.highlightColor
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
                color: Theme.backgroundColor
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius
                visible: supplierCount === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "📭"
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignHCenter
                    }

                    AppLabel {
                        text: "Нет привязанных поставщиков"
                        level: "body"
                        font.italic: true
                        color: Theme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                        enterDelay: 0
                    }
                }
            }
        }
    }

    // === КНОПКИ ===
    footer: Item {
        height: 60

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 8
            color: Theme.backgroundColor
            radius: Theme.smallRadius

            AppButton {
                anchors.centerIn: parent
                text: "Закрыть"
                implicitWidth: 120
                implicitHeight: 40
                btnColor: Theme.backgroundColor
                enterDelay: 0

                contentItem: Text {
                    text: parent.text
                    font: Theme.defaultFont
                    color: Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                    border.color: Theme.inputBorder
                    border.width: 1
                    radius: Theme.smallRadius
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                onClicked: root.close()
            }
        }
    }

    // === АНИМАЦИИ ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.9; duration: 150; easing.type: Easing.InCubic }
        }
    }

    // === ФУНКЦИИ ===

    // Обновление деталей поставщика
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

    // Открытие диалога для артикула
    function openFor(article) {
        console.log("Opening suppliers dialog for article:", article)
        currentArticle = article

        itemSuppliersModel.setArticle(article)
        supplierUpdateTimer.restart()
        open()
    }

    // Timer для асинхронного обновления модели
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

    // Обновление при открытии
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
