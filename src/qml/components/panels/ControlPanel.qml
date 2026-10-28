// ControlPanel.qml - Панель управления товарами
// Расположение: qml/components/panels/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common" as Common
import "../dialogs/items"
import "../dialogs"

Rectangle {
    id: root
    Layout.preferredWidth: 416
    Layout.fillHeight: true

    color: "white"
    border.width: 1
    border.color: Theme.inputBorder
    radius: Theme.defaultRadius

    // === СИГНАЛЫ ===
    signal addItemClicked(var itemData)
    signal saveItemClicked(int itemIndex, var itemData)
    signal addCategoryClicked()
    signal editCategoryClicked(var categoryData)
    signal deleteCategoryClicked(var categoryData)
    signal copyItemClicked(var itemData)

    // === СВОЙСТВА ===
    property int currentItemId: -1
    property string currentArticle: ""
    property var currentItemData: ({})
    property bool isEditMode: currentItemId !== -1

    // Отступы контента
    property int contentPadding: 12

    // Product Card Dialog
    property Component productCardDialogComponent: null
    property var currentProductDialog: null

    // Путь к ProductCardDialog (относительно panels/)
    readonly property string productCardDialogPath: "../dialogs/items/ProductCardDialog.qml"

    // === ФУНКЦИИ ===

    function openProductCardDialog() {
        console.log("openProductCardDialog called")

        if (!productCardDialogComponent) {
            console.log("Creating component from:", productCardDialogPath)
            productCardDialogComponent = Qt.createComponent(productCardDialogPath)
        }

        console.log("Component status: " + productCardDialogComponent.status)

        if (productCardDialogComponent.status === Component.Ready) {
            console.log("Component ready, creating object...")

            var rootWindow = root
            while (rootWindow.parent) {
                rootWindow = rootWindow.parent
            }

            currentProductDialog = productCardDialogComponent.createObject(rootWindow, {
                "itemDocumentsModel": itemDocumentsModel
            })

            if (!currentProductDialog) {
                console.error("Failed to create dialog object!")
                return
            }

            console.log("Dialog object created, connecting signals...")

            currentProductDialog.addItemClicked.connect(function(itemData) {
                console.log("addItemClicked signal received")
                root.addItemClicked(itemData)
                currentProductDialog.close()
            })

            currentProductDialog.saveItemClicked.connect(function(itemIndex, itemData) {
                console.log("saveItemClicked signal received")
                root.saveItemClicked(itemIndex, itemData)
                currentProductDialog.close()
            })

            console.log("Clearing documents model for new item")
            if (itemDocumentsModel) {
                itemDocumentsModel.clear()
            }

            console.log("Clearing dialog fields")
            currentProductDialog.clearFields()

            console.log("Opening dialog...")
            currentProductDialog.open()
        } else if (productCardDialogComponent.status === Component.Error) {
            console.error("Error loading ProductCardDialog: " + productCardDialogComponent.errorString())
        }
    }

    function openProductCardDialogForEdit(itemData) {
        console.log("openProductCardDialogForEdit called with itemData:", JSON.stringify(itemData))

        if (!productCardDialogComponent) {
            productCardDialogComponent = Qt.createComponent(productCardDialogPath)
        }

        if (productCardDialogComponent.status === Component.Ready) {
            var rootWindow = root
            while (rootWindow.parent) {
                rootWindow = rootWindow.parent
            }

            currentProductDialog = productCardDialogComponent.createObject(rootWindow, {
                "itemDocumentsModel": itemDocumentsModel
            })

            currentProductDialog.addItemClicked.connect(function(itemData) {
                console.log("addItemClicked signal received")
                root.addItemClicked(itemData)
                currentProductDialog.close()
            })

            currentProductDialog.saveItemClicked.connect(function(itemIndex, itemData) {
                console.log("saveItemClicked signal received")
                root.saveItemClicked(itemIndex, itemData)
                currentProductDialog.close()
            })

            currentProductDialog.populateFields(itemData)
            currentProductDialog.open()
        } else if (productCardDialogComponent.status === Component.Error) {
            console.error("Error loading ProductCardDialog: " + productCardDialogComponent.errorString())
        }
    }

    function clearFields() {
        currentItemId = -1
        currentArticle = ""
        currentItemData = {}
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 2
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            id: mainColumn
            width: scrollView.width - (contentPadding * 2)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // Верхний отступ
            Item { Layout.preferredHeight: contentPadding }

            // --- Кнопка "Добавить товар" ---
            Common.AppButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "➕ Добавить товар"
                btnColor: Theme.successColor
                enterDelay: 0

                onClicked: root.openProductCardDialog()
            }

            // --- Кнопка "Редактировать товар" ---
            Common.AppButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "✏️ Редактировать товар"
                btnColor: Theme.primaryColor
                enabled: currentItemId !== -1
                enterDelay: 0

                onClicked: {
                    if (currentItemId !== -1 && Object.keys(currentItemData).length > 0) {
                        console.log("DEBUG: Opening edit dialog with full data")
                        console.log("DEBUG: Item data:", JSON.stringify(currentItemData))
                        root.openProductCardDialogForEdit(currentItemData)
                    } else {
                        console.error("ERROR: No valid item data available for editing")
                        console.error("currentItemId:", currentItemId)
                        console.error("currentItemData keys:", Object.keys(currentItemData))
                    }
                }
            }

            // --- Кнопка "Копировать товар" ---
            Common.AppButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "📋 Копировать товар"
                btnColor: "#9C27B0"  // Фиолетовый
                enabled: currentItemId !== -1
                enterDelay: 0

                onClicked: {
                    if (currentItemId !== -1) {
                        root.copyItemClicked(currentItemData)
                    }
                }
            }

            // --- Секция "Категория" ---
            GroupBox {
                Layout.fillWidth: true
                title: "Категория"

                label: Common.AppLabel {
                    text: parent.title
                    level: "body"
                    font.bold: true
                    enterDelay: 0
                }

                background: Rectangle {
                    color: Theme.backgroundColor
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    Common.AppComboBox {
                        id: categoryComboBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        model: categoryModel
                        textRole: "name"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Common.AppButton {
                            text: "➕"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            btnColor: Theme.successColor
                            enterDelay: 0
                            ToolTip.visible: hovered
                            ToolTip.text: "Добавить категорию"

                            onClicked: addCategoryClicked()
                        }

                        Common.AppButton {
                            text: "✏️"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            btnColor: Theme.primaryColor
                            enabled: categoryComboBox.currentIndex >= 0
                            enterDelay: 0
                            ToolTip.visible: hovered
                            ToolTip.text: "Редактировать категорию"

                            onClicked: {
                                if (categoryComboBox.currentIndex >= 0) {
                                    let cat = categoryModel.get(categoryComboBox.currentIndex)
                                    editCategoryClicked(cat)
                                }
                            }
                        }

                        Common.AppButton {
                            text: "🗑️"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            btnColor: Theme.errorColor
                            enabled: categoryComboBox.currentIndex >= 0
                            enterDelay: 0
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

            // --- Секция "Поставщики" ---
            GroupBox {
                Layout.fillWidth: true
                title: "Поставщики"

                label: Common.AppLabel {
                    text: parent.title
                    level: "body"
                    font.bold: true
                    enterDelay: 0
                }

                background: Rectangle {
                    color: Theme.backgroundColor
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 6

                    Common.AppButton {
                        text: "📋 Список"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        btnColor: Theme.accentColor
                        enterDelay: 0

                        onClicked: {
                            suppliersManagerDialog.openForManagement()
                        }
                    }

                    Common.AppButton {
                        text: "🔗 Привязать"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        btnColor: Theme.primaryColor
                        enabled: currentArticle !== ""
                        enterDelay: 0

                        onClicked: {
                            suppliersManagerDialog.openForBinding(currentArticle)
                        }
                    }

                }
            }


            // Spacer (прижимает кнопку экспорта к самому низу панели)
            Item { Layout.fillHeight: true }

            // --- Кнопка "Экспорт в Excel" (на всю ширину внизу панели) ---
            Common.AppButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "📊 Экспорт в Excel"
                btnColor: "#27ae60"
                enterDelay: 0

                onClicked: {
                    exportDialog.open()
                }
            }

            // Нижний отступ
            Item { Layout.preferredHeight: contentPadding }
        }
    }

    // ВАЖНО: Экземпляр диалога должен находиться строго ВНУТРИ корневого элемента (Rectangle)
    ExportSettingsDialog {
        id: exportDialog
    }
}