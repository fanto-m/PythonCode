// AddItemDialog.qml - Компонент для выбора товара из склада
// Расположение: src/qml/components/dialogs/items/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common" as Common

Dialog {
    id: addItemDialog
    title: "Добавить позицию из склада"
    modal: true
    width: 900
    height: 500
    anchors.centerIn: parent

    // Сигнал, который вызывается при выборе товара
    signal itemSelected(string article, string name, real quantity, string unit, real price, string imagePath, string category, string status)

    // Функция для открытия диалога
    function openDialog() {
        searchField.text = ""
        open()
    }

    // === ФОН ДИАЛОГА ===
    background: Rectangle {
        color: "white"
        border.color: Theme.accentColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    // === ЗАГОЛОВОК ===
    header: Rectangle {
        width: parent.width
        height: 50
        color: "#9b59b6"  // Фиолетовый для спецификаций
        radius: Theme.defaultRadius

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.defaultRadius
            color: "#9b59b6"
        }

        Text {
            anchors.centerIn: parent
            text: "📦 Добавить позицию из склада"
            font.pixelSize: Theme.sizeH3
            font.bold: true
            font.family: Theme.defaultFont.family
            color: Theme.textOnPrimary
        }

        // Область для перетаскивания
        MouseArea {
            anchors.fill: parent
            property point clickPos: Qt.point(0, 0)
            onPressed: function(mouse) {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: function(mouse) {
                if (pressed) {
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    addItemDialog.x += delta.x
                    addItemDialog.y += delta.y
                }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 10

        // Поле поиска
        Common.AppTextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "🔍 Поиск товара по названию или артикулу..."
            enterDelay: 0
            onTextChanged: {
                itemsModel.setFilterString(text)
            }
        }

        // Список товаров
        ListView {
            id: warehouseListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: itemsModel

            delegate: Rectangle {
                id: itemDelegate
                width: warehouseListView.width
                height: 80
                color: itemMouseArea.containsMouse ? Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.1) : "white"
                border.color: Theme.inputBorder
                border.width: 1

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        let articleValue = model.article || ""
                        let nameValue = model.name || ""
                        let unitValue = model.unit || "шт."
                        let priceValue = (model.price !== undefined && model.price !== null) ? parseFloat(model.price) : 0.0
                        let imageValue = model.image_path || ""
                        let categoryValue = model.category || ""
                        let statusValue = model.status || "active"

                        addItemDialog.itemSelected(
                            articleValue,
                            nameValue,
                            1.0,
                            unitValue,
                            priceValue,
                            imageValue,
                            categoryValue,
                            statusValue
                        )

                        addItemDialog.close()
                        searchField.text = ""
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Миниатюра изображения
                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        color: Theme.backgroundColor
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius

                        Image {
                            id: itemImage
                            anchors.fill: parent
                            anchors.margins: 2
                            source: model.image_path ? "../../../../" + model.image_path : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: model.image_path && model.image_path !== "" && status === Image.Ready

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.warn("Failed to load image:", model.image_path)
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "📦"
                            font.pixelSize: 24
                            visible: !model.image_path || model.image_path === "" || itemImage.status !== Image.Ready
                            color: Theme.inputBorder
                        }
                    }

                    // Информация о товаре
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 2

                        Text {
                            text: model.name || ""
                            font.pixelSize: Theme.sizeBody
                            font.bold: true
                            font.family: Theme.defaultFont.family
                            color: Theme.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Артикул: " + (model.article || "") + " | На складе: " + (model.stock || 0) + " " + (model.unit || "шт.")
                            font.pixelSize: Theme.sizeCaption
                            font.family: Theme.defaultFont.family
                            color: Theme.textSecondary
                        }

                        Text {
                            text: "Категория: " + (model.category || "Не указана")
                            font.pixelSize: Theme.sizeSmall
                            font.family: Theme.defaultFont.family
                            color: Theme.inputBorder
                            visible: model.category !== undefined
                        }
                    }

                    // Цена
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        color: Qt.rgba(Theme.successColor.r, Theme.successColor.g, Theme.successColor.b, 0.1)
                        border.color: Theme.successColor
                        border.width: 1
                        radius: Theme.smallRadius

                        Text {
                            anchors.centerIn: parent
                            text: (model.price !== undefined ? model.price.toFixed(2) : "0.00") + " ₽"
                            font.pixelSize: Theme.sizeBody
                            font.bold: true
                            font.family: Theme.defaultFont.family
                            color: Theme.successColor
                        }
                    }
                }
            }

            // Пустой список
            Text {
                anchors.centerIn: parent
                visible: warehouseListView.count === 0
                text: "Товары не найдены"
                font: Theme.defaultFont
                color: Theme.inputBorder
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignRight
        padding: 12

        background: Rectangle {
            color: Theme.backgroundColor
            radius: Theme.smallRadius
        }

        Common.AppButton {
            text: "Закрыть"
            btnColor: Theme.textSecondary
            animateEntry: false
            onClicked: {
                addItemDialog.close()
                searchField.text = ""
            }
        }
    }

    // === АНИМАЦИИ ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 250; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.95; duration: 150; easing.type: Easing.InCubic }
        }
    }
}
