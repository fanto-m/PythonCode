// CreateSpecificationMode.qml - Updated with SpecificationItemsTable
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./" as Local
import "./"
import "../qml/components/common" as Common
Rectangle {
    id: root

    Local.AddItemDialog {
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

    color: Theme.background

    signal backToMain()

    property int currentSpecId: -1
    property string currentSpecName: ""
    property bool isEditMode: currentSpecId !== -1
    property bool hasChanges: false

    // Calculation properties
    property real materialsCost: 0
    property real laborCost: 0
    property real overheadCost: 0
    property real totalCost: 0

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

    // Connect to model's totalCostChanged signal
    Connections {
        target: specificationItemsModel
        function onTotalCostChanged() {
            calculateCosts()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========================================
        // HEADER
        // ========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Theme.primary

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Button {
                    text: "← Главное меню"
                    onClicked: {
                        if (hasChanges) {
                            confirmExitDialog.open()
                        } else {
                            clearForm()
                            backToMain()
                        }
                    }

                    background: Rectangle {
                        color: parent.down ? Theme.primaryDark : (parent.hovered ? Theme.primaryHover : "transparent")
                        radius: 4
                        border.color: Theme.textWhite
                        border.width: 2
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.textWhite
                        font.pointSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    text: isEditMode ? "Редактирование спецификации" : "Создание спецификации"
                    font.pointSize: 18
                    font.bold: true
                    color: Theme.textWhite
                    Layout.fillWidth: true
                }

                Text {
                    text: "📋"
                    font.pointSize: 24
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

                // --- BASIC INFO SECTION ---
                GroupBox {
                    Layout.fillWidth: true
                    title: "Основная информация"
                    font.pointSize: 11
                    font.bold: true

                    background: Rectangle {
                        color: Theme.white
                        border.color: Theme.border
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            // Name field
                            ColumnLayout {
                                Layout.preferredWidth: 800
                                Layout.minimumWidth: 800
                                Layout.maximumWidth: 800
                                spacing: 4

                                Text {
                                    text: "Название изделия *"
                                    font.pointSize: 10
                                    font.bold: true
                                }

                                TextField {
                                    id: nameField
                                    Layout.fillWidth: true
                                    placeholderText: "Например: Изделие А-123"
                                    font.pointSize: 10
                                    onTextChanged: hasChanges = true

                                    background: Rectangle {
                                        color: Theme.white
                                        border.color: nameField.activeFocus ? Theme.primary : Theme.border
                                        border.width: nameField.activeFocus ? 2 : 1
                                        radius: 4
                                    }
                                }
                            }

                            // Status
                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 4

                                Text {
                                    text: "Статус"
                                    font.pointSize: 10
                                    font.bold: true
                                }

                                ComboBox {
                                    id: statusComboBox
                                    Layout.preferredWidth: 200
                                    Layout.minimumWidth: 200
                                    Layout.maximumWidth: 200
                                    model: ["черновик", "утверждена", "архив"]
                                    currentIndex: 0
                                    font.pointSize: 10
                                    onCurrentIndexChanged: hasChanges = true

                                    background: Rectangle {
                                        color: Theme.white
                                        border.color: statusComboBox.activeFocus ? Theme.primary : Theme.border
                                        border.width: statusComboBox.activeFocus ? 2 : 1
                                        radius: 4
                                    }
                                }
                            }
                        }

                        // Description
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Описание"
                                font.pointSize: 10
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                clip: true

                                TextArea {
                                    id: descriptionField
                                    placeholderText: "Подробное описание изделия..."
                                    wrapMode: TextEdit.Wrap
                                    font.pointSize: 10
                                    selectByMouse: true
                                    onTextChanged: hasChanges = true

                                    background: Rectangle {
                                        color: Theme.white
                                        border.color: descriptionField.activeFocus ? Theme.primary : Theme.border
                                        border.width: descriptionField.activeFocus ? 2 : 1
                                        radius: 4
                                    }
                                }
                            }
                        }
                    }
                }

                // --- MATERIALS SECTION ---
                GroupBox {
                    Layout.fillWidth: true
                    title: "Материалы и комплектующие"
                    font.pointSize: 11
                    font.bold: true

                    background: Rectangle {
                        color: Theme.white
                        border.color: Theme.border
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Status indicator
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "#e3f2fd"
                            radius: 4
                            visible: itemsTable.rowCount > 0

                            Text {
                                anchors.centerIn: parent
                                text: "📦 Добавлено позиций: " + itemsTable.rowCount + " | Стоимость материалов: " + materialsCost.toFixed(2) + " ₽"
                                font.pointSize: 10
                                font.bold: true
                                color: Theme.primary
                            }
                        }

                        Button {
                            text: "➕ Добавить позицию из склада"
                            Layout.fillWidth: true
                            font.pointSize: 10

                            background: Rectangle {
                                color: parent.down ? Theme.successDark : (parent.hovered ? Theme.successHover : Theme.success)
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: Theme.textWhite
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                addItemDialog.open()
                            }
                        }

                        // Use the new SpecificationItemsTable component
                        Local.SpecificationItemsTable {
                            id: itemsTable
                            Layout.fillWidth: true
                            Layout.preferredHeight: 500
                            //Theme: root.Theme  // Pass Theme explicitly
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

                // --- COSTS SECTION ---
                GroupBox {
                    Layout.fillWidth: true
                    title: "Калькуляция стоимости"
                    font.pointSize: 11
                    font.bold: true

                    background: Rectangle {
                        color: Theme.white
                        border.color: Theme.border
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 15

                        // Labor cost
                        Text {
                            text: "Стоимость работы (₽):"
                            font.pointSize: 10
                        }
                        TextField {
                            id: laborCostField
                            Layout.fillWidth: true
                            text: "0"
                            font.pointSize: 10
                            horizontalAlignment: Text.AlignRight
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            onTextChanged: {
                                hasChanges = true
                                calculateCosts()
                            }

                            background: Rectangle {
                                color: Theme.white
                                border.color: laborCostField.activeFocus ? Theme.primary : Theme.border
                                border.width: laborCostField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        // Overhead percentage
                        Text {
                            text: "Накладные расходы (%):"
                            font.pointSize: 10
                        }
                        TextField {
                            id: overheadField
                            Layout.fillWidth: true
                            text: "0"
                            font.pointSize: 10
                            horizontalAlignment: Text.AlignRight
                            validator: DoubleValidator { bottom: 0; top: 100; decimals: 2 }
                            onTextChanged: {
                                hasChanges = true
                                calculateCosts()
                            }

                            background: Rectangle {
                                color: Theme.white
                                border.color: overheadField.activeFocus ? Theme.primary : Theme.border
                                border.width: overheadField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        // Divider
                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: Theme.tableHeader
                        }

                        // Cost breakdown
                        Text {
                            text: "Материалы:"
                            font.pointSize: 10
                            color: Theme.textSecondary
                        }
                        Text {
                            text: materialsCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: Theme.textPrimary
                        }

                        Text {
                            text: "Работа:"
                            font.pointSize: 10
                            color: Theme.textSecondary
                        }
                        Text {
                            text: laborCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: Theme.textPrimary
                        }

                        Text {
                            text: "Накладные:"
                            font.pointSize: 10
                            color: Theme.textSecondary
                        }
                        Text {
                            text: overheadCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: Theme.textPrimary
                        }

                        // Total
                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: Theme.textSuccess
                        }

                        Text {
                            text: "ИТОГО:"
                            font.pointSize: 12
                            font.bold: true
                            color: Theme.textSuccess
                        }
                        Text {
                            text: totalCost.toFixed(2) + " ₽"
                            font.pointSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: Theme.textSuccess
                        }
                    }
                }

                // --- ACTION BUTTONS ---
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 15
                    spacing: 10

                    Button {
                        text: "💾 Сохранить"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: nameField.text.trim().length > 0 && itemsTable.rowCount > 0
                        font.pointSize: 11

                        background: Rectangle {
                            color: {
                                if (!parent.enabled) return Theme.disabled
                                if (parent.down) return Theme.successDark
                                if (parent.hovered) return Theme.successHover
                                return Theme.success
                            }
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: parent.enabled ? Theme.textWhite : Theme.textPlaceholder
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Debug: print items before save
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
                                notificationDialog.dialogType = "success"
                                notificationDialog.message = "Спецификация успешно сохранена!"
                                notificationDialog.showCancelButton = false
                                notificationDialog.open()
                            } else {
                                notificationDialog.dialogType = "error"
                                notificationDialog.message = "Ошибка при сохранении спецификации!"
                                notificationDialog.showCancelButton = false
                                notificationDialog.open()
                            }
                        }
                    }

                    Button {
                        text: "📄 Экспорт в Excel"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: currentSpecId > 0
                        font.pointSize: 11

                        background: Rectangle {
                            color: {
                                if (!parent.enabled) return Theme.disabled
                                if (parent.down) return Theme.infoDark
                                if (parent.hovered) return Theme.infoHover
                                return Theme.info
                            }
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: parent.enabled ? Theme.textWhite : Theme.textPlaceholder
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var result = specificationsModel.exportToExcel(currentSpecId)
                            notificationDialog.dialogType = result ? "success" : "error"
                            notificationDialog.message = result ? "Успешно экспортировано в Excel!" : "Ошибка при экспорте в Excel!"
                            notificationDialog.showCancelButton = false
                            notificationDialog.open()
                        }
                    }

                    Button {
                        text: "📕 Экспорт в PDF"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: currentSpecId > 0
                        font.pointSize: 11

                        background: Rectangle {
                            color: {
                                if (!parent.enabled) return Theme.disabled
                                if (parent.down) return Theme.dangerDark
                                if (parent.hovered) return Theme.dangerHover
                                return Theme.danger
                            }
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: parent.enabled ? Theme.textWhite : Theme.textPlaceholder
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var result = specificationsModel.exportToPDF(currentSpecId)
                            notificationDialog.dialogType = result ? "success" : "error"
                            notificationDialog.message = result ? "Успешно экспортировано в PDF!" : "Ошибка при экспорте в PDF!"
                            notificationDialog.showCancelButton = false
                            notificationDialog.open()
                        }
                    }

                    Button {
                        text: "🗑️ Очистить"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 45
                        font.pointSize: 11

                        background: Rectangle {
                            color: parent.down ? Theme.neutralDark : (parent.hovered ? Theme.neutralHover : Theme.neutral)
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Theme.textWhite
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

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
    // DIALOGS
    // ========================================

    // Universal notification dialog
    Common.NotificationDialog {
        id: notificationDialog
        onAccepted: {}
        onRejected: {}
    }

    // Confirm exit dialog
    Common.NotificationDialog {
        id: confirmExitDialog
        dialogType: "warning"
        message: "У вас есть несохраненные изменения. \n Выйти без сохранения?"
        showCancelButton: true
        onAccepted: {
            clearForm()
            backToMain()
        }
    }

    // Confirm clear dialog
    Common.NotificationDialog {
        id: confirmClearDialog
        dialogType: "warning"
        message: "Вы уверены, что хотите очистить форму? \n Все несохраненные данные будут потеряны."
        showCancelButton: true
        onAccepted: {
            clearForm()
        }
    }
}