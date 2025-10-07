// ControlPanel.qml - Fixed Edit Mode Overlap
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    Layout.preferredWidth: 416
    Layout.fillHeight: true

    color: "#ffffff"
    border.width: 1
    border.color: "#d0d0d0"
    radius: 6

    // Theme constants
    readonly property color primaryColor: "#2196F3"
    readonly property color errorColor: "#f44336"
    readonly property color successColor: "#4caf50"
    readonly property color borderColor: "#d0d0d0"
    readonly property color focusBorderColor: primaryColor
    readonly property int baseSpacing: 10
    readonly property int baseFontSize: 10

    // Content padding
    property int contentLeftPadding: 12
    property int contentRightPadding: 12
    property int contentTopPadding: 12
    property int contentBottomPadding: 12

    // Signals
    signal addItemClicked(var itemData)
    signal saveItemClicked(int itemIndex, var itemData)
    signal addCategoryClicked()
    signal editCategoryClicked(var categoryData)
    signal deleteCategoryClicked(var categoryData)

    // Properties
    property alias imageField: imageField
    property int currentItemId: -1
    property string currentArticle: ""
    property bool isEditMode: currentItemId !== -1

    // Validation state
    property bool hasValidationErrors: false

    // Public functions
    function populateFields(data) {
        currentItemId = data.index
        currentArticle = data.article
        articleField.text = data.article
        nameField.text = data.name
        descriptionField.text = data.description
        imageField.text = data.image_path.split("/").pop()
        priceField.text = String(data.price)
        stockField.text = String(data.stock)

        var statusIndex = statusComboBox.model.indexOf(data.status || "в наличии")
        statusComboBox.currentIndex = statusIndex >= 0 ? statusIndex : 0

        var unitIndex = unitComboBox.model.indexOf(data.unit || "шт.")
        unitComboBox.currentIndex = unitIndex >= 0 ? unitIndex : 0

        var idx = categoryModel.indexOfName(data.category)
        categoryComboBox.currentIndex = idx

        clearErrors()
    }

    function clearFields() {
        currentItemId = -1
        currentArticle = ""
        articleField.text = ""
        nameField.text = ""
        descriptionField.text = ""
        imageField.text = ""
        priceField.text = ""
        stockField.text = ""
        statusComboBox.currentIndex = -1
        unitComboBox.currentIndex = -1
        categoryComboBox.currentIndex = -1
        clearErrors()
    }

    function clearErrors() {
        articleField.hasError = false
        priceField.hasError = false
        stockField.hasError = false
        hasValidationErrors = false
    }

    function validateFields() {
        clearErrors()
        var isValid = true

        if (articleField.text.trim() === "") {
            articleField.hasError = true
            isValid = false
        }

        if (priceField.text.trim() === "" || parseFloat(priceField.text) < 0) {
            priceField.hasError = true
            isValid = false
        }

        if (stockField.text.trim() === "" || parseInt(stockField.text) < 0) {
            stockField.hasError = true
            isValid = false
        }

        hasValidationErrors = !isValid
        return isValid
    }

    // Main content wrapper
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 2
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            id: mainColumn
            width: scrollView.width - (root.contentLeftPadding + root.contentRightPadding)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: baseSpacing

            // Top spacer
            Item { Layout.preferredHeight: root.contentTopPadding }

            // Mode indicator - FIXED LAYOUT
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 65
                visible: isEditMode
                color: "#e3f2fd"
                border.color: primaryColor
                radius: 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "✏️"
                            font.pointSize: baseFontSize + 2
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Режим редактирования"
                            font.pointSize: baseFontSize
                            font.bold: true
                            color: "#1565c0"
                        }
                    }

                    Button {
                        text: "Очистить"
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: 100
                        flat: true
                        font.pointSize: baseFontSize - 1
                        onClicked: clearFields()

                        background: Rectangle {
                            color: parent.down ? "#bbdefb" : (parent.hovered ? "#d1e7fd" : "transparent")
                            radius: 3
                        }

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: "#1565c0"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Category section
            GroupBox {
                Layout.fillWidth: true
                title: "Категория"
                font.pointSize: baseFontSize
                font.bold: true

                background: Rectangle {
                    color: "#fafafa"
                    border.color: borderColor
                    radius: 4
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    ComboBox {
                        id: categoryComboBox
                        Layout.fillWidth: true
                        model: categoryModel
                        textRole: "name"
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: "white"
                            border.color: categoryComboBox.activeFocus ? focusBorderColor : borderColor
                            border.width: categoryComboBox.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Button {
                            text: "➕"
                            Layout.fillWidth: true
                            font.pointSize: baseFontSize + 2
                            ToolTip.visible: hovered
                            ToolTip.text: "Добавить категорию"
                            onClicked: addCategoryClicked()
                        }

                        Button {
                            text: "✏️"
                            Layout.fillWidth: true
                            enabled: categoryComboBox.currentIndex >= 0
                            font.pointSize: baseFontSize + 2
                            ToolTip.visible: hovered
                            ToolTip.text: "Редактировать категорию"
                            onClicked: {
                                if (categoryComboBox.currentIndex >= 0) {
                                    let cat = categoryModel.get(categoryComboBox.currentIndex)
                                    editCategoryClicked(cat)
                                }
                            }
                        }

                        Button {
                            text: "🗑️"
                            enabled: categoryComboBox.currentIndex >= 0
                            font.pointSize: baseFontSize + 2
                            ToolTip.visible: hovered
                            ToolTip.text: "Удалить категорию"
                            onClicked: {
                                if (categoryComboBox.currentIndex >= 0) {
                                    deleteCategoryClicked({
                                        id: categoryModel.get(categoryComboBox.currentIndex).id,
                                        name: categoryComboBox.currentText
                                    })
                                }
                            }
                        }
                    }
                }
            }

            // Article field with generator
            GroupBox {
                Layout.fillWidth: true
                title: "Артикул *"
                font.pointSize: baseFontSize
                font.bold: true

                background: Rectangle {
                    color: articleField.hasError ? "#ffebee" : "#fafafa"
                    border.color: borderColor
                    radius: 4
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        TextField {
                            id: articleField
                            Layout.fillWidth: true
                            placeholderText: "Введите артикул"
                            font.pointSize: baseFontSize
                            property bool hasError: false

                            background: Rectangle {
                                color: "white"
                                border.color: {
                                    if (articleField.hasError) return errorColor
                                    if (articleField.activeFocus) return focusBorderColor
                                    return borderColor
                                }
                                border.width: articleField.activeFocus ? 2 : 1
                                radius: 4
                            }

                            onTextChanged: if (hasError && text.trim() !== "") hasError = false
                        }

                        Button {
                            text: "🎲"
                            enabled: categoryComboBox.currentIndex >= 0
                            font.pointSize: baseFontSize + 2
                            ToolTip.visible: hovered
                            ToolTip.text: "Сгенерировать артикул"
                            onClicked: {
                                var categoryId = categoryModel.get(categoryComboBox.currentIndex).id
                                var generatedSku = categoryModel.generateSkuForCategory(categoryId)
                                if (generatedSku) {
                                    articleField.text = generatedSku
                                }
                            }
                        }
                    }

                    Text {
                        visible: articleField.hasError
                        text: "⚠️ Артикул обязателен для заполнения"
                        font.pointSize: baseFontSize - 1
                        color: errorColor
                    }
                }
            }

            // Name field
            GroupBox {
                Layout.fillWidth: true
                title: "Название товара *"
                font.pointSize: baseFontSize
                font.bold: true

                background: Rectangle {
                    color: "#fafafa"
                    border.color: borderColor
                    radius: 4
                    y: parent.topPadding - parent.bottomPadding
                }

                TextField {
                    id: nameField
                    anchors.fill: parent
                    placeholderText: "Введите название"
                    font.pointSize: baseFontSize

                    background: Rectangle {
                        color: "white"
                        border.color: nameField.activeFocus ? focusBorderColor : borderColor
                        border.width: nameField.activeFocus ? 2 : 1
                        radius: 4
                    }
                }
            }

            // Description field
            GroupBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                title: "Описание"
                font.pointSize: baseFontSize
                font.bold: true

                background: Rectangle {
                    color: "#fafafa"
                    border.color: borderColor
                    radius: 4
                    y: parent.topPadding - parent.bottomPadding
                }

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    TextArea {
                        id: descriptionField
                        placeholderText: "Введите описание товара..."
                        wrapMode: TextEdit.Wrap
                        font.pointSize: baseFontSize
                        selectByMouse: true

                        background: Rectangle {
                            color: "white"
                            border.color: descriptionField.activeFocus ? focusBorderColor : borderColor
                            border.width: descriptionField.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }
                }
            }

            // Image field
            GroupBox {
                Layout.fillWidth: true
                title: "Изображение"
                font.pointSize: baseFontSize
                font.bold: true

                background: Rectangle {
                    color: "#fafafa"
                    border.color: borderColor
                    radius: 4
                    y: parent.topPadding - parent.bottomPadding
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 6

                    TextField {
                        id: imageField
                        Layout.fillWidth: true
                        placeholderText: "Выберите файл..."
                        readOnly: true
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: "#f5f5f5"
                            border.color: borderColor
                            radius: 4
                        }
                    }

                    Button {
                        text: "📁"
                        font.pointSize: baseFontSize + 2
                        ToolTip.visible: hovered
                        ToolTip.text: "Выбрать файл"
                        onClicked: fileDialog.open()
                    }
                }
            }

            // Price and Stock row
            RowLayout {
                Layout.fillWidth: true
                spacing: baseSpacing

                GroupBox {
                    Layout.fillWidth: true
                    title: "Цена *"
                    font.pointSize: baseFontSize
                    font.bold: true

                    background: Rectangle {
                        color: priceField.hasError ? "#ffebee" : "#fafafa"
                        border.color: borderColor
                        radius: 4
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 4

                        TextField {
                            id: priceField
                            Layout.fillWidth: true
                            placeholderText: "0.00"
                            font.pointSize: baseFontSize
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            property bool hasError: false

                            background: Rectangle {
                                color: "white"
                                border.color: {
                                    if (priceField.hasError) return errorColor
                                    if (priceField.activeFocus) return focusBorderColor
                                    return borderColor
                                }
                                border.width: priceField.activeFocus ? 2 : 1
                                radius: 4
                            }

                            onTextChanged: if (hasError && text.trim() !== "") hasError = false
                        }

                        Text {
                            visible: priceField.hasError
                            text: "⚠️ Неверная цена"
                            font.pointSize: baseFontSize - 2
                            color: errorColor
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Остаток *"
                    font.pointSize: baseFontSize
                    font.bold: true

                    background: Rectangle {
                        color: stockField.hasError ? "#ffebee" : "#fafafa"
                        border.color: borderColor
                        radius: 4
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 4

                        TextField {
                            id: stockField
                            Layout.fillWidth: true
                            placeholderText: "0"
                            font.pointSize: baseFontSize
                            inputMethodHints: Qt.ImhDigitsOnly
                            property bool hasError: false

                            background: Rectangle {
                                color: "white"
                                border.color: {
                                    if (stockField.hasError) return errorColor
                                    if (stockField.activeFocus) return focusBorderColor
                                    return borderColor
                                }
                                border.width: stockField.activeFocus ? 2 : 1
                                radius: 4
                            }

                            onTextChanged: if (hasError && text.trim() !== "") hasError = false
                        }

                        Text {
                            visible: stockField.hasError
                            text: "⚠️ Неверный остаток"
                            font.pointSize: baseFontSize - 2
                            color: errorColor
                        }
                    }
                }
            }

            // Status and Unit row
            RowLayout {
                Layout.fillWidth: true
                spacing: baseSpacing

                GroupBox {
                    Layout.fillWidth: true
                    title: "Статус"
                    font.pointSize: baseFontSize
                    font.bold: true

                    background: Rectangle {
                        color: "#fafafa"
                        border.color: borderColor
                        radius: 4
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ComboBox {
                        id: statusComboBox
                        anchors.fill: parent
                        model: ["в наличии", "под заказ", "архив"]
                        currentIndex: 0
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: "white"
                            border.color: statusComboBox.activeFocus ? focusBorderColor : borderColor
                            border.width: statusComboBox.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Ед. изм."
                    font.pointSize: baseFontSize
                    font.bold: true

                    background: Rectangle {
                        color: "#fafafa"
                        border.color: borderColor
                        radius: 4
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ComboBox {
                        id: unitComboBox
                        anchors.fill: parent
                        model: ["шт.", "м.", "кг.", "л.", "уп."]
                        currentIndex: 0
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: "white"
                            border.color: unitComboBox.activeFocus ? focusBorderColor : borderColor
                            border.width: unitComboBox.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }
                }
            }

            // Suppliers section
            GroupBox {
                Layout.fillWidth: true
                title: "Поставщики"
                font.pointSize: baseFontSize
                font.bold: true

                background: Rectangle {
                    color: "#fafafa"
                    border.color: borderColor
                    radius: 4
                    y: parent.topPadding - parent.bottomPadding
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 6

                    Button {
                        text: "📋 Список"
                        Layout.fillWidth: true
                        font.pointSize: baseFontSize - 1
                        onClicked: {
                            suppliersManagerDialog.openForManagement()
                        }
                    }

                    Button {
                        text: "🔗 Привязать"
                        Layout.fillWidth: true
                        enabled: currentArticle !== ""
                        font.pointSize: baseFontSize - 1
                        onClicked: {
                            suppliersManagerDialog.openForBinding(currentArticle)
                        }
                    }
                }
            }

            // Required fields note
            Text {
                Layout.fillWidth: true
                text: "* - обязательные поля"
                font.pointSize: baseFontSize - 1
                font.italic: true
                color: "#757575"
                horizontalAlignment: Text.AlignRight
            }

            // Spacer
            Item { Layout.fillHeight: true }

            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: baseSpacing

                Button {
                    text: "➕ Добавить"
                    Layout.fillWidth: true
                    visible: !isEditMode
                    highlighted: true
                    font.pointSize: baseFontSize

                    background: Rectangle {
                        color: {
                            if (!parent.enabled) return "#e0e0e0"
                            if (parent.down) return Qt.darker(successColor, 1.2)
                            if (parent.hovered) return Qt.lighter(successColor, 1.1)
                            return successColor
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
                        if (!validateFields()) return

                        var newData = {
                            "article": articleField.text.trim(),
                            "name": nameField.text.trim(),
                            "description": descriptionField.text.trim(),
                            "image_path": imageField.text,
                            "category": categoryComboBox.currentText || "",
                            "price": parseFloat(priceField.text) || 0.0,
                            "stock": parseInt(stockField.text) || 0
                        }
                        addItemClicked(newData)
                    }
                }

                Button {
                    text: "💾 Сохранить"
                    Layout.fillWidth: true
                    visible: isEditMode
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
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.enabled ? "white" : "#9e9e9e"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (!validateFields()) return

                        var updatedData = {
                            "article": articleField.text.trim(),
                            "name": nameField.text.trim(),
                            "description": descriptionField.text.trim(),
                            "image_path": imageField.text,
                            "category": categoryComboBox.currentText || "",
                            "price": parseFloat(priceField.text) || 0.0,
                            "stock": parseInt(stockField.text) || 0,
                            "status": statusComboBox.currentText,
                            "unit": unitComboBox.currentText,
                            "manufacturer": "",
                            "barcode": ""
                        }
                        saveItemClicked(currentItemId, updatedData)
                    }
                }
            }

            // Bottom spacer
            Item { Layout.preferredHeight: root.contentBottomPadding }
        }
    }
}