// CreateSpecificationMode.qml - Режим создания/редактирования спецификаций
// Расположение: qml/components/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"
import "../../../components" as Legacy  // Для AddItemDialog и SpecificationItemsTable
import "../common" as Common

Rectangle {
    id: root
    color: Theme.backgroundColor

    // === ДИАЛОГИ ===
    Legacy.AddItemDialog {
        id: addItemDialog

        onItemSelected: function(article, name, quantity, unit, price, imagePath, category, status) {
            let wasAdded = specificationItemsModel.addItem(
                article, name, quantity, unit, price,
                imagePath, category, status
            )
            if (wasAdded) {
                console.log("Новый товар добавлен")
            } else {
                console.log("Количество увеличено")
            }
            hasChanges = true
        }
    }

    // === СИГНАЛЫ ===
    signal backToMain()

    // === СВОЙСТВА ===
    property int currentSpecId: -1
    property string currentSpecName: ""
    property bool isEditMode: currentSpecId !== -1
    property bool hasChanges: false

    // Свойства калькуляции
    property real materialsCost: 0
    property real laborCost: 0
    property real overheadCost: 0
    property real totalCost: 0

    // === ФУНКЦИИ ===
    function calculateCosts() {
        materialsCost = specificationItemsModel.getTotalMaterialsCost() || 0
        laborCost = parseFloat(laborCostField.text) || 0
        var overheadPercent = parseFloat(overheadField.text) || 0
        if (isNaN(laborCost) || isNaN(overheadPercent)) {
            console.warn("Invalid input in laborCostField or overheadField")
            laborCost = 0
            overheadPercent = 0
        }
        overheadCost = materialsCost * (overheadPercent / 100)
        totalCost = materialsCost + laborCost + overheadCost
    }

    function clearForm() {
        currentSpecId = -1
        currentSpecName = ""
        nameField.text = ""
        descriptionField.text = ""
        laborCostField.text = "0"
        overheadField.text = "0"
        statusComboBox.currentIndex = 0
        specificationItemsModel.clear()
        hasChanges = false
        calculateCosts()
    }

    Connections {
        target: specificationItemsModel
        function onTotalCostChanged() {
            calculateCosts()
        }
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========================================
        // HEADER
        // ========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Theme.primaryColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                AppButton {
                    text: "← Главное меню"
                    btnColor: "transparent"
                    implicitHeight: 40
                    enterDelay: 0

                    background: Rectangle {
                        color: parent.down ? Qt.darker(Theme.primaryColor, 1.2) :
                               (parent.hovered ? Qt.lighter(Theme.primaryColor, 1.1) : "transparent")
                        radius: Theme.smallRadius
                        border.color: Theme.textOnPrimary
                        border.width: 2
                    }

                    onClicked: {
                        if (hasChanges) {
                            confirmExitDialog.open()
                        } else {
                            clearForm()
                            backToMain()
                        }
                    }
                }

                AppLabel {
                    text: isEditMode ? "Редактирование спецификации" : "Создание спецификации"
                    level: "h2"
                    color: Theme.textOnPrimary
                    Layout.fillWidth: true
                    enterDelay: 0
                }

                Text {
                    text: "📋"
                    font.pixelSize: 24
                }
            }
        }

        // ========================================
        // MAIN CONTENT
        // ========================================
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: Math.min(parent.width - 20, 1400)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 15
                anchors.topMargin: 15

                // --- ОСНОВНАЯ ИНФОРМАЦИЯ ---
                GroupBox {
                    Layout.fillWidth: true
                    title: "Основная информация"

                    label: AppLabel {
                        text: parent.title
                        level: "body"
                        font.bold: true
                        enterDelay: 0
                    }

                    background: Rectangle {
                        color: "white"
                        border.color: Theme.inputBorder
                        radius: Theme.defaultRadius
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            // Название
                            ColumnLayout {
                                Layout.preferredWidth: 800
                                Layout.minimumWidth: 800
                                Layout.maximumWidth: 800
                                spacing: 4

                                AppLabel {
                                    text: "Название изделия *"
                                    level: "body"
                                    font.bold: true
                                    enterDelay: 0
                                }

                                AppTextField {
                                    id: nameField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    placeholderText: "Например: Изделие А-123"
                                    enterDelay: 0
                                    onTextChanged: hasChanges = true
                                }
                            }

                            // Статус
                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 4

                                AppLabel {
                                    text: "Статус"
                                    level: "body"
                                    font.bold: true
                                    enterDelay: 0
                                }

                                AppComboBox {
                                    id: statusComboBox
                                    Layout.preferredWidth: 200
                                    Layout.preferredHeight: 40
                                    model: ["черновик", "утверждена", "архив"]
                                    currentIndex: 0
                                    onCurrentIndexChanged: hasChanges = true
                                }
                            }
                        }

                        // Описание
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            AppLabel {
                                text: "Описание"
                                level: "body"
                                font.bold: true
                                enterDelay: 0
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                clip: true

                                AppTextArea {
                                    id: descriptionField
                                    placeholderText: "Подробное описание изделия..."
                                    enterDelay: 0
                                    onTextChanged: hasChanges = true
                                }
                            }
                        }
                    }
                }

                // --- МАТЕРИАЛЫ ---
                GroupBox {
                    Layout.fillWidth: true
                    title: "Материалы и комплектующие"

                    label: AppLabel {
                        text: parent.title
                        level: "body"
                        font.bold: true
                        enterDelay: 0
                    }

                    background: Rectangle {
                        color: "white"
                        border.color: Theme.inputBorder
                        radius: Theme.defaultRadius
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Индикатор состояния
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: Theme.infoColor
                            opacity: 0.2
                            radius: Theme.smallRadius
                            visible: itemsTable.rowCount > 0

                            AppLabel {
                                anchors.centerIn: parent
                                text: "📦 Добавлено позиций: " + itemsTable.rowCount + " | Стоимость материалов: " + materialsCost.toFixed(2) + " ₽"
                                level: "body"
                                font.bold: true
                                color: Theme.primaryColor
                                enterDelay: 0
                            }
                        }

                        Common.AppButton {
                            text: "➕ Добавить позицию из склада"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            btnColor: Theme.successColor
                            animateEntry: false

                            onClicked: {
                                addItemDialog.open()
                            }
                        }

                        // Таблица спецификаций
                        Legacy.SpecificationItemsTable {
                            id: itemsTable
                            Layout.fillWidth: true
                            Layout.preferredHeight: 500
                            model: specificationItemsModel

                            onItemQuantityChanged: function(row, newQuantity) {
                                specificationItemsModel.updateQuantity(row, newQuantity)
                                hasChanges = true
                            }

                            onItemRemoved: function(row) {
                                specificationItemsModel.removeItem(row)
                                hasChanges = true
                            }
                        }
                    }
                }

                // --- КАЛЬКУЛЯЦИЯ ---
                GroupBox {
                    Layout.fillWidth: true
                    title: "Калькуляция стоимости"

                    label: AppLabel {
                        text: parent.title
                        level: "body"
                        font.bold: true
                        enterDelay: 0
                    }

                    background: Rectangle {
                        color: "white"
                        border.color: Theme.inputBorder
                        radius: Theme.defaultRadius
                        y: parent.topPadding - parent.bottomPadding
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 15

                        AppLabel {
                            text: "Стоимость работы (₽):"
                            level: "body"
                            enterDelay: 0
                        }
                        AppTextField {
                            id: laborCostField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            text: "0"
                            horizontalAlignment: Text.AlignRight
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            enterDelay: 0
                            onTextChanged: {
                                hasChanges = true
                                calculateCosts()
                            }
                        }

                        AppLabel {
                            text: "Накладные расходы (%):"
                            level: "body"
                            enterDelay: 0
                        }
                        AppTextField {
                            id: overheadField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            text: "0"
                            horizontalAlignment: Text.AlignRight
                            validator: DoubleValidator { bottom: 0; top: 100; decimals: 2 }
                            enterDelay: 0
                            onTextChanged: {
                                hasChanges = true
                                calculateCosts()
                            }
                        }

                        // Разделитель
                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: Theme.inputBorder
                        }

                        // Разбивка стоимости
                        AppLabel {
                            text: "Материалы:"
                            level: "body"
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        AppLabel {
                            text: materialsCost.toFixed(2) + " ₽"
                            level: "body"
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            enterDelay: 0
                        }

                        AppLabel {
                            text: "Работа:"
                            level: "body"
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        AppLabel {
                            text: laborCost.toFixed(2) + " ₽"
                            level: "body"
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            enterDelay: 0
                        }

                        AppLabel {
                            text: "Накладные:"
                            level: "body"
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                        AppLabel {
                            text: overheadCost.toFixed(2) + " ₽"
                            level: "body"
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            enterDelay: 0
                        }

                        // Итого
                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: Theme.successColor
                        }

                        AppLabel {
                            text: "ИТОГО:"
                            level: "h3"
                            color: Theme.successColor
                            enterDelay: 0
                        }
                        AppLabel {
                            text: totalCost.toFixed(2) + " ₽"
                            level: "h2"
                            color: Theme.successColor
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            enterDelay: 0
                        }
                    }
                }

                // --- КНОПКИ ДЕЙСТВИЙ ---
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 15
                    spacing: 10

                    AppButton {
                        text: "💾 Сохранить"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: nameField.text.trim().length > 0 && itemsTable.rowCount > 0
                        btnColor: Theme.successColor
                        enterDelay: 0

                        onClicked: {
                            specificationItemsModel.debugPrintItems()

                            var specId = specificationsModel.saveSpecification(
                                currentSpecId,
                                nameField.text,
                                descriptionField.text,
                                statusComboBox.currentText,
                                laborCost,
                                parseFloat(overheadField.text) || 0
                            )

                            if (specId > 0) {
                                hasChanges = false
                                notificationDialog.showSuccess("Спецификация успешно сохранена!")
                            } else {
                                notificationDialog.showError("Ошибка при сохранении спецификации!")
                            }
                        }
                    }

                    AppButton {
                        text: "📄 Экспорт в Excel"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: currentSpecId > 0
                        btnColor: Theme.infoColor
                        enterDelay: 0

                        onClicked: {
                            var result = specificationsModel.exportToExcel(currentSpecId)
                            if (result) {
                                notificationDialog.showSuccess("Успешно экспортировано в Excel!")
                            } else {
                                notificationDialog.showError("Ошибка при экспорте в Excel!")
                            }
                        }
                    }

                    AppButton {
                        text: "📕 Экспорт в PDF"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: currentSpecId > 0
                        btnColor: Theme.errorColor
                        enterDelay: 0

                        onClicked: {
                            var result = specificationsModel.exportToPDF(currentSpecId)
                            if (result) {
                                notificationDialog.showSuccess("Успешно экспортировано в PDF!")
                            } else {
                                notificationDialog.showError("Ошибка при экспорте в PDF!")
                            }
                        }
                    }

                    AppButton {
                        text: "🗑️ Очистить"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 45
                        btnColor: "#6c757d"  // Нейтральный серый
                        enterDelay: 0

                        onClicked: {
                            if (hasChanges) {
                                confirmClearDialog.open()
                            } else {
                                clearForm()
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 20 }
            }
        }
    }

    // ========================================
    // ДИАЛОГИ
    // ========================================

    NotificationDialog {
        id: notificationDialog
        onAccepted: {}
        onRejected: {}
    }

    NotificationDialog {
        id: confirmExitDialog
        dialogType: "warning"
        message: "У вас есть несохраненные изменения. \n Выйти без сохранения?"
        showCancelButton: true
        onAccepted: {
            clearForm()
            backToMain()
        }
    }

    NotificationDialog {
        id: confirmClearDialog
        dialogType: "warning"
        message: "Вы уверены, что хотите очистить форму? \n Все несохраненные данные будут потеряны."
        showCancelButton: true
        onAccepted: {
            clearForm()
        }
    }
}
