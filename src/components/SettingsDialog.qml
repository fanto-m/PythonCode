// SettingsDialog.qml
// Place this file in your QML directory
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: settingsDialog
    title: "⚙️ Настройки приложения"
    modal: true
    width: 500
    height: 400
    anchors.centerIn: parent

    readonly property color primaryColor: "#2196F3"
    readonly property color borderColor: "#d0d0d0"
    readonly property color focusBorderColor: primaryColor
    readonly property int baseFontSize: 10
    readonly property int baseSpacing: 10

    background: Rectangle {
        color: "#ffffff"
        border.color: borderColor
        border.width: 1
        radius: 8
    }

    contentItem: ColumnLayout {
        spacing: baseSpacing * 2

        // VAT Settings Section
        GroupBox {
            Layout.fillWidth: true
            title: "Настройки НДС"
            font.pointSize: baseFontSize + 1
            font.bold: true

            background: Rectangle {
                color: "#fafafa"
                border.color: borderColor
                radius: 4
                y: parent.topPadding - parent.bottomPadding
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: baseSpacing

                // VAT Included by default
                CheckBox {
                    id: defaultVatIncluded
                    Layout.fillWidth: true
                    text: "По умолчанию включать НДС в цену"
                    font.pointSize: baseFontSize
                    checked: configManager.vatIncluded

                    onCheckedChanged: {
                        if (checked !== configManager.vatIncluded) {
                            configManager.vatIncluded = checked
                        }
                    }
                }

                // VAT Rate
                RowLayout {
                    Layout.fillWidth: true
                    spacing: baseSpacing

                    Label {
                        text: "Ставка НДС (%):"
                        font.pointSize: baseFontSize
                    }

                    TextField {
                        id: vatRateField
                        Layout.preferredWidth: 80
                        text: configManager.vatRate.toString()
                        font.pointSize: baseFontSize
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        placeholderText: "20.0"

                        background: Rectangle {
                            color: "white"
                            border.color: vatRateField.activeFocus ? focusBorderColor : borderColor
                            border.width: vatRateField.activeFocus ? 2 : 1
                            radius: 4
                        }

                        validator: DoubleValidator {
                            bottom: 0.0
                            top: 100.0
                            decimals: 2
                        }
                    }

                    Button {
                        text: "Применить"
                        font.pointSize: baseFontSize - 1
                        enabled: {
                            let rate = parseFloat(vatRateField.text)
                            return !isNaN(rate) && rate >= 0 && rate <= 100
                        }

                        onClicked: {
                            let rate = parseFloat(vatRateField.text)
                            if (!isNaN(rate)) {
                                configManager.vatRate = rate
                            }
                        }

                        background: Rectangle {
                            color: {
                                if (!parent.enabled) return "#e0e0e0"
                                if (parent.down) return Qt.darker(primaryColor, 1.2)
                                if (parent.hovered) return Qt.lighter(primaryColor, 1.1)
                                return primaryColor
                            }
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: parent.enabled ? "white" : "#9e9e9e"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Стандартные ставки НДС: 0%, 10%, 20%"
                    font.pointSize: baseFontSize - 2
                    font.italic: true
                    color: "#757575"
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Currency Settings Section
        GroupBox {
            Layout.fillWidth: true
            title: "Валюта"
            font.pointSize: baseFontSize + 1
            font.bold: true

            background: Rectangle {
                color: "#fafafa"
                border.color: borderColor
                radius: 4
                y: parent.topPadding - parent.bottomPadding
            }

            RowLayout {
                anchors.fill: parent
                spacing: baseSpacing

                Label {
                    text: "Валюта по умолчанию:"
                    font.pointSize: baseFontSize
                }

                ComboBox {
                    id: currencyComboBox
                    Layout.fillWidth: true
                    model: ["RUB", "USD", "EUR", "CNY"]
                    currentIndex: model.indexOf(configManager.defaultCurrency)
                    font.pointSize: baseFontSize

                    onCurrentTextChanged: {
                        if (currentText !== configManager.defaultCurrency) {
                            configManager.defaultCurrency = currentText
                        }
                    }

                    background: Rectangle {
                        color: "white"
                        border.color: currencyComboBox.activeFocus ? focusBorderColor : borderColor
                        border.width: currencyComboBox.activeFocus ? 2 : 1
                        radius: 4
                    }
                }
            }
        }

        // Spacer
        Item { Layout.fillHeight: true }

        // Info text
        Text {
            Layout.fillWidth: true
            text: "ℹ️ Настройки сохраняются автоматически"
            font.pointSize: baseFontSize - 1
            font.italic: true
            color: "#757575"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "Сбросить"
            DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
            flat: true
            font.pointSize: baseFontSize

            onClicked: {
                configManager.resetToDefaults()
                vatRateField.text = configManager.vatRate.toString()
            }
        }

        Button {
            text: "Закрыть"
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            highlighted: true
            font.pointSize: baseFontSize

            background: Rectangle {
                color: {
                    if (parent.down) return Qt.darker(primaryColor, 1.2)
                    if (parent.hovered) return Qt.lighter(primaryColor, 1.1)
                    return primaryColor
                }
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: settingsDialog.close()
        }
    }
}