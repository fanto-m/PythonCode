// CreateSpecificationMode.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f5f5f5"

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

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========================================
        // HEADER
        // ========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#f39c12"

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
                        color: parent.down ? "#d68910" : (parent.hovered ? "#2c3e50" : "transparent")
                        radius: 4
                        border.color: "white"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pointSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    text: isEditMode ? "Редактирование спецификации" : "Создание спецификации"
                    font.pointSize: 18
                    font.bold: true
                    color: "white"
                    Layout.fillWidth: true
                }

                Text {
                    text: "📝"
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
                //width: parent.width - 20
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

                            // Name field
                            ColumnLayout {
                                Layout.fillWidth: true
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
                                        color: "white"
                                        border.color: nameField.activeFocus ? "#f39c12" : "#d0d0d0"
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
                                    Layout.fillWidth: true
                                    model: ["черновик", "утверждена", "архив"]
                                    currentIndex: 0
                                    font.pointSize: 10
                                    onCurrentIndexChanged: hasChanges = true

                                    background: Rectangle {
                                        color: "white"
                                        border.color: statusComboBox.activeFocus ? "#f39c12" : "#d0d0d0"
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
                                        color: "white"
                                        border.color: descriptionField.activeFocus ? "#f39c12" : "#d0d0d0"
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
                        color: "white"
                        border.color: "#d0d0d0"
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Button {
                            text: "➕ Добавить позицию из склада"
                            Layout.fillWidth: true
                            font.pointSize: 10

                            background: Rectangle {
                                color: parent.down ? "#27ae60" : (parent.hovered ? "#2ecc71" : "#2ecc71")
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
                                addItemDialog.open()
                            }
                        }

                        // Items table
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 500
                            border.color: "#d0d0d0"
                            border.width: 1
                            radius: 4
                            color: "#fafafa"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 1
                                spacing: 0

                                // Header
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    color: "#e0e0e0"

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Text {
                                            text: "Вид"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.preferredWidth: 60  // Match image width
                                            Layout.leftMargin: 10
                                        }

                                        Text {
                                            text: "Артикул"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.preferredWidth: 100
                                            Layout.leftMargin: 10
                                        }
                                        Text {
                                            text: "Название"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 10
                                        }
                                        Text {
                                            text: "Категория"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 10
                                        }
                                        Text {
                                            text: "Кол-во"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.preferredWidth: 80
                                            Layout.leftMargin: 10
                                        }
                                        Text {
                                            text: "Ед."
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.preferredWidth: 50
                                            Layout.leftMargin: 10
                                        }
                                        Text {
                                            text: "Цена"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.preferredWidth: 90
                                            Layout.leftMargin: 10
                                        }
                                        Text {
                                            text: "Сумма"
                                            font.bold: true
                                            font.pointSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                            Layout.preferredWidth: 90
                                            Layout.leftMargin: 10
                                        }
                                        Item {
                                            Layout.preferredWidth: 50  // Space for delete button
                                        }
                                    }
                                }

                                // Items list
                                ListView {
                                    id: itemsListView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: specificationItemsModel

                                    delegate: Rectangle {
                                        width: itemsListView.width
                                        height: 60
                                        color: index % 2 ? "white" : "#f9f9f9"
                                        border.color: "#e0e0e0"
                                        border.width: 1

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0

                                            // Image - 60px width to match header
                                            Rectangle {
                                                Layout.preferredWidth: 60
                                                Layout.preferredHeight: 50
                                                Layout.leftMargin: 10
                                                Layout.alignment: Qt.AlignVCenter
                                                color: "#f5f5f5"
                                                border.color: "#d0d0d0"
                                                border.width: 1
                                                radius: 4

                                                Image {
                                                    anchors.fill: parent
                                                    anchors.margins: 2
                                                    source: model.image_path ? "../images/" + model.image_path : ""
                                                    fillMode: Image.PreserveAspectFit
                                                    smooth: true
                                                    visible: model.image_path && model.image_path !== ""
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "📦"
                                                    font.pointSize: 20
                                                    visible: !model.image_path || model.image_path === ""
                                                    color: "#999"
                                                }
                                            }

                                            Text {
                                                text: model.article
                                                font.pointSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.preferredWidth: 100
                                                Layout.leftMargin: 10
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                text: model.name
                                                font.pointSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.fillWidth: true
                                                Layout.leftMargin: 10
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                text: model.category
                                                font.pointSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.fillWidth: true
                                                Layout.leftMargin: 10
                                                elide: Text.ElideRight
                                            }
                                            TextField {
                                                id: quantityField
                                                text: model.quantity.toString()
                                                Layout.preferredWidth: 70
                                                Layout.leftMargin: 10
                                                font.pointSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignRight
                                                validator: DoubleValidator { bottom: 0; decimals: 3 }

                                                onEditingFinished: {
                                                    if (text !== "" && text !== model.quantity.toString()) {
                                                        var newValue = parseFloat(text)
                                                        if (!isNaN(newValue)) {
                                                            model.quantity = newValue
                                                            hasChanges = true
                                                            calculateCosts()
                                                        }
                                                    }
                                                }

                                                background: Rectangle {
                                                    color: "white"
                                                    border.color: quantityField.activeFocus ? "#f39c12" : "#d0d0d0"
                                                    border.width: 1
                                                    radius: 3
                                                }
                                            }
                                            Text {
                                                text: model.unit
                                                font.pointSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.preferredWidth: 50
                                                Layout.leftMargin: 10
                                            }
                                            Text {
                                                text: model.price.toFixed(2) + " ₽"
                                                font.pointSize: 12
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.preferredWidth: 90
                                                Layout.leftMargin: 10
                                                horizontalAlignment: Text.AlignRight
                                                color: "#007bff"
                                            }
                                            Text {
                                                text: (model.quantity * model.price).toFixed(2) + " ₽"
                                                font.pointSize: 12
                                                font.bold: true
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.preferredWidth: 90
                                                Layout.leftMargin: 10
                                                horizontalAlignment: Text.AlignRight
                                                color: "#28a745"
                                            }
                                            Button {
                                                text: "🗑️"
                                                Layout.preferredWidth: 40
                                                Layout.preferredHeight: 30
                                                Layout.alignment: Qt.AlignVCenter
                                                font.pointSize: 10
                                                onClicked: {
                                                    specificationItemsModel.removeItem(index)
                                                    hasChanges = true
                                                    calculateCosts()
                                                }

                                                background: Rectangle {
                                                    color: parent.hovered ? "#dc3545" : "transparent"
                                                    radius: 3
                                                }
                                            }
                                        }
                                    }

                                    Label {
                                        anchors.centerIn: parent
                                        visible: itemsListView.count === 0
                                        text: "Нет материалов\nДобавьте позиции из склада"
                                        font.pointSize: 10
                                        color: "#999"
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    ScrollBar.vertical: ScrollBar {}
                                }
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
                                color: "white"
                                border.color: laborCostField.activeFocus ? "#f39c12" : "#d0d0d0"
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
                                color: "white"
                                border.color: overheadField.activeFocus ? "#f39c12" : "#d0d0d0"
                                border.width: overheadField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        // Divider
                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: "#e0e0e0"
                        }

                        // Cost breakdown
                        Text {
                            text: "Материалы:"
                            font.pointSize: 10
                            color: "#555"
                        }
                        Text {
                            text: materialsCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#007bff"
                        }

                        Text {
                            text: "Работа:"
                            font.pointSize: 10
                            color: "#555"
                        }
                        Text {
                            text: laborCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#007bff"
                        }

                        Text {
                            text: "Накладные:"
                            font.pointSize: 10
                            color: "#555"
                        }
                        Text {
                            text: overheadCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#007bff"
                        }

                        // Total
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
                            text: totalCost.toFixed(2) + " ₽"
                            font.pointSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#28a745"
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
                        enabled: nameField.text.trim().length > 0 && itemsListView.count > 0
                        font.pointSize: 11

                        background: Rectangle {
                            color: {
                                if (!parent.enabled) return "#e0e0e0"
                                if (parent.down) return "#1e7e34"
                                if (parent.hovered) return "#218838"
                                return "#28a745"
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

                        onClicked: {
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
                                successDialog.message = "Спецификация успешно сохранена!"
                                successDialog.open()
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
                                if (!parent.enabled) return "#e0e0e0"
                                if (parent.down) return "#117a8b"
                                if (parent.hovered) return "#138496"
                                return "#17a2b8"
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

                        onClicked: {
                            var result = specificationsModel.exportToExcel(currentSpecId);
                            if (!result) {
                                successDialog.message = "Ошибка при экспорте в Excel!";
                                successDialog.open();
                            }
                        }
                    }

                    Button {
                        text: "📑 Экспорт в PDF"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        enabled: currentSpecId > 0
                        font.pointSize: 11

                        background: Rectangle {
                            color: {
                                if (!parent.enabled) return "#e0e0e0"
                                if (parent.down) return "#c82333"
                                if (parent.hovered) return "#e02535"
                                return "#dc3545"
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

                        onClicked: {
                            var result = specificationsModel.exportToPDF(currentSpecId);
                            if (!result) {
                                successDialog.message = "Ошибка при экспорте в PDF!";
                                successDialog.open();
                            }
                        }
                    }

                    Button {
                        text: "🗑️ Очистить"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 45
                        font.pointSize: 11

                        background: Rectangle {
                            color: parent.down ? "#5a6268" : (parent.hovered ? "#6c757d" : "#6c757d")
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: "white"
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

    // Add item from warehouse dialog
    Dialog {
        id: addItemDialog
        title: "Добавить позицию из склада"
        modal: true
        width: 700
        height: 500
        anchors.centerIn: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Поиск товара..."
                font.pointSize: 10
                onTextChanged: {
                    // Filter warehouse items
                    itemsModel.setFilterString(text)
                }
            }

            ListView {
                id: warehouseListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: itemsModel

                delegate: Rectangle {
                    width: warehouseListView.width
                    height: 80  // Increased height to accommodate image
                    color: mouseArea.containsMouse ? "#f0f0f0" : "white"
                    border.color: "#e0e0e0"
                    border.width: 1

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            specificationItemsModel.addItem( //line 802
                                model.article,
                                model.name,
                                1.0,  // default quantity
                                model.unit,
                                model.price,
                                model.image_path || "",  // Added missing image_path parameter
                                model.category || ""
                            )
                            hasChanges = true
                            calculateCosts()
                            addItemDialog.close()
                            searchField.text = ""
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // Image viewer
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            color: "#f5f5f5"
                            border.color: "#d0d0d0"
                            border.width: 1
                            radius: 4

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: model.image_path ? "../images/" + model.image_path : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: model.image_path && model.image_path !== ""
                            }

                            // Placeholder icon when no image
                            Text {
                                anchors.centerIn: parent
                                text: "📦"
                                font.pointSize: 24
                                visible: !model.image_path || model.image_path === ""
                                color: "#999"
                            }
                        }

                        // Item details
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 2

                            Text {
                                text: model.name
                                font.pointSize: 10
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Артикул: " + model.article + " | На складе: " + model.stock + " " + model.unit
                                font.pointSize: 9
                                color: "#666"
                            }

                            // Category (if available)
                            Text {
                                text: "Категория: " + (model.category || "Не указана")
                                font.pointSize: 8
                                color: "#999"
                                visible: model.category !== undefined
                            }
                        }

                        // Price
                        Text {
                            text: model.price.toFixed(2) + " ₽"
                            font.pointSize: 11
                            font.bold: true
                            color: "#007bff"
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: warehouseListView.count === 0
                    text: "Товары не найдены"
                    font.pointSize: 10
                    color: "#999"
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "Закрыть"
                onClicked: {
                    addItemDialog.close()
                    searchField.text = ""
                }
            }
        }
    }

    // Confirm exit dialog
    Dialog {
        id: confirmExitDialog
        title: "Несохраненные изменения"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No

        Text {
            text: "У вас есть несохраненные изменения.\nВыйти без сохранения?"
        }

        onAccepted: {
            clearForm()
            backToMain()
        }
    }

    // Confirm clear dialog
    Dialog {
        id: confirmClearDialog
        title: "Очистить форму"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No

        Text {
            text: "Вы уверены, что хотите очистить форму?\nВсе несохраненные данные будут потеряны."
        }

        onAccepted: clearForm()
    }

    // Success dialog
    Dialog {
        id: successDialog
        title: "Успех"
        modal: true
        anchors.centerIn: parent
        width: 300
        height: 150

        property string message: ""

        contentItem: Text {
            text: successDialog.message
            wrapMode: Text.WordWrap
            anchors.centerIn: parent
            padding: 20
        }

        footer: DialogButtonBox {
            Button {
                text: "OK"
                onClicked: successDialog.close()
            }
        }
    }
}