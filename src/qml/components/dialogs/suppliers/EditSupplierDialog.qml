// qml/components/dialogs/suppliers/EditSupplierDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: editSupplierDialog
    title: "Редактировать поставщика"
    modal: true
    width: 600
    height: 600
    standardButtons: Dialog.NoButton

    property int supplierId: -1
    property bool hasErrors: false

    signal supplierEdited(int id, string name, string company, string email, string phone, string website)

    // 🎨 Header с перемещением
    header: Rectangle {
        width: parent.width
        height: 50
        color: Theme.primaryColor
        radius: Theme.defaultRadius

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.defaultRadius
            color: parent.color
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 10
            spacing: 10

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "☰"
                    color: Theme.textOnPrimary
                    font.pixelSize: 20
                    opacity: 0.7
                }

                Text {
                    anchors.centerIn: parent
                    text: editSupplierDialog.title
                    font: Theme.boldFont
                    color: Theme.textOnPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    property point clickPos: Qt.point(0, 0)

                    onPressed: function(mouse) {
                        clickPos = Qt.point(mouse.x, mouse.y)
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                            editSupplierDialog.x += delta.x
                            editSupplierDialog.y += delta.y
                        }
                    }
                }
            }

            ToolButton {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: "✕"
                font.pixelSize: 16
                font.bold: true

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: Theme.textOnPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? Qt.lighter(Theme.primaryColor, 1.2) : "transparent"
                    radius: Theme.smallRadius
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                onClicked: editSupplierDialog.reject()
            }
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Инфо блок
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: Theme.backgroundColor
                radius: Theme.defaultRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: "✏️"
                        font.pixelSize: 32
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        AppLabel {
                            text: "Редактирование поставщика"
                            level: "h3"
                            enterDelay: 0
                        }

                        AppLabel {
                            text: "ID: " + supplierId
                            level: "caption"
                            enterDelay: 50
                        }
                    }
                }
            }

            // Форма
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.parent.width - 20
                    spacing: 16

                    // Компания (обязательное)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        AppLabel {
                            text: "Компания *"
                            level: "h3"
                            enterDelay: 100
                        }

                        AppTextField {
                            id: companyField
                            Layout.fillWidth: true
                            placeholderText: "Введите название компании"
                            enterDelay: 150

                            validator: RegularExpressionValidator {
                                regularExpression: /.{2,}/
                            }

                            onTextChanged: validateForm()
                        }

                        AppLabel {
                            visible: companyField.text.trim().length > 0 && !companyField.acceptableInput
                            text: "⚠️ Название компании должно содержать минимум 2 символа"
                            level: "error"
                            enterDelay: 200
                        }
                    }

                    // ФИО
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        AppLabel {
                            text: "ФИО контактного лица"
                            level: "h3"
                            enterDelay: 250
                        }

                        AppTextField {
                            id: nameField
                            Layout.fillWidth: true
                            placeholderText: "Иванов Иван Иванович"
                            enterDelay: 300
                        }
                    }

                    // Email
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        AppLabel {
                            text: "Email"
                            level: "h3"
                            enterDelay: 350
                        }

                        AppTextField {
                            id: emailField
                            Layout.fillWidth: true
                            placeholderText: "example@company.com"
                            enterDelay: 400
                            inputMethodHints: Qt.ImhEmailCharactersOnly

                            validator: RegularExpressionValidator {
                                regularExpression: /^$|^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                            }

                            onTextChanged: validateForm()
                        }

                        AppLabel {
                            visible: emailField.text.trim().length > 0 && !emailField.acceptableInput
                            text: "⚠️ Введите корректный email адрес"
                            level: "error"
                            enterDelay: 450
                        }
                    }

                    // Телефон
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        AppLabel {
                            text: "Телефон"
                            level: "h3"
                            enterDelay: 500
                        }

                        AppTextField {
                            id: phoneField
                            Layout.fillWidth: true
                            placeholderText: "+7 (XXX) XXX-XX-XX"
                            enterDelay: 550
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                        }
                    }

                    // Веб-сайт
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        AppLabel {
                            text: "Веб-сайт"
                            level: "h3"
                            enterDelay: 600
                        }

                        AppTextField {
                            id: websiteField
                            Layout.fillWidth: true
                            placeholderText: "https://example.com"
                            enterDelay: 650
                            inputMethodHints: Qt.ImhUrlCharactersOnly

                            validator: RegularExpressionValidator {
                                regularExpression: /^$|^https?:\/\/.+\..+$/
                            }

                            onTextChanged: validateForm()
                        }

                        AppLabel {
                            visible: websiteField.text.trim().length > 0 && !websiteField.acceptableInput
                            text: "⚠️ URL должен начинаться с http:// или https://"
                            level: "error"
                            enterDelay: 700
                        }
                    }

                    // Примечание
                    AppLabel {
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        text: "* - обязательные поля"
                        level: "caption"
                        font.italic: true
                        enterDelay: 750
                    }

                    // Подсказка об изменениях
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        color: Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.1)
                        border.color: Theme.accentColor
                        radius: Theme.defaultRadius
                        visible: supplierId > 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "ℹ️"
                                font.pixelSize: 24
                            }

                            AppLabel {
                                Layout.fillWidth: true
                                text: "Изменения будут применены ко всем связанным записям"
                                level: "caption"
                                color: Theme.accentColor
                                wrapMode: Text.WordWrap
                                enterDelay: 800
                            }
                        }
                    }
                }
            }

            // Кнопки
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "Отмена"
                    btnColor: "#666666"
                    Layout.preferredWidth: 120
                    enterDelay: 850

                    onClicked: editSupplierDialog.reject()
                }

                AppButton {
                    text: "Сохранить"
                    btnColor: Theme.primaryColor
                    enabled: companyField.text.trim() !== "" && !hasErrors
                    Layout.preferredWidth: 120
                    enterDelay: 900

                    onClicked: {
                        supplierEdited(
                            supplierId,
                            nameField.text.trim(),
                            companyField.text.trim(),
                            emailField.text.trim(),
                            phoneField.text.trim(),
                            websiteField.text.trim()
                        )
                        editSupplierDialog.accept()
                    }
                }
            }
        }
    }

    function validateForm() {
        hasErrors = false

        if (companyField.text.trim().length > 0 && !companyField.acceptableInput) {
            hasErrors = true
        }

        if (emailField.text.trim().length > 0 && !emailField.acceptableInput) {
            hasErrors = true
        }

        if (websiteField.text.trim().length > 0 && !websiteField.acceptableInput) {
            hasErrors = true
        }
    }

    function openFor(id, name, company, email, phone, website) {
        supplierId = id
        nameField.text = name || ""
        companyField.text = company || ""
        emailField.text = email || ""
        phoneField.text = phone || ""
        websiteField.text = website || ""
        hasErrors = false
        open()
        companyField.forceActiveFocus()
    }
}
