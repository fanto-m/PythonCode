// EditWarehouseScreen.qml - Экран редактирования склада
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"
import "../components/panels"
import "../components/tables"

Rectangle {
    id: root
    color: Theme.backgroundColor

    // Сигналы навигации
    signal backToMain()

    // Сигналы для диалогов категорий
    signal addCategoryClicked()
    signal editCategoryClicked(var categoryData)
    signal deleteCategoryClicked(var categoryData)

    // Сигналы для товаров
    signal addItemClicked(var itemData)
    signal saveItemClicked(int itemIndex, var itemData)
    signal copyItemClicked(var itemData)
    signal deleteItemRequested(int index, string name, string article)

    // Свойства для связи с внешними моделями
    property var itemsModel
    property var categoryModel
    property var suppliersTableModel
    property var itemDocumentsModel
    property var itemSuppliersModel

    // Выбранные пути файлов
    property string selectedImagePath: ""
    property string selectedDocumentPath: ""

    // Доступ к ControlPanel извне
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
                anchors.margins: Theme.defaultSpacing
                spacing: 15

                Button {
                    text: "← Главное меню"
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        controlPanel.clearFields()
                        root.backToMain()
                    }

                    background: Rectangle {
                        color: parent.down ? Theme.editModeDark : (parent.hovered ? Theme.menuTitleColor : "transparent")
                        radius: Theme.smallRadius
                        border.color: Theme.textOnPrimary
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.textOnPrimary
                        font: Theme.defaultFont
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
        FilterPanel {
            id: filterPanel
            itemsModel: root.itemsModel
        }

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
                model: root.itemsModel

                onItemSelected: function(itemData) {
                    controlPanel.currentItemId = itemData.index
                    controlPanel.currentArticle = itemData.article
                    controlPanel.currentItemData = Object.assign({}, itemData)
                    root.selectedImagePath = itemData.image_path
                    root.selectedDocumentPath = itemData.document
                }

                onDeleteRequested: function(index, name, article) {
                    root.deleteItemRequested(index, name, article)
                }
            }

            // Панель управления
            ControlPanel {
                id: controlPanel
                Layout.preferredWidth: 416

                onAddCategoryClicked: root.addCategoryClicked()

                onEditCategoryClicked: function(categoryData) {
                    if (categoryData && categoryData.id !== undefined) {
                        root.editCategoryClicked(categoryData)
                    }
                }

                onDeleteCategoryClicked: function(categoryData) {
                    root.deleteCategoryClicked(categoryData)
                }

                onAddItemClicked: function(itemData) {
                    root.addItemClicked(itemData)
                }

                onSaveItemClicked: function(itemIndex, itemData) {
                    root.saveItemClicked(itemIndex, itemData)
                }

                onCopyItemClicked: function(itemData) {
                    root.copyItemClicked(itemData)
                }
            }
        }
    }
}
