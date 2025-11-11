// ControlPanel.qml - Исправленная версия с полными данными товара
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
    property int currentItemId: -1
    property string currentArticle: ""
    property var currentItemData: ({})
    property bool isEditMode: currentItemId !== -1

    // Product Card Dialog properties
    property Component productCardDialogComponent: null
    property var currentProductDialog: null

    // Public functions for dialog management
    function openProductCardDialog() {
        console.log("openProductCardDialog called")

        if (!productCardDialogComponent) {
            console.log("Creating component from ProductCardDialog.qml")
            productCardDialogComponent = Qt.createComponent("ProductCardDialog.qml")
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

            // Обработчик добавления товара
            currentProductDialog.addItemClicked.connect(function(itemData) {
                console.log("addItemClicked signal received")
                root.addItemClicked(itemData)
                currentProductDialog.close()
            })

            // Обработчик сохранения товара
            currentProductDialog.saveItemClicked.connect(function(itemIndex, itemData) {
                console.log("saveItemClicked signal received")
                root.saveItemClicked(itemIndex, itemData)
                currentProductDialog.close()
            })

            // Очищаем модель документов для нового товара
            console.log("Clearing documents model for new item")
            if (itemDocumentsModel) {
                itemDocumentsModel.clear()
            }

            // Очищаем поля диалога
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
            productCardDialogComponent = Qt.createComponent("ProductCardDialog.qml")
        }

        if (productCardDialogComponent.status === Component.Ready) {
            var rootWindow = root
            while (rootWindow.parent) {
                rootWindow = rootWindow.parent
            }

            currentProductDialog = productCardDialogComponent.createObject(rootWindow, {
                "itemDocumentsModel": itemDocumentsModel
            })

            // Обработчик добавления (не используется в режиме редактирования, но нужен)
            currentProductDialog.addItemClicked.connect(function(itemData) {
                console.log("addItemClicked signal received")
                root.addItemClicked(itemData)
                currentProductDialog.close()
            })

            // Обработчик сохранения изменений
            currentProductDialog.saveItemClicked.connect(function(itemIndex, itemData) {
                console.log("saveItemClicked signal received")
                root.saveItemClicked(itemIndex, itemData)
                currentProductDialog.close()
            })

            // Заполняем поля данными товара
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
        vatIncluded.checked = false

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

            // Кнопка "Добавить товар"
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "➕ Добавить товар"
                font.pointSize: baseFontSize + 1

                background: Rectangle {
                    color: parent.hovered ? "#FFD700" : "#FFC700"
                    radius: 4
                    border.color: "#FFA000"
                    border.width: 2
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.openProductCardDialog()
            }

            // Кнопка "Редактировать товар"
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "✏️ Редактировать товар"
                font.pointSize: baseFontSize + 1
                enabled: currentItemId !== -1

                background: Rectangle {
                    color: parent.enabled ? (parent.hovered ? "#FFA500" : "#FFB84D") : "#CCCCCC"
                    radius: 4
                    border.color: parent.enabled ? "#FF8C00" : "#999999"
                    border.width: 2
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.enabled ? "#333333" : "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

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

            // Spacer
            Item { Layout.fillHeight: true }

            // Bottom spacer
            Item { Layout.preferredHeight: root.contentBottomPadding }
        }
    }
}