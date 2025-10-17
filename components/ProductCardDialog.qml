// ProductCardDialog.qml - Диалог карточки товара с Grid Layout
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: productDialog
    width: 850
    height: 550
    title: isEditMode ? "Редактирование товара" : "Добавление нового товара"
    modal: true
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Component.onCompleted: {
        console.log("ProductCardDialog loaded successfully!")
    }

    // Обработчик для перемещения окна
    MouseArea {
        id: titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        cursorShape: Qt.OpenHandCursor

        property point lastMousePos

        onPressed: {
            lastMousePos = Qt.point(mouseX, mouseY)
            cursorShape = Qt.ClosedHandCursor
        }

        onReleased: {
            cursorShape = Qt.OpenHandCursor
        }

        onMouseXChanged: {
            if (pressed) {
                productDialog.x += mouseX - lastMousePos.x
            }
        }

        onMouseYChanged: {
            if (pressed) {
                productDialog.y += mouseY - lastMousePos.y
            }
        }
    }

    // Signals
    signal addItemClicked(var itemData)
    signal saveItemClicked(int itemIndex, var itemData)

    // Properties
    property alias imageField: imageField
    property alias documentField: documentField
    property int currentItemId: -1
    property string currentArticle: ""
    property bool isEditMode: currentItemId !== -1
    property bool hasValidationErrors: false

    // Theme
    readonly property color primaryColor: "#2196F3"
    readonly property color errorColor: "#f44336"
    readonly property color successColor: "#4caf50"
    readonly property color borderColor: "#e0e0e0"
    readonly property color focusBorderColor: primaryColor
    readonly property int baseSpacing: 16
    readonly property int baseFontSize: 10

    // File dialogs
    FileDialog {
        id: imageDialog
        title: "Выберите изображение"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Image files (*.jpg *.png *.gif)"]
        onAccepted: {
            imageField.text = selectedFile.toString().split("/").pop()
        }
    }

    FileDialog {
        id: documentDialog
        title: "Выберите документ"
        fileMode: FileDialog.OpenFile
        nameFilters: ["All files (*.*)"]
        onAccepted: {
            documentField.text = selectedFile.toString().split("/").pop()
        }
    }

    // Main content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12



        // Grid Layout
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            columnSpacing: baseSpacing
            rowSpacing: baseSpacing

            // --- РЯД 0 ---
            // Категория
            ColumnLayout {
                Layout.row: 0
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Категория"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

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
            }

            // Цена
            ColumnLayout {
                Layout.row: 0
                Layout.column: 1
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Цена"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        TextField {
                            id: priceField
                            Layout.fillWidth: true
                            placeholderText: "0.00"
                            text: "0.00"
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

                        CheckBox {
                            id: vatIncluded
                            text: "НДС"
                            font.pointSize: baseFontSize - 2

                            Component.onCompleted: {
                                if (configManager) checked = configManager.vatIncluded
                            }

                            onCheckedChanged: {
                                if (configManager) configManager.vatIncluded = checked
                            }

                            Connections {
                                target: configManager
                                function onVatIncludedChanged() {
                                    vatIncluded.checked = configManager.vatIncluded
                                }
                            }
                        }
                    }

                    Text {
                        visible: priceField.hasError
                        text: "⚠️ Неверная цена"
                        font.pointSize: baseFontSize - 2
                        color: errorColor
                    }
                }
            }

            // --- РЯД 1 ---
            // Артикул
            ColumnLayout {
                Layout.row: 1
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Артикул"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

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
                        text: "..."
                        font.pointSize: baseFontSize + 1
                        Layout.preferredWidth: 40
                        enabled: categoryComboBox.currentIndex >= 0
                        ToolTip.visible: hovered
                        ToolTip.text: "Сгенерировать"

                        onClicked: {
                            var categoryId = categoryModel.get(categoryComboBox.currentIndex).id
                            var generatedSku = categoryModel.generateSkuForCategory(categoryId)
                            if (generatedSku) articleField.text = generatedSku
                        }

                        background: Rectangle {
                            color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
                            border.color: borderColor
                            border.width: 1
                            radius: 4
                        }
                    }
                }

                Text {
                    visible: articleField.hasError
                    text: "⚠️ Артикул обязателен"
                    font.pointSize: baseFontSize - 2
                    color: errorColor
                }
            }

            // Остаток
            ColumnLayout {
                Layout.row: 1
                Layout.column: 1
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Остаток"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                SpinBox {
                    id: stockField
                    Layout.fillWidth: true
                    from: 0
                    to: 999999
                    value: 0
                    font.pointSize: baseFontSize
                }
            }

            // --- РЯД 2 ---
            // Название товара
            ColumnLayout {
                Layout.row: 2
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Название товара *"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Введите название товара"
                    font.pointSize: baseFontSize

                    background: Rectangle {
                        color: "white"
                        border.color: nameField.activeFocus ? focusBorderColor : borderColor
                        border.width: nameField.activeFocus ? 2 : 1
                        radius: 4
                    }
                }
            }

            // Ед. изм.
            ColumnLayout {
                Layout.row: 2
                Layout.column: 1
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Ед. изм."
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                ComboBox {
                    id: unitComboBox
                    Layout.fillWidth: true
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

            // --- РЯД 3 ---
            // Производитель
            ColumnLayout {
                Layout.row: 3
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Производитель"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                TextField {
                    id: manufacturerField
                    Layout.fillWidth: true
                    placeholderText: "Введите производителя"
                    font.pointSize: baseFontSize

                    background: Rectangle {
                        color: "white"
                        border.color: manufacturerField.activeFocus ? focusBorderColor : borderColor
                        border.width: manufacturerField.activeFocus ? 2 : 1
                        radius: 4
                    }
                }
            }

            // Статус
            ColumnLayout {
                Layout.row: 3
                Layout.column: 1
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Статус"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                ComboBox {
                    id: statusComboBox
                    Layout.fillWidth: true
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

            // --- РЯД 4 и 5 ---
            // Описание (растягивается на несколько рядов)
            ColumnLayout {
                Layout.row: 4
                Layout.column: 0
                Layout.rowSpan: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Text {
                    text: "Описание"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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

            // Изображение
            ColumnLayout {
                Layout.row: 4
                Layout.column: 1
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Изображение"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Button {
                        text: "Обзор..."
                        font.pointSize: baseFontSize - 1
                        onClicked: imageDialog.open()

                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#f5f5f5"
                            border.color: borderColor
                            border.width: 1
                            radius: 4
                        }
                    }

                    TextField {
                        id: imageField
                        Layout.fillWidth: true
                        placeholderText: "Файл не выбран."
                        readOnly: true
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: "#f5f5f5"
                            border.color: borderColor
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }

            // Документ
            ColumnLayout {
                Layout.row: 5
                Layout.column: 1
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Документ"
                    font.pointSize: baseFontSize - 1
                    font.bold: true
                    color: "#333"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Button {
                        text: "Обзор..."
                        font.pointSize: baseFontSize - 1
                        onClicked: documentDialog.open()

                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#f5f5f5"
                            border.color: borderColor
                            border.width: 1
                            radius: 4
                        }
                    }

                    TextField {
                        id: documentField
                        Layout.fillWidth: true
                        placeholderText: "Файл не выбран."
                        readOnly: true
                        font.pointSize: baseFontSize

                        background: Rectangle {
                            color: "#f5f5f5"
                            border.color: borderColor
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }
        }
    }

    // Footer
    footer: RowLayout {
        spacing: 12
        anchors.margins: 20

        Item { Layout.fillWidth: true }

        Button {
            text: "Отмена"
            Layout.preferredWidth: 140
            font.pointSize: baseFontSize
            onClicked: productDialog.reject()

            background: Rectangle {
                color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
                border.color: borderColor
                border.width: 1
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#333"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            text: isEditMode ? "💾 Сохранить" : "➕ Добавить"
            Layout.preferredWidth: 140
            highlighted: true
            font.pointSize: baseFontSize
            font.bold: true

            background: Rectangle {
                color: {
                    if (!parent.enabled) return "#ccc"
                    if (parent.down) return Qt.darker(isEditMode ? primaryColor : successColor, 1.3)
                    if (parent.hovered) return Qt.lighter(isEditMode ? primaryColor : successColor, 1.1)
                    return isEditMode ? primaryColor : successColor
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

            onClicked: {
                if (!validateFields()) return

                let inputPrice = parseFloat(priceField.text) || 0.0
                let finalPrice = (vatIncluded.checked && configManager)
                    ? configManager.calculatePriceWithoutVAT(inputPrice)
                    : inputPrice

                var itemData = {
                    "article": articleField.text.trim(),
                    "name": nameField.text.trim(),
                    "description": descriptionField.text.trim(),
                    "image_path": imageField.text,
                    "category": categoryComboBox.currentText || "",
                    "price": finalPrice,
                    "stock": stockField.value,
                    "status": statusComboBox.currentText || "в наличии",
                    "unit": unitComboBox.currentText || "шт.",
                    "manufacturer": manufacturerField.text.trim() || "",
                    "document": documentField.text || ""
                }

                if (isEditMode) {
                    saveItemClicked(currentItemId, itemData)
                } else {
                    addItemClicked(itemData)
                }
                productDialog.accept()
            }
        }
    }

    // Functions
    function populateFields(data) {
        console.log("populateFields called with itemId:", data.index)

        currentItemId = data.index
        currentArticle = data.article
        articleField.text = data.article
        nameField.text = data.name
        descriptionField.text = data.description
        imageField.text = data.image_path.split("/").pop()
        priceField.text = String(data.price)
        stockField.value = data.stock
        manufacturerField.text = String(data.manufacturer || "")
        documentField.text = data.document.split("/").pop()

        var statusIndex = statusComboBox.model.indexOf(data.status || "в наличии")
        statusComboBox.currentIndex = statusIndex >= 0 ? statusIndex : 0

        var unitIndex = unitComboBox.model.indexOf(data.unit || "шт.")
        unitComboBox.currentIndex = unitIndex >= 0 ? unitIndex : 0

        var idx = categoryModel.indexOfName(data.category)
        categoryComboBox.currentIndex = idx

        clearErrors()

        console.log("isEditMode now:", isEditMode)
    }

    function clearFields() {
        currentItemId = -1
        currentArticle = ""
        articleField.text = ""
        nameField.text = ""
        descriptionField.text = ""
        imageField.text = ""
        priceField.text = "0.00"
        stockField.value = 0
        statusComboBox.currentIndex = -1
        unitComboBox.currentIndex = -1
        categoryComboBox.currentIndex = -1
        clearErrors()
    }

    function clearErrors() {
        articleField.hasError = false
        priceField.hasError = false
        hasValidationErrors = false
    }

    function validateFields() {
        clearErrors()
        var isValid = true

        if (articleField.text.trim() === "") {
            articleField.hasError = true
            isValid = false
        }

        if (priceField.text.trim() === "" || isNaN(parseFloat(priceField.text)) || parseFloat(priceField.text) < 0) {
            priceField.hasError = true
            isValid = false
        }

        hasValidationErrors = !isValid
        return isValid
    }
}