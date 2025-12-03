// ProductCardDialog.qml - Диалог карточки товара
// РЕФАКТОРИНГ: Использует кастомные компоненты и Theme
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

// === ИМПОРТЫ ДЛЯ ТЕМЫ И КОМПОНЕНТОВ ===
// Файл в qml/components/dialogs/items/
import "../../../styles"
import "../../common"
import "../system"

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

    // === ПЕРЕТАСКИВАНИЕ ОКНА ===
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

    // === СИГНАЛЫ ===
    signal addItemClicked(var itemData)
    signal saveItemClicked(int itemIndex, var itemData)

    // === СВОЙСТВА ===
    property int currentItemId: -1
    property string currentArticle: ""
    property bool isEditMode: currentItemId !== -1
    property bool hasValidationErrors: false

    // Пути к файлам
    property string currentImagePath: ""
    property string currentDocumentPath: ""

    // Ссылка на модель документов
    property var itemDocumentsModel: null

    // Единая высота полей ввода
    readonly property int fieldHeight: 45

    // === ДИАЛОГ ВЫБОРА ИЗОБРАЖЕНИЯ ===
    ImageFileDialog {
        id: imageDialog
        onImageSelected: function(relativePath, subdirectory) {
            currentImagePath = relativePath
            imageField.text = fileManager ? fileManager.get_file_name(relativePath) : relativePath
            console.log("Image selected:", relativePath, "subdir:", subdirectory)
        }
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
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

                // === GRID LAYOUT ДЛЯ ПОЛЕЙ ФОРМЫ ===
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 800
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 16

                    // --- РЯД 0: Категория и Цена ---
                    ColumnLayout {
                        Layout.row: 0
                        Layout.column: 0
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Категория"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        AppComboBox {
                            id: categoryComboBox
                            Layout.fillWidth: true
                            Layout.preferredHeight: fieldHeight
                            model: categoryModel
                            textRole: "name"
                        }
                    }

                    ColumnLayout {
                        Layout.row: 0
                        Layout.column: 1
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Цена"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            AppTextField {
                                id: priceField
                                Layout.fillWidth: true
                                Layout.preferredHeight: fieldHeight
                                placeholderText: "0.00"
                                text: "0.00"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                property bool hasError: false
                                enterDelay: 0

                                background: Rectangle {
                                    color: Theme.inputBackground
                                    border.color: {
                                        if (priceField.hasError) return Theme.errorColor
                                        if (priceField.activeFocus) return Theme.inputBorderFocus
                                        return Theme.inputBorder
                                    }
                                    border.width: priceField.activeFocus ? 2 : 1
                                    radius: Theme.smallRadius
                                }

                                onTextChanged: if (hasError && text.trim() !== "") hasError = false
                            }

                            AppCheckBox {
                                id: vatIncluded
                                text: "НДС"
                                checked: false

                                onCheckedChanged: {
                                    if (configManager) configManager.vatIncluded = checked
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

                        AppLabel {
                            text: "Артикул"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            AppTextField {
                                id: articleField
                                Layout.fillWidth: true
                                Layout.preferredHeight: fieldHeight
                                placeholderText: "Введите артикул"
                                property bool hasError: false
                                enterDelay: 0

                                background: Rectangle {
                                    color: Theme.inputBackground
                                    border.color: {
                                        if (articleField.hasError) return Theme.errorColor
                                        if (articleField.activeFocus) return Theme.inputBorderFocus
                                        return Theme.inputBorder
                                    }
                                    border.width: articleField.activeFocus ? 2 : 1
                                    radius: Theme.smallRadius
                                }

                                onTextChanged: if (hasError && text.trim() !== "") hasError = false
                            }

                            // Кнопка автогенерации
                            AppButton {
                                text: "..."
                                Layout.preferredWidth: fieldHeight
                                Layout.preferredHeight: fieldHeight
                                btnColor: Theme.backgroundColor
                                enabled: categoryComboBox.currentIndex >= 0
                                enterDelay: 0

                                ToolTip.visible: hovered
                                ToolTip.text: "Сгенерировать артикул"
                                ToolTip.delay: 500

                                contentItem: Text {
                                    text: parent.text
                                    font: Theme.defaultFont
                                    color: parent.enabled ? Theme.textColor : Theme.textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
                                    border.color: Theme.inputBorder
                                    border.width: 1
                                    radius: Theme.smallRadius
                                }

                                onClicked: {
                                    var categoryId = categoryModel.get(categoryComboBox.currentIndex).id
                                    var generatedSku = categoryModel.generateSkuForCategory(categoryId)
                                    if (generatedSku) {
                                        articleField.text = generatedSku
                                    }
                                }
                            }
                        }

                        AppLabel {
                            visible: articleField.hasError
                            text: "⚠️ Артикул обязателен"
                            level: "error"
                            enterDelay: 0
                        }
                    }

                    ColumnLayout {
                        Layout.row: 1
                        Layout.column: 1
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Наименование"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        AppTextField {
                            id: nameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: fieldHeight
                            placeholderText: "Введите наименование"
                            enterDelay: 0
                        }
                    }

                    // --- РЯД 2: Описание (на всю ширину) ---
                    ColumnLayout {
                        Layout.row: 2
                        Layout.column: 0
                        Layout.columnSpan: 2
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

                            AppTextArea {
                                id: descriptionField
                                placeholderText: "Введите описание товара"
                                enterDelay: 0
                            }
                        }
                    }

                    // --- РЯД 3: Количество и Статус ---
                    ColumnLayout {
                        Layout.row: 3
                        Layout.column: 0
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Количество"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        SpinBox {
                            id: stockField
                            Layout.fillWidth: true
                            Layout.preferredHeight: fieldHeight
                            from: 0
                            to: 999999
                            value: 0
                            editable: true
                            focusPolicy: Qt.StrongFocus
                            font: Theme.defaultFont

                            validator: IntValidator {
                                bottom: stockField.from
                                top: stockField.to
                            }

                            background: Rectangle {
                                color: "white"
                                border.color: stockField.activeFocus ? Theme.inputBorderFocus : Theme.inputBorder
                                border.width: stockField.activeFocus ? 2 : 1
                                radius: Theme.smallRadius
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.row: 3
                        Layout.column: 1
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Статус"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        AppComboBox {
                            id: statusComboBox
                            Layout.fillWidth: true
                            Layout.preferredHeight: fieldHeight
                            model: ["в наличии", "под заказ", "нет в наличии", "снят с производства"]
                        }
                    }

                    // --- РЯД 4: Единица измерения и Производитель ---
                    ColumnLayout {
                        Layout.row: 4
                        Layout.column: 0
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Единица измерения"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        AppComboBox {
                            id: unitComboBox
                            Layout.fillWidth: true
                            Layout.preferredHeight: fieldHeight
                            model: ["шт.", "кг", "л", "м", "см", "м²", "м³", "упак.", "компл."]
                            editable: true
                        }
                    }

                    ColumnLayout {
                        Layout.row: 4
                        Layout.column: 1
                        Layout.preferredWidth: 300
                        spacing: 4

                        AppLabel {
                            text: "Производитель"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        AppTextField {
                            id: manufacturerField
                            Layout.fillWidth: true
                            Layout.preferredHeight: fieldHeight
                            placeholderText: "Название производителя"
                            enterDelay: 0
                        }
                    }

                    // --- РЯД 5: Изображение ---
                    ColumnLayout {
                        Layout.row: 5
                        Layout.column: 0
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        spacing: 4

                        AppLabel {
                            text: "Изображение"
                            level: "body"
                            font.bold: true
                            enterDelay: 0
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            AppButton {
                                text: "📁 Выбрать"
                                Layout.preferredHeight: fieldHeight
                                btnColor: Theme.backgroundColor
                                enterDelay: 0

                                contentItem: Text {
                                    text: parent.text
                                    font: Theme.defaultFont
                                    color: Theme.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#f0f0f0" : "#f5f5f5"
                                    border.color: Theme.inputBorder
                                    border.width: 1
                                    radius: Theme.smallRadius
                                }

                                onClicked: imageDialog.open()
                            }

                            AppTextField {
                                id: imageField
                                Layout.fillWidth: true
                                Layout.preferredHeight: fieldHeight
                                placeholderText: "Файл не выбран"
                                readOnly: true
                                enterDelay: 0

                                background: Rectangle {
                                    color: "#f5f5f5"
                                    border.color: Theme.inputBorder
                                    border.width: 1
                                    radius: Theme.smallRadius
                                }
                            }
                        }
                    }
                }

                // Подсказка в режиме добавления
                AppLabel {
                    visible: !isEditMode
                    text: "💡 Документы можно добавить после сохранения товара"
                    level: "caption"
                    font.italic: true
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    horizontalAlignment: Text.AlignHCenter
                    enterDelay: 0
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

        // === КНОПКИ ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.fillWidth: true }

            AppButton {
                text: "Отмена"
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                btnColor: Theme.backgroundColor
                enterDelay: 0

                contentItem: Text {
                    text: parent.text
                    font: Theme.defaultFont
                    color: Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
                    border.color: Theme.inputBorder
                    border.width: 1
                    radius: Theme.smallRadius
                }

                onClicked: {
                    productDialog.reject()
                }
            }

            AppButton {
                text: isEditMode ? "💾 Сохранить" : "➕ Добавить"
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                btnColor: isEditMode ? Theme.primaryColor : Theme.successColor
                enterDelay: 0

                contentItem: Text {
                    text: parent.text
                    font: Theme.boldFont
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

    // === ФУНКЦИИ ===
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
        vatIncluded.checked = false
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
