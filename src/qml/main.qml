// main.qml - Главное окно приложения с авторизацией
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

ApplicationWindow {
    id: mainWindow
    width: 1000
    height: 800
    visible: true
    title: "Система управления складом"
    visibility: Window.Maximized

    // === РЕЖИМЫ ПРИЛОЖЕНИЯ ===
    // "login"       - Авторизация
    // "main"        - Главное меню
    // "edit"        - Редактирование склада
    // "view"        - Просмотр склада
    // "create_spec" - Создание спецификации
    // "view_spec"   - Просмотр спецификаций
    property string currentMode: "login"  // Начинаем с авторизации

    property int defaultWidth: 1000
    property int defaultHeight: 700

    // Shared properties для диалогов
    property string selectedImagePath: ""
    property string selectedDocumentPath: ""

    // === ОБРАБОТЧИКИ ОКНА ===
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

    // === ПРОВЕРКА ПРАВ ===
    readonly property string currentRole: typeof authManager !== "undefined" && authManager
                                          ? authManager.currentRole : ""
    readonly property bool canEdit: currentRole === "admin" || currentRole === "manager"
    readonly property bool canCreateSpec: currentRole === "admin" || currentRole === "manager"
    readonly property bool canSettings: currentRole === "admin"

    // === НАВИГАЦИЯ С ПРОВЕРКОЙ ПРАВ ===
    function navigateTo(mode) {
        // Проверка прав доступа
        if (mode === "edit" && !canEdit) {
            errorDialog.showError("У вас нет прав для редактирования склада")
            return
        }
        if (mode === "create_spec" && !canCreateSpec) {
            errorDialog.showError("У вас нет прав для создания спецификаций")
            return
        }
        if (mode === "settings" && !canSettings) {
            errorDialog.showError("У вас нет прав для доступа к настройкам")
            return
        }

        currentMode = mode
    }

    // === ОТСЛЕЖИВАНИЕ АКТИВНОСТИ ПОЛЬЗОВАТЕЛЯ ===
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true

        onPressed: function(mouse) {
            resetInactivity()
            mouse.accepted = false
        }

        onPositionChanged: function(mouse) {
            resetInactivity()
            mouse.accepted = false
        }
    }

    // Отслеживание клавиатуры
    Item {
        focus: true
        Keys.onPressed: function(event) {
            resetInactivity()
            event.accepted = false
        }
    }

    function resetInactivity() {
        if (typeof authManager !== "undefined" && authManager && authManager.isLoggedIn) {
            authManager.resetInactivityTimer()
        }
    }

    // === ПОДКЛЮЧЕНИЕ К AUTH MANAGER ===
    Connections {
        target: typeof authManager !== "undefined" ? authManager : null

        function onLoginSuccessful(username, role) {
            console.log("Login successful:", username, role)
            navigateTo("main")
        }

        function onLoggedOut(reason) {
            console.log("Logged out:", reason)
            inactivityWarningDialog.close()
            loginScreen.reset()
            navigateTo("login")

            if (reason === "timeout") {
                errorDialog.showWarning("Сессия завершена из-за неактивности")
            }
        }

        function onInactivityWarning(secondsLeft) {
            inactivityWarningDialog.updateSeconds(secondsLeft)
        }
    }

    // === MAIN CONTENT SWITCHER ===
    StackLayout {
        anchors.fill: parent
        currentIndex: {
            switch (currentMode) {
                case "login": return 0
                case "main": return 1
                case "edit": return 2
                case "view": return 3
                case "create_spec": return 4
                case "view_spec": return 5
                case "settings": return 6
                default: return 0
            }
        }

        // ========================================
        // 0: LOGIN
        // ========================================
        LoginScreen {
            id: loginScreen
            onLoginSuccessful: navigateTo("main")
        }

        // ========================================
        // 1: MAIN MENU
        // ========================================
        MainMenuScreen {
            onEditWarehouseClicked: navigateTo("edit")
            onViewWarehouseClicked: navigateTo("view")
            onCreateSpecificationClicked: navigateTo("create_spec")
            onViewSpecificationsClicked: navigateTo("view_spec")
            onSettingsClicked: navigateTo("settings")
        }

        // ========================================
        // 2: EDIT WAREHOUSE MODE
        // ========================================
        EditWarehouseScreen {
            id: editScreen
            onBackToMain: navigateTo("main")

            onSelectedImagePathChanged: mainWindow.selectedImagePath = selectedImagePath
            onSelectedDocumentPathChanged: mainWindow.selectedDocumentPath = selectedDocumentPath
        }

        // ========================================
        // 3: VIEW WAREHOUSE MODE
        // ========================================
        ViewWarehouseScreen {
            id: viewScreen
            isActive: currentMode === "view"
            onBackToMain: navigateTo("main")
        }

        // ========================================
        // 4: CREATE SPECIFICATION MODE
        // ========================================
        CreateSpecificationMode {
            onBackToMain: navigateTo("main")
        }

        // ========================================
        // 5: VIEW SPECIFICATIONS MODE
        // ========================================
        ViewSpecificationsMode {
            onBackToMain: navigateTo("main")
        }

        // ========================================
        // 6: SETTINGS (только для admin)
        // ========================================
        SettingsScreen {
            onBackToMain: navigateTo("main")
        }
    }

    // ========================================
    // HEADER С ИНФОРМАЦИЕЙ О ПОЛЬЗОВАТЕЛЕ
    // ========================================
    Rectangle {
        id: userHeader
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: userHeaderContent.width + 20
        height: 36
        radius: Theme.smallRadius
        color: Qt.rgba(0, 0, 0, 0.1)
        visible: currentMode !== "login" && currentMode !== "settings" && (typeof authManager !== "undefined" && authManager && authManager.isLoggedIn)
        z: 100

        RowLayout {
            id: userHeaderContent
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "👤"
                font.pixelSize: 16
            }

            Text {
                text: typeof authManager !== "undefined" && authManager ? authManager.currentUser : ""
                font: Theme.defaultFont
                color: Theme.textOnPrimary
            }

            Text {
                text: "(" + (typeof authManager !== "undefined" && authManager ? authManager.currentRole : "") + ")"
                font.pixelSize: Theme.sizeCaption
                color: Theme.textSubtitle
            }

            // Кнопка выхода
            Button {
                implicitWidth: 30
                implicitHeight: 30
                flat: true

                background: Rectangle {
                    radius: Theme.smallRadius
                    color: parent.hovered ? Qt.rgba(255, 255, 255, 0.2) : "transparent"
                }

                contentItem: Text {
                    text: "🚪"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (typeof authManager !== "undefined" && authManager) {
                        authManager.logout("manual")
                    }
                }

                ToolTip.visible: hovered
                ToolTip.text: "Выйти"
            }
        }
    }

    // ========================================
    // SHARED DIALOGS
    // ========================================

    // Диалог предупреждения о неактивности
    InactivityWarningDialog {
        id: inactivityWarningDialog
    }

    // Диалог ошибок/уведомлений
    NotificationDialog {
        id: errorDialog
    }

    // Диалог удаления товара
    DeleteConfirmationDialog {
        id: deleteDialog
        onConfirmed: function(itemIndex) {
            if (itemIndex >= 0) {
                itemsModel.deleteItem(itemIndex)
                if (editScreen.controlPanel) {
                    editScreen.controlPanel.clearFields()
                }
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
            if (editScreen.controlPanel && editScreen.controlPanel.imageField) {
                editScreen.controlPanel.imageField.text = fileName
            }
        }
    }

    DocumentFileDialog {
        id: documentDialog
        onDocumentSelected: function(path) {
            var fileName = path.split("/").pop()
            mainWindow.selectedDocumentPath = "documents/" + fileName
            if (editScreen.controlPanel && editScreen.controlPanel.documentField) {
                editScreen.controlPanel.documentField.text = fileName
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
