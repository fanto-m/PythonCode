// SpecificationEditDialog.qml - Диалог редактирования спецификации
// Расположение: src/qml/components/dialogs/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common" as Common
import "../items" as ItemDialogs  // Для AddItemDialog
import "../../tables" as Tables  // Для SpecificationItemsTable

Dialog {
    id: editDialog
    title: "Редактирование спецификации"
    modal: true
    width: 1400
    height: 900
    anchors.centerIn: parent

    property int specId: -1
    property bool hasChanges: false
    property real materialsCost: 0
    property real laborCost: 0
    property real overheadCost: 0
    property real totalCost: 0

    // Сигналы
    signal specificationSaved()
    signal saveError(string errorText)

    function openFor(id) {
        specId = id
        hasChanges = false

        var specs = specificationsModel.loadAllSpecifications()
        var spec = null
        for (var i = 0; i < specs.length; i++) {
            if (specs[i].id === id) {
                spec = specs[i]
                break
            }
        }

        if (!spec) {
            console.error("Specification not found:", id)
            return
        }

        editNameField.text = spec.name
        editDescriptionField.text = spec.description || ""
        editLaborCostField.text = spec.labor_cost.toString()
        editOverheadField.text = spec.overhead_percentage.toString()

        var statuses = ["черновик", "утверждена", "архив"]
        editStatusComboBox.currentIndex = statuses.indexOf(spec.status)

        specificationItemsModel.clear()
        var items = specificationsModel.loadSpecificationItems(id)
        specificationItemsModel.loadItems(items)

        calculateEditCosts()
        open()
    }

    function calculateEditCosts() {
        materialsCost = specificationItemsModel.getTotalMaterialsCost() || 0
        laborCost = parseFloat(editLaborCostField.text) || 0
        var overheadPercent = parseFloat(editOverheadField.text) || 0
        overheadCost = materialsCost * (overheadPercent / 100)
        totalCost = materialsCost + laborCost + overheadCost
    }

    function saveChanges() {
        var result = specificationsModel.saveSpecification(
            specId,
            editNameField.text,
            editDescriptionField.text,
            editStatusComboBox.currentText,
            laborCost,
            parseFloat(editOverheadField.text) || 0
        )

        if (result > 0) {
            hasChanges = false
            specificationSaved()
            close()
        } else {
            saveError("Ошибка при сохранении спецификации!")
        }
    }

    onClosed: {
        specificationItemsModel.clear()
    }

    // === ФОН ДИАЛОГА ===
    background: Rectangle {
        color: "white"
        border.color: Theme.accentColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    // === ЗАГОЛОВОК С ПЕРЕТАСКИВАНИЕМ ===
    header: Rectangle {
        width: parent.width
        height: 50
        color: "#9b59b6"  // Фиолетовый для спецификаций
        radius: Theme.defaultRadius

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.defaultRadius
            color: "#9b59b6"
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10

            Text {
                text: "✏️ Редактирование: " + editNameField.text
                font.pixelSize: Theme.sizeH3
                font.bold: true
                font.family: Theme.defaultFont.family
                color: Theme.textOnPrimary
                Layout.fillWidth: true
            }

            // Индикатор изменений
            Rectangle {
                visible: editDialog.hasChanges
                width: unsavedLabel.width + 16
                height: 24
                radius: 12
                color: Theme.warningColor

                Text {
                    id: unsavedLabel
                    anchors.centerIn: parent
                    text: "● Несохранено"
                    font.pixelSize: Theme.sizeCaption
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textOnPrimary
                }
            }
        }

        // Область для перетаскивания
        MouseArea {
            anchors.fill: parent
            property point clickPos: Qt.point(0, 0)
            onPressed: function(mouse) {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: function(mouse) {
                if (pressed) {
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    editDialog.x += delta.x
                    editDialog.y += delta.y
                }
            }
        }
    }

    contentItem: ScrollView {
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 15

            // === ОСНОВНАЯ ИНФОРМАЦИЯ ===
            GroupBox {
                Layout.fillWidth: true
                title: "Основная информация"

                label: Text {
                    text: parent.title
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textColor
                    padding: 5
                }

                background: Rectangle {
                    color: "white"
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        // Название
                        ColumnLayout {
                            Layout.preferredWidth: 500
                            Layout.minimumWidth: 500
                            Layout.maximumWidth: 500
                            spacing: 4

                            Text {
                                text: "Название изделия *"
                                font: Theme.boldFont
                                color: Theme.textColor
                            }

                            Common.AppTextField {
                                id: editNameField
                                Layout.fillWidth: true
                                placeholderText: "Например: Изделие А-123"
                                enterDelay: 0
                                onTextChanged: editDialog.hasChanges = true
                            }
                        }

                        // Статус
                        ColumnLayout {
                            Layout.preferredWidth: 200
                            Layout.minimumWidth: 200
                            Layout.maximumWidth: 200
                            spacing: 4

                            Text {
                                text: "Статус"
                                font: Theme.boldFont
                                color: Theme.textColor
                            }

                            Common.AppComboBox {
                                id: editStatusComboBox
                                Layout.fillWidth: true
                                model: ["черновик", "утверждена", "архив"]
                                onCurrentIndexChanged: editDialog.hasChanges = true
                            }
                        }
                    }

                    // Описание
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Описание"
                            font: Theme.boldFont
                            color: Theme.textColor
                        }

                        Common.AppTextArea {
                            id: editDescriptionField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            placeholderText: "Подробное описание изделия..."
                            enterDelay: 0
                            onTextChanged: editDialog.hasChanges = true
                        }
                    }
                }
            }

            // === МАТЕРИАЛЫ И КОМПЛЕКТУЮЩИЕ ===
            GroupBox {
                Layout.fillWidth: true
                title: "Материалы и комплектующие"

                label: Text {
                    text: parent.title
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textColor
                    padding: 5
                }

                background: Rectangle {
                    color: "white"
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // Строка итогов
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: Qt.rgba(Theme.infoColor.r, Theme.infoColor.g, Theme.infoColor.b, 0.1)
                        radius: Theme.smallRadius
                        visible: editItemsTable.rowCount > 0

                        Text {
                            anchors.centerIn: parent
                            text: "📦 Позиций: " + editItemsTable.rowCount + " | Стоимость материалов: " + editDialog.materialsCost.toFixed(2) + " ₽"
                            font: Theme.boldFont
                            color: Theme.infoColor
                        }
                    }

                    // Кнопка добавления
                    // Кнопка добавления
                    Button {
                        text: "➕ Добавить позицию из склада"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        onClicked: addItemDialog.open()

                        background: Rectangle {
                            color: parent.down ? Qt.darker(Theme.successColor, 1.1)
                                 : (parent.hovered ? Qt.lighter(Theme.successColor, 1.1) : Theme.successColor)
                            radius: Theme.defaultRadius
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            font: Theme.defaultFont
                            color: Theme.textOnPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // Таблица
                    Tables.SpecificationItemsTable {
                        id: editItemsTable
                        Layout.fillWidth: true
                        Layout.preferredHeight: 400
                        model: specificationItemsModel
                        readOnly: false

                        onItemQuantityChanged: function(row, newQuantity) {
                            specificationItemsModel.updateQuantity(row, newQuantity)
                            editDialog.hasChanges = true
                            editDialog.calculateEditCosts()
                        }

                        onItemRemoved: function(row) {
                            specificationItemsModel.removeItem(row)
                            editDialog.hasChanges = true
                            editDialog.calculateEditCosts()
                        }
                    }
                }
            }

            // === КАЛЬКУЛЯЦИЯ СТОИМОСТИ ===
            GroupBox {
                Layout.fillWidth: true
                title: "Калькуляция стоимости"

                label: Text {
                    text: parent.title
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textColor
                    padding: 5
                }

                background: Rectangle {
                    color: "white"
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding - parent.bottomPadding
                }

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 15

                    // Стоимость работы
                    Text {
                        text: "Стоимость работы (₽):"
                        font: Theme.defaultFont
                        color: Theme.textColor
                    }
                    Common.AppTextField {
                        id: editLaborCostField
                        Layout.fillWidth: true
                        text: "0"
                        horizontalAlignment: Text.AlignRight
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        enterDelay: 0
                        onTextChanged: {
                            editDialog.hasChanges = true
                            editDialog.calculateEditCosts()
                        }
                    }

                    // Накладные расходы
                    Text {
                        text: "Накладные расходы (%):"
                        font: Theme.defaultFont
                        color: Theme.textColor
                    }
                    Common.AppTextField {
                        id: editOverheadField
                        Layout.fillWidth: true
                        text: "0"
                        horizontalAlignment: Text.AlignRight
                        validator: DoubleValidator { bottom: 0; top: 100; decimals: 2 }
                        enterDelay: 0
                        onTextChanged: {
                            editDialog.hasChanges = true
                            editDialog.calculateEditCosts()
                        }
                    }

                    // Разделитель
                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        height: 2
                        color: Theme.dividerColor
                    }

                    // Итоги (только для чтения)
                    Text {
                        text: "Материалы:"
                        font: Theme.defaultFont
                        color: Theme.textSecondary
                    }
                    Text {
                        text: editDialog.materialsCost.toFixed(2) + " ₽"
                        font: Theme.boldFont
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.textColor
                    }

                    Text {
                        text: "Работа:"
                        font: Theme.defaultFont
                        color: Theme.textSecondary
                    }
                    Text {
                        text: editDialog.laborCost.toFixed(2) + " ₽"
                        font: Theme.boldFont
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.textColor
                    }

                    Text {
                        text: "Накладные:"
                        font: Theme.defaultFont
                        color: Theme.textSecondary
                    }
                    Text {
                        text: editDialog.overheadCost.toFixed(2) + " ₽"
                        font: Theme.boldFont
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.textColor
                    }

                    // Финальный разделитель
                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        height: 2
                        color: Theme.successColor
                    }

                    // ИТОГО
                    Text {
                        text: "ИТОГО:"
                        font.pixelSize: Theme.sizeH3
                        font.bold: true
                        font.family: Theme.defaultFont.family
                        color: Theme.successColor
                    }
                    Text {
                        text: editDialog.totalCost.toFixed(2) + " ₽"
                        font.pixelSize: Theme.sizeH2
                        font.bold: true
                        font.family: Theme.defaultFont.family
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.successColor
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignRight
        spacing: 10
        padding: 12

        background: Rectangle {
            color: Theme.backgroundColor
            radius: Theme.smallRadius
        }

        Common.AppButton {
            text: "💾 Сохранить изменения"
            btnColor: Theme.successColor
            enabled: editNameField.text.trim().length > 0 && editItemsTable.rowCount > 0
            animateEntry: false
            onClicked: editDialog.saveChanges()
        }

        Common.AppButton {
            text: "❌ Отмена"
            btnColor: Theme.textSecondary
            animateEntry: false
            onClicked: {
                if (editDialog.hasChanges) {
                    confirmCancelEditDialog.open()
                } else {
                    editDialog.close()
                }
            }
        }
    }

    // === ДИАЛОГ ПОДТВЕРЖДЕНИЯ ОТМЕНЫ ===
    Dialog {
        id: confirmCancelEditDialog
        title: "Подтверждение"
        modal: true
        width: 400
        anchors.centerIn: parent

        background: Rectangle {
            color: "white"
            border.color: Theme.warningColor
            border.width: 2
            radius: Theme.defaultRadius
        }

        contentItem: ColumnLayout {
            spacing: 15
            anchors.margins: 20

            Text {
                text: "⚠️"
                font.pixelSize: 32
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "У вас есть несохраненные изменения.\nВыйти без сохранения?"
                font: Theme.defaultFont
                color: Theme.textColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        footer: DialogButtonBox {
            alignment: Qt.AlignCenter
            spacing: 10
            padding: 12

            background: Rectangle {
                color: Theme.backgroundColor
                radius: Theme.smallRadius
            }

            Common.AppButton {
                text: "Да, выйти"
                btnColor: Theme.errorColor
                animateEntry: false
                onClicked: {
                    confirmCancelEditDialog.close()
                    editDialog.close()
                }
            }

            Common.AppButton {
                text: "Отмена"
                btnColor: Theme.textSecondary
                animateEntry: false
                onClicked: confirmCancelEditDialog.close()
            }
        }
    }

    // === АНИМАЦИИ ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 250; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.95; duration: 150; easing.type: Easing.InCubic }
        }
    }
}
