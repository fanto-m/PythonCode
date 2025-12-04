// main.qml - Главное окно приложения
// Расположение: src/qml/
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "styles"
import "screens"
import "components/common"
import "components/dialogs/categories"
import "components/dialogs/suppliers"
import "components/dialogs/system"
import "components/dialogs/items"
import "components/dialogs/specifications"
import "components/panels"
import "components/tables"

ApplicationWindow {
    id: mainWindow
    width: 1000
    height: 800
    visible: true
    title: "Система управления складом"
    visibility: Window.Maximized

    // === СВОЙСТВА ===
    property string currentMode: "main"  // "main", "edit", "view", "create_spec", "view_spec"
    property int defaultWidth: 1000
    property int defaultHeight: 700

    // Shared properties
    property string selectedImagePath: ""
    property string selectedDocumentPath: ""

    // === ОБРАБОТЧИКИ ===
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed) {
            width = defaultWidth
            height = defaultHeight
            x = (Screen.width - defaultWidth) / 2
            y = (Screen.height - defaultHeight) / 2
        }
    }

    Component.onCompleted: {
        if (categoryModel && categoryModel.errorOccurred) {
            categoryModel.errorOccurred.connect(handleError)
        }
        if (itemsModel && itemsModel.errorOccurred) {
            itemsModel.errorOccurred.connect(handleError)
        }
    }

    function handleError(message) {
        errorDialog.showError(message)
    }

    // === MAIN CONTENT SWITCHER ===
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
        MainMenuScreen {
            onEditWarehouseClicked: currentMode = "edit"
            onViewWarehouseClicked: currentMode = "view"
            onCreateSpecificationClicked: currentMode = "create_spec"
            onViewSpecificationsClicked: currentMode = "view_spec"
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
                    color: Theme.editModeColor

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
                                color: parent.down ? Theme.editModeDark :
                                       (parent.hovered ? Qt.lighter(Theme.editModeColor, 1.1) : "transparent")
                                radius: Theme.smallRadius
                                border.color: Theme.textOnPrimary
                                border.width: 2
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            onClicked: {
                                controlPanel.clearFields()
                                currentMode = "main"
                            }
                        }

                        Text {
                            text: "Редактирование склада"
                            font: Theme.headerFont
                            color: Theme.textOnPrimary
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "✏️"
                            font.pixelSize: 24
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

                    ItemList {
                        id: itemList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: itemsModel

                        onItemSelected: function(itemData) {
                            controlPanel.currentItemId = itemData.index
                            controlPanel.currentArticle = itemData.article
                            controlPanel.currentItemData = Object.assign({}, itemData)
                            mainWindow.selectedImagePath = itemData.image_path
                            mainWindow.selectedDocumentPath = itemData.document
                        }

                        onDeleteRequested: function(index, name, article) {
                            deleteDialog.openFor(index, name, article)
                        }
                    }

                    ControlPanel {
                        id: controlPanel
                        Layout.preferredWidth: 416

                        onAddCategoryClicked: addCategoryDialog.open()

                        onEditCategoryClicked: function(categoryData) {
                            if (categoryData && categoryData.id !== undefined) {
                                editCategoryDialog.openFor(categoryData)
                            }
                        }

                        onDeleteCategoryClicked: function(categoryData) {
                            deleteCategoryDialog.openFor(categoryData.id, categoryData.name)
                        }

                        onAddItemClicked: function(itemData) {
                            var categoryId = categoryModel.getCategoryIdByName(itemData.category)
                            var errorMessage = itemsModel.addItem(
                                itemData.article,
                                itemData.name,
                                itemData.description,
                                itemData.image_path,
                                categoryId,
                                itemData.price,
                                itemData.stock,
                                itemData.status,
                                itemData.unit,
                                itemData.manufacturer,
                                itemData.document
                            )
                            if (errorMessage) {
                                errorDialog.showError(errorMessage)
                            } else {
                                controlPanel.clearFields()
                            }
                        }

                        onSaveItemClicked: function(itemIndex, itemData) {
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
                                errorDialog.showError(errorMessage)
                            } else {
                                controlPanel.clearFields()
                            }
                        }

                        onCopyItemClicked: function(itemData) {
                            console.log("QML: Копируем товар:", itemData.name, "из категории:", itemData.category)

                            var categoryId = categoryModel.getCategoryIdByName(itemData.category)
                            if (categoryId === undefined || categoryId === -1) {
                                errorDialog.showError("Не удалось определить категорию для копирования")
                                return
                            }

                            var newArticle = categoryModel.generateSkuForCategory(categoryId)
                            if (!newArticle) {
                                errorDialog.showError("Не удалось сгенерировать артикул для категории")
                                return
                            }

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
                                errorDialog.showError(errorMessage)
                            } else {
                                console.log("Товар успешно скопирован с артикулом:", newArticle)
                                controlPanel.clearFields()
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
                    color: Theme.viewModeColor

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
                                color: parent.down ? Theme.viewModeDark :
                                       (parent.hovered ? Qt.lighter(Theme.viewModeColor, 1.1) : "transparent")
                                radius: Theme.smallRadius
                                border.color: Theme.textOnPrimary
                                border.width: 2
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            onClicked: currentMode = "main"
                        }

                        Text {
                            text: "Просмотр склада"
                            font: Theme.headerFont
                            color: Theme.textOnPrimary
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "👁️"
                            font.pixelSize: 24
                        }
                    }
                }

                // Filter Panel (simplified)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Layout.topMargin: 5
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    spacing: 10

                    Text {
                        id: dateTimeText
                        text: Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                        font: Theme.defaultFont
                        color: Theme.textSecondary
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
                        Layout.preferredWidth: 200
                        currentIndex: 0
                        onCurrentValueChanged: itemsModel.setFilterField(currentValue)
                    }
                }

                // View-only items list
                ItemList {
                    id: viewItemList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 5
                    model: itemsModel
                    readOnly: true
                }
            }
        }

        // ========================================
        // 3: CREATE SPECIFICATION MODE
        // ========================================
        Item {
            CreateSpecificationMode {
                anchors.fill: parent
                onBackToMain: currentMode = "main"
            }
        }

        // ========================================
        // 4: VIEW SPECIFICATIONS MODE
        // ========================================
        Item {
            ViewSpecificationsMode {
                anchors.fill: parent
                onBackToMain: currentMode = "main"
            }
        }
    }

    // ========================================
    // SHARED DIALOGS
    // ========================================

    // Диалог ошибок
    NotificationDialog {
        id: errorDialog
    }

    // Диалог удаления товара
    DeleteConfirmationDialog {
        id: deleteDialog
        onConfirmed: function(itemIndex) {
            if (itemIndex >= 0) {
                itemsModel.deleteItem(itemIndex)
                controlPanel.clearFields()
            }
        }
    }

    // === Диалоги категорий ===
    AddCategoryDialog {
        id: addCategoryDialog
        onCategoryAdded: function(name, sku_prefix, sku_digits) {
            categoryModel.addCategory(name, sku_prefix, sku_digits)
        }
    }

    EditCategoryDialog {
        id: editCategoryDialog
        onCategoryEdited: function(id, name, prefix, digits) {
            categoryModel.updateCategory(id, name, prefix, digits)
        }
    }

    DeleteCategoryDialog {
        id: deleteCategoryDialog
        onCategoryDeleted: function(id) {
            categoryModel.deleteCategory(id)
        }
    }

    // === Диалоги файлов ===
    ImageFileDialog {
        id: fileDialogInternal
        onImageSelected: function(path) {
            var fileName = path.split("/").pop()
            mainWindow.selectedImagePath = "images/" + fileName
            if (controlPanel && controlPanel.imageField) {
                controlPanel.imageField.text = fileName
            }
        }
    }

    DocumentFileDialog {
        id: documentDialog
        onDocumentSelected: function(path) {
            var fileName = path.split("/").pop()
            mainWindow.selectedDocumentPath = "documents/" + fileName
            if (controlPanel && controlPanel.documentField) {
                controlPanel.documentField.text = fileName
            }
        }
    }

    // === Диалоги поставщиков ===
    ItemSuppliersDialog {
        id: itemSuppliersDialog
    }

    SuppliersManagerDialog {
        id: suppliersManagerDialog
    }

    AddSupplierDialog {
        id: addSupplierDialog
        onSupplierAdded: function(name, company, email, phone, website) {
            suppliersTableModel.addSupplier(name, company, email, phone, website)
        }
    }

    EditSupplierDialog {
        id: editSupplierDialog
        onSupplierEdited: function(id, name, company, email, phone, website) {
            suppliersTableModel.updateSupplier(id, name, company, email, phone, website)
        }
    }

    DeleteSupplierDialog {
        id: deleteSupplierDialog
        onSupplierDeleted: function(id) {
            suppliersTableModel.deleteSupplier(id)
        }
    }
}
