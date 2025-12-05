// EditWarehouseScreen.qml - Экран редактирования склада
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"
import "../components/panels"
import "../components/tables"

Item {
    id: root

    // Сигнал возврата в главное меню
    signal backToMain()

    // Выбранные пути файлов (для связи с диалогами)
    property string selectedImagePath: ""
    property string selectedDocumentPath: ""

    // Доступ к ControlPanel извне (для диалогов)
    property alias controlPanel: controlPanel

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // === HEADER ===
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
                        root.backToMain()
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

        // === FILTER PANEL ===
        FilterPanel {}

        // === MAIN CONTENT ===
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            // Список товаров
            ItemList {
                id: itemList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: itemsModel

                onItemSelected: function(itemData) {
                    controlPanel.currentItemId = itemData.index
                    controlPanel.currentArticle = itemData.article
                    controlPanel.currentItemData = Object.assign({}, itemData)
                    root.selectedImagePath = itemData.image_path
                    root.selectedDocumentPath = itemData.document
                }

                onDeleteRequested: function(index, name, article) {
                    deleteDialog.openFor(index, name, article)
                }
            }

            // Панель управления
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
