//AddCategoryDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: addCategoryDialogInternal
    title: "Новая категория"
    modal: true
    width: 500
    height: 350
    standardButtons: Dialog.Ok | Dialog.Cancel

    signal categoryAdded(string name, string skuPrefix, int skuDigits)

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 60 // Увеличенный верхний отступ для учета заголовка
        spacing: 15

        // Category name
        TextField {
            id: newCategoryField
            placeholderText: "Новая категория"
            text: ""
            leftPadding: 5
            Layout.fillWidth: true // Растягиваем по ширине
            Layout.topMargin: 10 // Дополнительный отступ сверху для разделения с title
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 30
                color: "#e0e0e0"
                border.color: "#4682b4"
                border.width: 2
                radius: 5
            }
        }

        // SKU Template section
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#ccc"
        }

        Label {
            text: "Шаблон артикула (SKU):"
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Префикс:"
                Layout.preferredWidth: 70
            }

            TextField {
                id: skuPrefixField
                placeholderText: "P"
                Layout.preferredWidth: 80
                maximumLength: 5
                validator: RegularExpressionValidator {
                    regularExpression: /[A-ZА-ЯЁ0-9-]*/
                }
                onTextChanged: {
                    text = text.toUpperCase()
                    updatePreview()
                }
            }

            Label {
                text: "Разрядность:"
                Layout.preferredWidth: 90
            }

            SpinBox {
                id: skuDigitsSpinBox
                from: 2
                to: 8
                value: 4
                Layout.preferredWidth: 120
                onValueChanged: updatePreview()
            }
        }

        // Preview
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Пример:"
                font.italic: true
                color: "#666"
            }

            Label {
                id: previewLabel
                text: generatePreview()
                font.bold: true
                color: "#0066cc"
            }
        }

        // Description
        Label {
            text: "Артикулы для товаров этой категории будут иметь вид: " +
                  skuPrefixField.text + "-" + "X".repeat(skuDigitsSpinBox.value)
            font.pointSize: 9
            color: "#666"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }
    }

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