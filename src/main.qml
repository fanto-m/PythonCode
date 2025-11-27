// main.qml - New Main Window with Mode Selection
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "qml/styles"                           // ← Theme
import "qml/components/common"                // ← Типовые компоненты
import "qml/components/dialogs/categories"    // ← Диалог
import "qml/components/dialogs/suppliers"
import "qml/components/dialogs/system"
import "qml/components/panels"


ApplicationWindow {
    id: mainWindow
    width: 1000
    height: 800
    visible: true
    title: "Система управления складом"
    visibility: Window.Maximized




    property string currentMode: "main" // "main", "edit", "view", "create_spec", "view_spec"
    property int defaultWidth: 1000
    property int defaultHeight: 700

    // Shared properties
    property string selectedImagePath: ""
    property string selectedDocumentPath: ""

    onVisibilityChanged: {
        if (visibility === Window.Windowed) {
            width = defaultWidth
            height = defaultHeight
            x = (Screen.width - defaultWidth) / 2
            y = (Screen.height - defaultHeight) / 2
        }
    }


    Component.onCompleted: {
        if (categoryModel && categoryModel.errorOccurred) {
            categoryModel.errorOccurred.connect(errorDialog.showMessage)
        }
        if (itemsModel && itemsModel.errorOccurred) {
            itemsModel.errorOccurred.connect(errorDialog.showMessage)
        }
    }

    // Main content switcher
    StackLayout {
        anchors.fill: parent
        currentIndex: {
            switch (currentMode) {
                case "main": return 0
                case "edit": return 1
                case "view": return 2
                case "create_spec": return 3
                case "view_spec": return 4
                default: return 0
            }
        }

        // ========================================
        // 0: MAIN MENU
        // ========================================
        Item {
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f5f7fa" }
                    GradientStop { position: 1.0; color: "#c3cfe2" }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 30
                    width: 600

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Система управления складом"
                        font.pointSize: 24
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Выберите режим работы"
                        font.pointSize: 14
                        color: "#7f8c8d"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: "#bdc3c7"
                        Layout.topMargin: 10
                        Layout.bottomMargin: 20
                    }

                    // Edit Warehouse Button
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        onClicked: currentMode = "edit"

                        background: Rectangle {
                            color: parent.down ? "#2980b9" : (parent.hovered ? "#3498db" : "#3498db")
                            radius: 8
                            border.color: "#2980b9"
                            border.width: 2
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: RowLayout {
                            spacing: 15
                            Text {
                                text: "✏️"
                                font.pointSize: 28
                                Layout.leftMargin: 20
                            }
                            ColumnLayout {
                                spacing: 5
                                Layout.fillWidth: true
                                Text {
                                    text: "Редактировать склад"
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "white"
                                }
                                Text {
                                    text: "Добавление, редактирование и удаление товаров"
                                    font.pointSize: 11
                                    color: "#ecf0f1"
                                }
                            }
                            Text {
                                text: "→"
                                font.pointSize: 24
                                color: "white"
                                Layout.rightMargin: 20
                            }
                        }
                    }

                    // View Warehouse Button
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        onClicked: currentMode = "view"

                        background: Rectangle {
                            color: parent.down ? "#27ae60" : (parent.hovered ? "#2ecc71" : "#2ecc71")
                            radius: 8
                            border.color: "#27ae60"
                            border.width: 2
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: RowLayout {
                            spacing: 15
                            Text {
                                text: "👁️"
                                font.pointSize: 28
                                Layout.leftMargin: 20
                            }
                            ColumnLayout {
                                spacing: 5
                                Layout.fillWidth: true
                                Text {
                                    text: "Просмотр склада"
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "white"
                                }
                                Text {
                                    text: "Просмотр товаров и информации о складе"
                                    font.pointSize: 11
                                    color: "#ecf0f1"
                                }
                            }
                            Text {
                                text: "→"
                                font.pointSize: 24
                                color: "white"
                                Layout.rightMargin: 20
                            }
                        }
                    }

                    // Create Specification Button
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        onClicked: {
                            currentMode = "create_spec"
                            console.log("SpecificationItemsTable: Component completed")
                        }

                        background: Rectangle {
                            color: parent.down ? "#d68910" : (parent.hovered ? "#f39c12" : "#f39c12")
                            radius: 8
                            border.color: "#d68910"
                            border.width: 2
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: RowLayout {
                            spacing: 15
                            Text {
                                text: "📝"
                                font.pointSize: 28
                                Layout.leftMargin: 20
                            }
                            ColumnLayout {
                                spacing: 5
                                Layout.fillWidth: true
                                Text {
                                    text: "Создать спецификацию"
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "white"
                                }
                                Text {
                                    text: "Формирование новой спецификации товаров"
                                    font.pointSize: 11
                                    color: "#ecf0f1"
                                }
                            }
                            Text {
                                text: "→"
                                font.pointSize: 24
                                color: "white"
                                Layout.rightMargin: 20
                            }
                        }
                    }

                    // View Specifications Button
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        onClicked: currentMode = "view_spec"

                        background: Rectangle {
                            color: parent.down ? "#8e44ad" : (parent.hovered ? "#9b59b6" : "#9b59b6")
                            radius: 8
                            border.color: "#8e44ad"
                            border.width: 2
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: RowLayout {
                            spacing: 15
                            Text {
                                text: "📋"
                                font.pointSize: 28
                                Layout.leftMargin: 20
                            }
                            ColumnLayout {
                                spacing: 5
                                Layout.fillWidth: true
                                Text {
                                    text: "Просмотр спецификаций"
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "white"
                                }
                                Text {
                                    text: "Просмотр сохраненных спецификаций"
                                    font.pointSize: 11
                                    color: "#ecf0f1"
                                }
                            }
                            Text {
                                text: "→"
                                font.pointSize: 24
                                color: "white"
                                Layout.rightMargin: 20
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: "#bdc3c7"
                        Layout.topMargin: 20
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Версия 1.0"
                        font.pointSize: 10
                        color: "#95a5a6"
                    }
                }
            }
        }

        // ========================================
        // 1: EDIT WAREHOUSE MODE
        // ========================================
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#3498db"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Button {
                            text: "← Главное меню"
                            onClicked: {
                                controlPanel.clearFields()
                                currentMode = "main"
                            }

                            background: Rectangle {
                                color: parent.down ? "#2980b9" : (parent.hovered ? "#2c3e50" : "transparent")
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
                            text: "Редактирование склада"
                            font.pointSize: 18
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "✏️"
                            font.pointSize: 24
                        }
                    }
                }

                // Filter Panel
                FilterPanel {}

                // Main content
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    Components.ItemList {
                        id: itemList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: itemsModel

                        onItemSelected: (itemData) => {
                            controlPanel.currentItemId = itemData.index
                            controlPanel.currentArticle = itemData.article
                            //controlPanel.currentItemData = itemData  // ← ДОБАВЬТЕ ЭТУ СТРОКУ
                            controlPanel.currentItemData = Object.assign({}, itemData)
                            mainWindow.selectedImagePath = itemData.image_path
                            mainWindow.selectedDocumentPath = itemData.document
                        }

                        onDeleteRequested: (index, name, article) => {
                            deleteDialog.openFor(index, name, article)
                        }
                    }

                    Components.ControlPanel {
                        id: controlPanel
                        Layout.preferredWidth: 416

                        onAddCategoryClicked: () => addCategoryDialog.open()

                        onEditCategoryClicked: (categoryData) => {
                            if (categoryData && categoryData.id !== undefined) {
                                editCategoryDialog.openFor(categoryData)
                            }
                        }

                        onDeleteCategoryClicked: (categoryData) => {
                            deleteCategoryDialog.openFor(categoryData.id, categoryData.name)
                        }

                        onAddItemClicked: (itemData) => {
                            var categoryId = categoryModel.getCategoryIdByName(itemData.category)
                            var errorMessage = itemsModel.addItem(
                                itemData.article,
                                itemData.name,
                                itemData.description,
                                itemData.image_path,
                                categoryId,
                                itemData.price,
                                itemData.stock,
                                itemData.status,      // Добавляем status
                                itemData.unit,        // Добавляем unit
                                itemData.manufacturer, // Добавляем manufacturer
                                itemData.document     // document уже был
                            )
                            if (errorMessage) {
                                errorDialog.message = errorMessage
                                errorDialog.open()
                            } else {
                                controlPanel.clearFields()
                            }
                        }

                        onSaveItemClicked: (itemIndex, itemData) => {
                            var categoryId = categoryModel.getCategoryIdByName(itemData.category)
                            var errorMessage = itemsModel.updateItem(
                                itemIndex,
                                itemData.article,
                                itemData.name,
                                itemData.description,
                                itemData.image_path,
                                categoryId,
                                itemData.price,
                                itemData.stock,
                                itemData.status,
                                itemData.unit,
                                itemData.manufacturer || "",
                                itemData.document || ""
                            )
                            if (errorMessage) {
                                errorDialog.message = errorMessage
                                errorDialog.open()
                            } else {
                                controlPanel.clearFields()
                            }
                        }

                        onCopyItemClicked: (itemData) => {
                            console.log("QML: Копируем товар:", itemData.name, "из категории:", itemData.category)

                            // Получаем ID категории по имени (как и в addItemClicked)
                            var categoryId = categoryModel.getCategoryIdByName(itemData.category)
                            if (categoryId === undefined || categoryId === -1) {
                                errorDialog.message = "Не удалось определить категорию для копирования"
                                errorDialog.open()
                                return
                            }

                            // Генерируем артикул через существующую логику!
                            var newArticle = categoryModel.generateSkuForCategory(categoryId)
                            if (!newArticle) {
                                errorDialog.message = "Не удалось сгенерировать артикул для категории"
                                errorDialog.open()
                                return
                            }

                            // Копируем товар с новым артикулом
                            var errorMessage = itemsModel.addItem(
                                newArticle,
                                itemData.name,
                                itemData.description,
                                itemData.image_path,
                                categoryId,
                                itemData.price,
                                itemData.stock,
                                itemData.status || "в наличии",
                                itemData.unit || "шт.",
                                itemData.manufacturer || "",
                                itemData.document || ""
                            )

                            if (errorMessage) {
                                errorDialog.message = errorMessage
                                errorDialog.open()
                            } else {
                                console.log("Товар успешно скопирован с артикулом:", newArticle)
                                controlPanel.clearFields()  // Сбрасываем выделение
                            }
                        }

                    }
                }
            }
        }

        // ========================================
        // 2: VIEW WAREHOUSE MODE
        // ========================================
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#2ecc71"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Button {
                            text: "← Главное меню"
                            onClicked: currentMode = "main"

                            background: Rectangle {
                                color: parent.down ? "#27ae60" : (parent.hovered ? "#2c3e50" : "transparent")
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
                            text: "Просмотр склада"
                            font.pointSize: 18
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "👁️"
                            font.pointSize: 24
                        }
                    }
                }

                // Filter Panel (simplified)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    spacing: 5

                    Text {
                        id: dateTimeText
                        text: Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                        font.pixelSize: 14
                        color: "gray"
                        verticalAlignment: Text.AlignVCenter
                    }

                    Timer {
                        interval: 1000
                        repeat: true
                        running: currentMode === "view"
                        onTriggered: {
                            dateTimeText.text = Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                        }
                    }

                    TextField {
                        id: viewFilterField
                        placeholderText: "Поиск по складу..."
                        Layout.fillWidth: true
                        onTextChanged: itemsModel.setFilterString(text)
                    }

                    ComboBox {
                        id: viewFilterComboBox
                        textRole: "display"
                        valueRole: "value"
                        model: [
                            { display: "Название", value: "name" },
                            { display: "Артикул", value: "article" },
                            { display: "Описание", value: "description" },
                            { display: "Категория", value: "category" },
                            { display: "Цена", value: "price" },
                            { display: "Остаток", value: "stock" }
                        ]
                        Layout.preferredWidth: 295
                        currentIndex: 0
                        onCurrentValueChanged: itemsModel.setFilterField(currentValue)
                    }
                }

                // View-only items list
                Components.ItemList {
                    id: viewItemList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 5
                    model: itemsModel
                    readOnly: true  // Hide delete/edit buttons in view mode
                }
            }
        }

        // ========================================
        // 3: CREATE SPECIFICATION MODE
        // ========================================
        Item {
            Components.CreateSpecificationMode {
                anchors.fill: parent
                onBackToMain: currentMode = "main"
            }
        }

        // ========================================
        // 4: VIEW SPECIFICATIONS MODE
        // ========================================
        Item {
            Components.ViewSpecificationsMode {
                anchors.fill: parent
                onBackToMain: currentMode = "main"
            }
        }
    }

    // ========================================
    // SHARED DIALOGS
    // ========================================
    Components.DeleteConfirmationDialog {
        id: deleteDialog
        onConfirmed: (itemIndex) => {
            if (itemIndex >= 0) {
                itemsModel.deleteItem(itemIndex)
                controlPanel.clearFields()
            }
        }
    }

    AddCategoryDialog {
        id: addCategoryDialog
        onCategoryAdded: (name, sku_prefix, sku_digits) => categoryModel.addCategory(name, sku_prefix, sku_digits)
    }

    EditCategoryDialog {
        id: editCategoryDialog
        onCategoryEdited: (id, name, prefix, digits) =>
            categoryModel.updateCategory(id, name, prefix, digits)
    }

    DeleteCategoryDialog {
        id: deleteCategoryDialog
        onCategoryDeleted: (id) => categoryModel.deleteCategory(id)
    }

    ImageFileDialog {
        id: fileDialogInternal
        onImageSelected: (path) => {
            var fileName = path.split("/").pop()
            mainWindow.selectedImagePath = "images/" + fileName
            if (controlPanel && controlPanel.imageField) {
                controlPanel.imageField.text = fileName
            }
        }
    }

    DocumentFileDialog {
        id: documentDialog
        onDocumentSelected: (path) => {
            // Сохраняем только имя файла из полного пути
            var fileName = path.split("/").pop()
            mainWindow.selectedDocumentPath = "documents/" + fileName
            if (controlPanel && controlPanel.documentField) {
                controlPanel.documentField.text = fileName
            }
        }
    }


    Components.ErrorDialog {
        id: errorDialog
    }

    Components.ItemSuppliersDialog {
        id: itemSuppliersDialog
    }

    Components.SuppliersManagerDialog {
        id: suppliersManagerDialog
    }

    AddSupplierDialog {
        id: addSupplierDialog
        onSupplierAdded: (name, company, email, phone, website) => {
            suppliersTableModel.addSupplier(name, company, email, phone, website)
        }
    }

    EditSupplierDialog {
        id: editSupplierDialog
        onSupplierEdited: (id, name, company, email, phone, website) => {
            suppliersTableModel.updateSupplier(id, name, company, email, phone, website)
        }
    }

    DeleteSupplierDialog {
        id: deleteSupplierDialog
        onSupplierDeleted: (id) => {
            suppliersTableModel.deleteSupplier(id)
        }
    }
}