// components/EditSupplierDialog.qml - Improved Version
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: editSupplierDialog
    title: "Редактировать поставщика"
    modal: true
    width: Math.min(Screen.width * 0.5, 600)
    height: Math.min(Screen.height * 0.7, 550)

    // Theme constants
    readonly property color primaryColor: "#2196F3"
    readonly property color errorColor: "#f44336"
    readonly property color borderColor: "#d0d0d0"
    readonly property int baseSpacing: 12
    readonly property int baseFontSize: 10

    property int supplierId: -1
    property bool hasErrors: false

    signal supplierEdited(int id, string name, string company, string email, string phone, string website)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: baseSpacing

        // Header section
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#f5f5f5"
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: baseSpacing
                spacing: baseSpacing

                Text {
                    text: "✏️"
                    font.pointSize: 24
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Редактирование поставщика"
                        font.pointSize: baseFontSize + 2
                        font.bold: true
                        color: "#212121"
                    }

                    Text {
                        id: subtitleText
                        text: "ID: " + supplierId
                        font.pointSize: baseFontSize - 1
                        color: "#757575"
                    }
                }
            }
        }

        // Form section
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: baseSpacing + 4

                // Company field (required)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Компания *"
                        font.pointSize: baseFontSize
                        font.bold: true
                        color: "#424242"
                    }

                    TextField {
                        id: companyField
                        Layout.fillWidth: true
                        placeholderText: "Введите название компании"
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: companyField.enabled ? "white" : "#f5f5f5"
                            border.color: {
                                if (!companyField.acceptableInput && companyField.text.length > 0)
                                    return errorColor
                                if (companyField.activeFocus)
                                    return primaryColor
                                return borderColor
                            }
                            border.width: companyField.activeFocus ? 2 : 1
                            radius: 4
                        }

                        validator: RegularExpressionValidator {
                            regularExpression: /.{2,}/
                        }

                        onTextChanged: validateForm()
                    }

                    Text {
                        visible: companyField.text.trim().length > 0 && !companyField.acceptableInput
                        text: "⚠️ Название компании должно содержать минимум 2 символа"
                        font.pointSize: baseFontSize - 1
                        color: errorColor
                    }
                }

                // Name field (optional)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "ФИО контактного лица"
                        font.pointSize: baseFontSize
                        font.bold: true
                        color: "#424242"
                    }

                    TextField {
                        id: nameField
                        Layout.fillWidth: true
                        placeholderText: "Иванов Иван Иванович"
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: nameField.enabled ? "white" : "#f5f5f5"
                            border.color: nameField.activeFocus ? primaryColor : borderColor
                            border.width: nameField.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }
                }

                // Email field (optional)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Email"
                        font.pointSize: baseFontSize
                        font.bold: true
                        color: "#424242"
                    }

                    TextField {
                        id: emailField
                        Layout.fillWidth: true
                        placeholderText: "example@company.com"
                        font.pointSize: baseFontSize
                        inputMethodHints: Qt.ImhEmailCharactersOnly

                        background: Rectangle {
                            color: emailField.enabled ? "white" : "#f5f5f5"
                            border.color: {
                                if (!emailField.acceptableInput && emailField.text.length > 0)
                                    return errorColor
                                if (emailField.activeFocus)
                                    return primaryColor
                                return borderColor
                            }
                            border.width: emailField.activeFocus ? 2 : 1
                            radius: 4
                        }

                        validator: RegularExpressionValidator {
                            regularExpression: /^$|^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                        }

                        onTextChanged: validateForm()
                    }

                    Text {
                        visible: emailField.text.trim().length > 0 && !emailField.acceptableInput
                        text: "⚠️ Введите корректный email адрес"
                        font.pointSize: baseFontSize - 1
                        color: errorColor
                    }
                }

                // Phone field (optional)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Телефон"
                        font.pointSize: baseFontSize
                        font.bold: true
                        color: "#424242"
                    }

                    TextField {
                        id: phoneField
                        Layout.fillWidth: true
                        placeholderText: "+7 (XXX) XXX-XX-XX"
                        font.pointSize: baseFontSize
                        inputMethodHints: Qt.ImhDialableCharactersOnly

                        background: Rectangle {
                            color: phoneField.enabled ? "white" : "#f5f5f5"
                            border.color: phoneField.activeFocus ? primaryColor : borderColor
                            border.width: phoneField.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }
                }

                // Website field (optional)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Веб-сайт"
                        font.pointSize: baseFontSize
                        font.bold: true
                        color: "#424242"
                    }

                    TextField {
                        id: websiteField
                        Layout.fillWidth: true
                        placeholderText: "https://example.com"
                        font.pointSize: baseFontSize
                        inputMethodHints: Qt.ImhUrlCharactersOnly

                        background: Rectangle {
                            color: websiteField.enabled ? "white" : "#f5f5f5"
                            border.color: {
                                if (!websiteField.acceptableInput && websiteField.text.length > 0)
                                    return errorColor
                                if (websiteField.activeFocus)
                                    return primaryColor
                                return borderColor
                            }
                            border.width: websiteField.activeFocus ? 2 : 1
                            radius: 4
                        }

                        validator: RegularExpressionValidator {
                            regularExpression: /^$|^https?:\/\/.+\..+$/
                        }

                        onTextChanged: validateForm()
                    }

                    Text {
                        visible: websiteField.text.trim().length > 0 && !websiteField.acceptableInput
                        text: "⚠️ URL должен начинаться с http:// или https://"
                        font.pointSize: baseFontSize - 1
                        color: errorColor
                    }
                }

                // Required fields note
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: baseSpacing
                    text: "* - обязательные поля"
                    font.pointSize: baseFontSize - 1
                    font.italic: true
                    color: "#757575"
                }

                // Change history hint
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#e3f2fd"
                    border.color: primaryColor
                    radius: 4
                    visible: supplierId > 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "ℹ️"
                            font.pointSize: baseFontSize + 2
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Изменения будут применены ко всем связанным записям"
                            font.pointSize: baseFontSize - 1
                            color: "#1565c0"
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
        background: Rectangle {
            color: "#fafafa"
            border.color: borderColor
            border.width: 1
        }

        Button {
            text: "💾 Сохранить"
            enabled: companyField.text.trim() !== "" && !hasErrors
            highlighted: true
            font.pointSize: baseFontSize

            background: Rectangle {
                color: {
                    if (!parent.enabled) return "#e0e0e0"
                    if (parent.down) return Qt.darker(primaryColor, 1.2)
                    if (parent.hovered) return Qt.lighter(primaryColor, 1.1)
                    return primaryColor
                }
                radius: 4
                border.width: 0
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: parent.enabled ? "white" : "#9e9e9e"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                supplierEdited(
                    supplierId,
                    nameField.text.trim(),
                    companyField.text.trim(),
                    emailField.text.trim(),
                    phoneField.text.trim(),
                    websiteField.text.trim()
                )
                close()
            }
        }

        Button {
            text: "Отмена"
            font.pointSize: baseFontSize

            background: Rectangle {
                color: {
                    if (parent.down) return "#e0e0e0"
                    if (parent.hovered) return "#f5f5f5"
                    return "white"
                }
                radius: 4
                border.color: borderColor
                border.width: 1
            }

            onClicked: close()
        }
    }

    function validateForm() {
        hasErrors = false

        // Check company field
        if (companyField.text.trim().length > 0 && !companyField.acceptableInput) {
            hasErrors = true
        }

        // Check email field
        if (emailField.text.trim().length > 0 && !emailField.acceptableInput) {
            hasErrors = true
        }

        // Check website field
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