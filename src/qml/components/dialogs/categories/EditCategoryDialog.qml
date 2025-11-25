// qml/components/dialogs/categories/EditCategoryDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: editCategoryDialogInternal
    title: "Редактирование категории"
    modal: true
    width: 500
    height: 400
    standardButtons: Dialog.NoButton

    property int categoryId: -1

    signal categoryEdited(int id, string name, string skuPrefix, int skuDigits)

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
                    text: editCategoryDialogInternal.title
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
                            editCategoryDialogInternal.x += delta.x
                            editCategoryDialogInternal.y += delta.y
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

                onClicked: editCategoryDialogInternal.reject()
            }
        }
    }

    contentItem: Item {
        implicitWidth: 500
        implicitHeight: 400

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 10
            spacing: 15

            // Название
            AppTextField {
                id: editCategoryField
                placeholderText: "Название категории"
                Layout.fillWidth: true
                enterDelay: 0
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.dividerColor
            }

            AppLabel {
                text: "Шаблон артикула (SKU):"
                level: "h3"
                enterDelay: 100
            }

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
                    Layout.preferredHeight: 40
                    enterDelay: 200

                    property int maximumLength: 5
                    validator: RegularExpressionValidator {
                        regularExpression: /[A-ZА-ЯЁ0-9-]*/
                    }
                    onTextChanged: {
                        if (text.length > maximumLength) {
                            text = text.substring(0, maximumLength)
                        }
                        text = text.toUpperCase()
                        updatePreview()
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
                    Layout.preferredHeight: 40
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

            AppLabel {
                text: "Артикулы будут иметь вид: " +
                      (skuPrefixField.text || "P") + "-" + "X".repeat(skuDigitsSpinBox.value)
                level: "caption"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                enterDelay: 400
            }

            Item { Layout.fillHeight: true }

            // Кнопки
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "Отмена"
                    btnColor: "#666666"
                    Layout.preferredWidth: 100
                    enterDelay: 450
                    onClicked: editCategoryDialogInternal.reject()
                }

                AppButton {
                    text: "ОК"
                    btnColor: Theme.primaryColor
                    Layout.preferredWidth: 100
                    enterDelay: 500
                    onClicked: editCategoryDialogInternal.accept()
                }
            }
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

    // Открыть для редактирования существующей категории
    function openFor(category) {
        categoryId = category.id
        editCategoryField.text = category.name
        skuPrefixField.text = category.sku_prefix
        skuDigitsSpinBox.value = category.sku_digits
        open()
        updatePreview()
    }

    onAccepted: {
        if (editCategoryField.text !== "" && categoryId >= 0) {
            categoryEdited(
                categoryId,
                editCategoryField.text,
                skuPrefixField.text.trim() || "ITEM",
                skuDigitsSpinBox.value
            )
        }
    }
}
