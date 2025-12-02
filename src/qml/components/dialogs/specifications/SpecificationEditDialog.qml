// SpecificationEditDialog.qml - Диалог редактирования спецификации
// Расположение: src/qml/components/specifications/
// NOTE: Скопируйте полный код из оригинального файла (строки 687-1160)
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Local  // Доступ к старым компонентам (временно)

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

    contentItem: ScrollView {
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 15

            GroupBox {
                Layout.fillWidth: true
                title: "Основная информация"
                font.pointSize: 11
                font.bold: true

                background: Rectangle {
                    color: "white"
                    border.color: "#d0d0d0"
                    radius: 6
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.preferredWidth: 500
                            Layout.minimumWidth: 500
                            Layout.maximumWidth: 500
                            spacing: 4

                            Text {
                                text: "Название изделия *"
                                font.pointSize: 10
                                font.bold: true
                            }

                            TextField {
                                id: editNameField
                                Layout.fillWidth: true
                                placeholderText: "Например: Изделие А-123"
                                font.pointSize: 10
                                onTextChanged: editSpecificationDialog.hasChanges = true

                                background: Rectangle {
                                    color: "white"
                                    border.color: editNameField.activeFocus ? "#9b59b6" : "#d0d0d0"
                                    border.width: editNameField.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                        }

                        ColumnLayout {
                             Layout.preferredWidth: 200
                             Layout.minimumWidth: 200
                             Layout.maximumWidth: 200
                            spacing: 4

                            Text {
                                text: "Статус"
                                font.pointSize: 10
                                font.bold: true
                            }

                            ComboBox {
                                id: editStatusComboBox
                                Layout.fillWidth: true
                                model: ["черновик", "утверждена", "архив"]
                                font.pointSize: 10
                                onCurrentIndexChanged: editSpecificationDialog.hasChanges = true

                                background: Rectangle {
                                    color: "white"
                                    border.color: editStatusComboBox.activeFocus ? "#9b59b6" : "#d0d0d0"
                                    border.width: editStatusComboBox.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                        }
                    }

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
                                id: editDescriptionField
                                placeholderText: "Подробное описание изделия..."
                                wrapMode: TextEdit.Wrap
                                font.pointSize: 10
                                selectByMouse: true
                                onTextChanged: editSpecificationDialog.hasChanges = true

                                background: Rectangle {
                                    color: "white"
                                    border.color: editDescriptionField.activeFocus ? "#9b59b6" : "#d0d0d0"
                                    border.width: editDescriptionField.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Материалы и комплектующие"
                font.pointSize: 11
                font.bold: true

                background: Rectangle {
                    color: "white"
                    border.color: "#d0d0d0"
                    radius: 6
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "#e3f2fd"
                        radius: 4
                        visible: editItemsTable.rowCount > 0

                        Text {
                            anchors.centerIn: parent
                            text: "📦 Позиций: " + editItemsTable.rowCount + " | Стоимость материалов: " + editSpecificationDialog.materialsCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            color: "#2196F3"
                        }
                    }

                    Button {
                        text: "➕ Добавить позицию из склада"
                        Layout.fillWidth: true
                        font.pointSize: 10

                        background: Rectangle {
                            color: parent.down ? "#218838" : (parent.hovered ? "#1e7e34" : "#28a745")
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: addItemDialog.open()
                    }

                    Local.SpecificationItemsTable {
                        id: editItemsTable
                        Layout.fillWidth: true
                        Layout.preferredHeight: 400
                        model: specificationItemsModel
                        readOnly: false

                        onItemQuantityChanged: function(row, newQuantity) {
                            specificationItemsModel.updateQuantity(row, newQuantity)
                            editSpecificationDialog.hasChanges = true
                            editSpecificationDialog.calculateEditCosts()
                        }

                        onItemRemoved: function(row) {
                            specificationItemsModel.removeItem(row)
                            editSpecificationDialog.hasChanges = true
                            editSpecificationDialog.calculateEditCosts()
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Калькуляция стоимости"
                font.pointSize: 11
                font.bold: true

                background: Rectangle {
                    color: "white"
                    border.color: "#d0d0d0"
                    radius: 6
                    y: parent.topPadding - parent.bottomPadding
                }

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 15

                    Text {
                        text: "Стоимость работы (₽):"
                        font.pointSize: 10
                    }
                    TextField {
                        id: editLaborCostField
                        Layout.fillWidth: true
                        text: "0"
                        font.pointSize: 10
                        horizontalAlignment: Text.AlignRight
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        onTextChanged: {
                            editSpecificationDialog.hasChanges = true
                            editSpecificationDialog.calculateEditCosts()
                        }

                        background: Rectangle {
                            color: "white"
                            border.color: editLaborCostField.activeFocus ? "#9b59b6" : "#d0d0d0"
                            border.width: editLaborCostField.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }

                    Text {
                        text: "Накладные расходы (%):"
                        font.pointSize: 10
                    }
                    TextField {
                        id: editOverheadField
                        Layout.fillWidth: true
                        text: "0"
                        font.pointSize: 10
                        horizontalAlignment: Text.AlignRight
                        validator: DoubleValidator { bottom: 0; top: 100; decimals: 2 }
                        onTextChanged: {
                            editSpecificationDialog.hasChanges = true
                            editSpecificationDialog.calculateEditCosts()
                        }

                        background: Rectangle {
                            color: "white"
                            border.color: editOverheadField.activeFocus ? "#9b59b6" : "#d0d0d0"
                            border.width: editOverheadField.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }

                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        height: 2
                        color: "#e0e0e0"
                    }

                    Text {
                        text: "Материалы:"
                        font.pointSize: 10
                        color: "#666"
                    }
                    Text {
                        text: editSpecificationDialog.materialsCost.toFixed(2) + " ₽"
                        font.pointSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#2c3e50"
                    }

                    Text {
                        text: "Работа:"
                        font.pointSize: 10
                        color: "#666"
                    }
                    Text {
                        text: editSpecificationDialog.laborCost.toFixed(2) + " ₽"
                        font.pointSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#2c3e50"
                    }

                    Text {
                        text: "Накладные:"
                        font.pointSize: 10
                        color: "#666"
                    }
                    Text {
                        text: editSpecificationDialog.overheadCost.toFixed(2) + " ₽"
                        font.pointSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#2c3e50"
                    }

                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        height: 2
                        color: "#28a745"
                    }

                    Text {
                        text: "ИТОГО:"
                        font.pointSize: 12
                        font.bold: true
                        color: "#28a745"
                    }
                    Text {
                        text: editSpecificationDialog.totalCost.toFixed(2) + " ₽"
                        font.pointSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#28a745"
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
            Button {
                text: "💾 Сохранить изменения"
                enabled: editNameField.text.trim().length > 0 && editItemsTable.rowCount > 0

                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#cccccc"
                        if (parent.down) return "#218838"
                        if (parent.hovered) return "#1e7e34"
                        return "#28a745"
                    }
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : "#999"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: editSpecificationDialog.saveChanges()
            }

            Button {
                text: "❌ Отмена"

                background: Rectangle {
                    color: parent.down ? "#5a6268" : (parent.hovered ? "#545b62" : "#6c757d")
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (editSpecificationDialog.hasChanges) {
                        confirmCancelEditDialog.open()
                    } else {
                        editSpecificationDialog.close()
                    }
                }
            }
        }
    }

    // Заглушки для полей
    property var editNameField: QtObject { property string text: "" }
    property var editDescriptionField: QtObject { property string text: "" }
    property var editLaborCostField: QtObject { property string text: "0" }
    property var editOverheadField: QtObject { property string text: "0" }
    property var editStatusComboBox: QtObject { property int currentIndex: 0; property string currentText: "черновик" }
}
