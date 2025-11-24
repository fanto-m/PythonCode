// qml/components/dialogs/categories/AddCategoryDialog.qml
// ВЕРСИЯ С ВОЗМОЖНОСТЬЮ ПЕРЕМЕЩЕНИЯ (Drag & Drop)
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: addCategoryDialogInternal
    title: "Новая категория"
    modal: true
    width: 500
    height: 400

    // 🎯 ВАЖНО: Убираем стандартные кнопки из footer
    // Добавим их вручную в content
    standardButtons: Dialog.NoButton

    signal categoryAdded(string name, string skuPrefix, int skuDigits)

    // 🎨 Кастомный header для перетаскивания
    header: Rectangle {
        id: dialogHeader
        width: parent.width
        height: 50
        color: Theme.primaryColor
        radius: Theme.defaultRadius

        // Закругление только сверху
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

            // 🎯 Область для перетаскивания
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Иконка перемещения (опционально)
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "☰"
                    color: Theme.textOnPrimary
                    font.pixelSize: 20
                    opacity: 0.7
                }

                // Заголовок
                Text {
                    anchors.centerIn: parent
                    text: addCategoryDialogInternal.title
                    font: Theme.boldFont
                    //font.pixelSize: 18
                    color: Theme.textOnPrimary
                }

                // 🖱️ MouseArea для перетаскивания
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor  // Курсор "перемещение"

                    property point clickPos: Qt.point(0, 0)

                    onPressed: function(mouse) {
                        clickPos = Qt.point(mouse.x, mouse.y)
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            // Вычисляем новую позицию
                            var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)

                            // Перемещаем диалог
                            addCategoryDialogInternal.x += delta.x
                            addCategoryDialogInternal.y += delta.y
                        }
                    }
                }
            }

            // Кнопка закрытия
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

                onClicked: addCategoryDialogInternal.reject()
            }
        }
    }

    // Основной контент
    contentItem: Item {
        implicitWidth: 500
        implicitHeight: 350

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 10  // Уменьшили, т.к. header уже есть
            spacing: 15

            // ==================== НАЗВАНИЕ КАТЕГОРИИ ====================
            AppTextField {
                id: newCategoryField
                placeholderText: "Новая категория"
                text: ""
                Layout.fillWidth: true
                enterDelay: 0
            }

            // ==================== РАЗДЕЛИТЕЛЬ ====================
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.dividerColor
            }

            // ==================== ЗАГОЛОВОК СЕКЦИИ SKU ====================
            AppLabel {
                text: "Шаблон артикула (SKU):"
                level: "h3"
                enterDelay: 100
            }

            // ==================== ПОЛЯ SKU ====================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                AppLabel {
                    text: "Префикс:"
                    Layout.preferredWidth: 70
                    enterDelay: 150
                }

                AppTextField {
                    id: skuPrefixField
                    placeholderText: "P"
                    Layout.preferredWidth: 80
                    enterDelay: 200

                    property int maximumLength: 5
                    onTextChanged: {
                        if (text.length > maximumLength) {
                            text = text.substring(0, maximumLength)
                        }
                        text = text.toUpperCase()
                        updatePreview()
                    }

                    validator: RegularExpressionValidator {
                        regularExpression: /[A-ZА-ЯЁ0-9-]*/
                    }
                }

                AppLabel {
                    text: "Разрядность:"
                    Layout.preferredWidth: 90
                    enterDelay: 250
                }

                SpinBox {
                    id: skuDigitsSpinBox
                    from: 2
                    to: 8
                    value: 4
                    Layout.preferredWidth: 120
                    onValueChanged: updatePreview()

                    contentItem: TextInput {
                        text: skuDigitsSpinBox.textFromValue(skuDigitsSpinBox.value, skuDigitsSpinBox.locale)
                        font: Theme.defaultFont
                        color: Theme.textColor
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        readOnly: !skuDigitsSpinBox.editable
                        validator: skuDigitsSpinBox.validator
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    background: Rectangle {
                        color: Theme.inputBackground
                        border.color: skuDigitsSpinBox.activeFocus
                            ? Theme.inputBorderFocus
                            : (skuDigitsSpinBox.hovered ? Theme.inputBorderHover : Theme.inputBorder)
                        border.width: skuDigitsSpinBox.activeFocus ? 2 : 1
                        radius: Theme.smallRadius

                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            // ==================== PREVIEW ====================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                AppLabel {
                    text: "Пример:"
                    level: "caption"
                    font.italic: true
                    enterDelay: 300
                }

                AppLabel {
                    id: previewLabel
                    text: generatePreview()
                    level: "h3"
                    color: Theme.highlightColor
                    enterDelay: 350
                }
            }

            // ==================== ОПИСАНИЕ ====================
            AppLabel {
                text: "Артикулы для товаров этой категории будут иметь вид: " +
                      (skuPrefixField.text || "P") + "-" + "X".repeat(skuDigitsSpinBox.value)
                level: "caption"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                enterDelay: 400
            }

            // ==================== SPACER ====================
            Item {
                Layout.fillHeight: true
            }

            // ==================== КНОПКИ (вручную) ====================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }  // Spacer

                AppButton {
                    text: "Отмена"
                    btnColor: "#666666"
                    Layout.preferredWidth: 100
                    enterDelay: 450

                    onClicked: addCategoryDialogInternal.reject()
                }

                AppButton {
                    text: "ОК"
                    btnColor: Theme.primaryColor
                    Layout.preferredWidth: 100
                    enterDelay: 500

                    onClicked: addCategoryDialogInternal.accept()
                }
            }
        }
    }

    // ==================== ФУНКЦИИ ====================

    function generatePreview() {
        var prefix = skuPrefixField.text || "P"
        var digits = skuDigitsSpinBox.value
        var examples = []

        for (var i = 1; i <= 3; i++) {
            var number = String(i).padStart(digits, '0')
            examples.push(prefix + "-" + number)
        }

        return examples.join(", ") + ", ..."
    }

    function updatePreview() {
        previewLabel.text = generatePreview()
    }

    // ==================== ОБРАБОТЧИКИ СОБЫТИЙ ====================

    onOpened: {
        console.log("DEBUG: AddCategoryDialog opened")

        newCategoryField.text = ""
        skuPrefixField.text = ""
        skuDigitsSpinBox.value = 4

        newCategoryField.forceActiveFocus()
        updatePreview()
    }

    onAccepted: {
        if (newCategoryField.text.trim() !== "") {
            var prefix = skuPrefixField.text.trim() || "ITEM"
            var digits = skuDigitsSpinBox.value

            categoryAdded(newCategoryField.text.trim(), prefix, digits)
        }
    }
}
