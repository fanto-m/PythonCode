// ProductCardDialog.qml - Упрощённая версия без автосохранения
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: productDialog
    width: 900
    height: 750
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
    property int currentItemId: -1
    property string currentArticle: ""
    property bool isEditMode: currentItemId !== -1
    property bool hasValidationErrors: false

    // Храним полные относительные пути к файлам
    property string currentImagePath: ""
    property string currentDocumentPath: ""

    // Ссылка на модель документов
    property var itemDocumentsModel: null

    // Theme
    readonly property color primaryColor: "#2196F3"
    readonly property color errorColor: "#f44336"
    readonly property color successColor: "#4caf50"
    readonly property color borderColor: "#e0e0e0"
    readonly property color focusBorderColor: primaryColor
    readonly property int baseSpacing: 16
    readonly property int baseFontSize: 10

    // Диалоги выбора файлов
    ImageFileDialog {
        id: imageDialog
        onImageSelected: function(relativePath, subdirectory) {
            currentImagePath = relativePath
            imageField.text = fileManager ? fileManager.get_file_name(relativePath) : relativePath
            console.log("Image selected:", relativePath, "subdir:", subdirectory)
        }
    }

    // Main content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        anchors.bottomMargin: 80
        spacing: 12

        // ScrollView для прокрутки содержимого
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                // Grid Layout для полей формы
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 800
                    columns: 2
                    columnSpacing: baseSpacing
                    rowSpacing: baseSpacing

                    // --- РЯД 0: Категория и Цена ---
                    ColumnLayout {
                        Layout.row: 0
                        Layout.column: 0
                        Layout.preferredWidth: 300
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

                    ColumnLayout {
                        Layout.row: 0
                        Layout.column: 1
                        Layout.preferredWidth: 300
                        spacing: 4

                        Text {
                            text: "Цена"
                            font.pointSize: baseFontSize - 1
                            font.bold: true
                            color: "#333"
                        }

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
                    }

                    // --- РЯД 1: Артикул и Наименование ---
                    ColumnLayout {
                        Layout.row: 1
                        Layout.column: 0
                        Layout.preferredWidth: 300
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

                            // Кнопка автогенерации
                            Button {
                                text: "..."
                                font.pointSize: baseFontSize + 1
                                Layout.preferredWidth: 40
                                enabled: categoryComboBox.currentIndex >= 0

                                ToolTip.visible: hovered
                                ToolTip.text: "Сгенерировать артикул"
                                ToolTip.delay: 500

                                onClicked: {
                                    var categoryId = categoryModel.get(categoryComboBox.currentIndex).id
                                    var generatedSku = categoryModel.generateSkuForCategory(categoryId)
                                    if (generatedSku) {
                                        articleField.text = generatedSku
                                    }
                                }

                                background: Rectangle {
                                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
                                    border.color: borderColor
                                    border.width: 1
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: parent.enabled ? "#333" : "#999"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
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

                    ColumnLayout {
                        Layout.row: 1
                        Layout.column: 1
                        Layout.preferredWidth: 300
                        spacing: 4

                        Text {
                            text: "Наименование"
                            font.pointSize: baseFontSize - 1
                            font.bold: true
                            color: "#333"
                        }

                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            placeholderText: "Введите наименование"
                            font.pointSize: baseFontSize

                            background: Rectangle {
                                color: "white"
                                border.color: nameField.activeFocus ? focusBorderColor : borderColor
                                border.width: nameField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }
                    }

                    // --- РЯД 2: Описание (на всю ширину) ---
                    ColumnLayout {
                        Layout.row: 2
                        Layout.column: 0
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Описание"
                            font.pointSize: baseFontSize - 1
                            font.bold: true
                            color: "#333"
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80

                            TextArea {
                                id: descriptionField
                                placeholderText: "Введите описание товара"
                                font.pointSize: baseFontSize
                                wrapMode: TextArea.Wrap

                                background: Rectangle {
                                    color: "white"
                                    border.color: descriptionField.activeFocus ? focusBorderColor : borderColor
                                    border.width: descriptionField.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                        }
                    }

                    // --- РЯД 3: Количество и Статус ---
                    ColumnLayout {
                        Layout.row: 3
                        Layout.column: 0
                        Layout.preferredWidth: 300
                        spacing: 4

                        Text {
                            text: "Количество"
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
                            editable: true
                            font.pointSize: baseFontSize

                            background: Rectangle {
                                color: "white"
                                border.color: stockField.activeFocus ? focusBorderColor : borderColor
                                border.width: stockField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.row: 3
                        Layout.column: 1
                        Layout.preferredWidth: 300
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
                            model: ["в наличии", "под заказ", "нет в наличии", "снят с производства"]
                            font.pointSize: baseFontSize

                            background: Rectangle {
                                color: "white"
                                border.color: statusComboBox.activeFocus ? focusBorderColor : borderColor
                                border.width: statusComboBox.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }
                    }

                    // --- РЯД 4: Единица измерения и Производитель ---
                    ColumnLayout {
                        Layout.row: 4
                        Layout.column: 0
                        Layout.preferredWidth: 300
                        spacing: 4

                        Text {
                            text: "Единица измерения"
                            font.pointSize: baseFontSize - 1
                            font.bold: true
                            color: "#333"
                        }

                        ComboBox {
                            id: unitComboBox
                            Layout.fillWidth: true
                            model: ["шт.", "кг", "л", "м", "м²", "м³", "упак.", "компл."]
                            editable: true
                            font.pointSize: baseFontSize

                            background: Rectangle {
                                color: "white"
                                border.color: unitComboBox.activeFocus ? focusBorderColor : borderColor
                                border.width: unitComboBox.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.row: 4
                        Layout.column: 1
                        Layout.preferredWidth: 300
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
                            placeholderText: "Название производителя"
                            font.pointSize: baseFontSize

                            background: Rectangle {
                                color: "white"
                                border.color: manufacturerField.activeFocus ? focusBorderColor : borderColor
                                border.width: manufacturerField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }
                    }

                    // --- РЯД 5: Изображение ---
                    ColumnLayout {
                        Layout.row: 5
                        Layout.column: 0
                        Layout.columnSpan: 2
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
                            spacing: 8

                            Button {
                                text: "📁 Выбрать"
                                font.pointSize: baseFontSize
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
                                placeholderText: "Файл не выбран"
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

                // Подсказка в режиме добавления
                Text {
                    visible: !isEditMode
                    text: "💡 Документы можно добавить после сохранения товара"
                    font.pointSize: 10
                    font.italic: true
                    color: "#666"
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    horizontalAlignment: Text.AlignHCenter
                }

                // Менеджер документов (только в режиме редактирования)
                MultipleDocumentsManager {
                    id: documentsManager
                    Layout.fillWidth: true
                    documentsModel: itemDocumentsModel
                    currentArticle: productDialog.currentArticle

                    visible: isEditMode
                }
            }
        }

        // Кнопки
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

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
                        "image_path": currentImagePath,
                        "category": categoryComboBox.currentText || "",
                        "price": finalPrice,
                        "stock": stockField.value,
                        "status": statusComboBox.currentText || "в наличии",
                        "unit": unitComboBox.currentText || "шт.",
                        "manufacturer": manufacturerField.text.trim() || "",
                        "document": currentDocumentPath
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
    }

    // Functions
    function populateFields(data) {
        console.log("populateFields called with itemId:", data.index)

        currentItemId = data.index
        currentArticle = data.article
        articleField.text = data.article
        nameField.text = data.name
        descriptionField.text = data.description

        currentImagePath = data.image_path || ""
        imageField.text = fileManager ? fileManager.get_file_name(currentImagePath) : currentImagePath

        currentDocumentPath = data.document || ""

        // Загружаем документы товара
        if (itemDocumentsModel && currentArticle) {
            documentsManager.loadDocuments(currentArticle)
        }

        priceField.text = String(data.price)
        stockField.value = data.stock
        manufacturerField.text = String(data.manufacturer || "")

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
        currentImagePath = ""
        imageField.text = ""
        currentDocumentPath = ""
        priceField.text = "0.00"
        stockField.value = 0
        statusComboBox.currentIndex = -1
        unitComboBox.currentIndex = -1
        categoryComboBox.currentIndex = -1

        documentsManager.clearDocuments()
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