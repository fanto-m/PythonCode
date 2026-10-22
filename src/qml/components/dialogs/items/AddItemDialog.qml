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
    width: 700
    height: 600 // Немного увеличим высоту для удобства
    anchors.centerIn: parent

    signal itemSelected(string article, string name, real quantity, string unit, real price, string imagePath, string category, string status)

    function openDialog() {
        searchField.text = ""
        open()
    }

    background: Rectangle {
        color: "white"
        border.color: Theme.accentColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    header: Rectangle {
        width: parent.width
        height: 50
        color: "#9b59b6"
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

        // Поле поиска (поле количества отсюда убрали)
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
            spacing: 5

            delegate: Rectangle {
                id: itemDelegate
                width: warehouseListView.width
                height: 80
                color: "white"
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // 1. Миниатюра изображения
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
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "📦"
                            font.pixelSize: 24
                            visible: !model.image_path || model.image_path === "" || itemImage.status !== Image.Ready
                            color: Theme.inputBorder
                        }
                    }

                    // 2. Информация о товаре
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
                            text: "Цена: " + (model.price !== undefined ? model.price.toFixed(2) : "0.00") + " ₽"
                            font.pixelSize: Theme.sizeSmall
                            font.family: Theme.defaultFont.family
                            color: Theme.successColor
                            font.bold: true
                        }
                    }

                    // 3. Блок ввода количества и кнопки добавления
                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 8

                        Common.AppTextField {
                            id: cardQuantityField
                            Layout.preferredWidth: 70
                            text: "1"
                            placeholderText: "Кол-во"

                            validator: DoubleValidator {
                                bottom: 0.001
                                decimals: 3
                                notation: DoubleValidator.StandardNotation
                            }
                        }

                        Common.AppButton {
                            text: "Добавить"
                            Layout.preferredWidth: 100
                            btnColor: Theme.accentColor

                            onClicked: {
                                let articleValue = model.article || ""
                                let nameValue = model.name || ""
                                let unitValue = model.unit || "шт."
                                let priceValue = (model.price !== undefined && model.price !== null) ? parseFloat(model.price) : 0.0
                                let imageValue = model.image_path || ""
                                let categoryValue = model.category || ""
                                let statusValue = model.status || "active"

                                let qtyStr = cardQuantityField.text.replace(',', '.');
                                let quantityValue = parseFloat(qtyStr);

                                if (isNaN(quantityValue) || quantityValue <= 0) {
                                    quantityValue = 1.0;
                                }

                                // Эмитим сигнал добавления
                                addItemDialog.itemSelected(
                                    articleValue,
                                    nameValue,
                                    quantityValue,
                                    unitValue,
                                    priceValue,
                                    imageValue,
                                    categoryValue,
                                    statusValue
                                )

                                // Опционально: сбрасываем счетчик после добавления, но НЕ закрываем окно,
                                // чтобы пользователь мог добавить еще позиции
                                cardQuantityField.text = "1"

                                if (typeof notificationDialog !== "undefined") {
                                    notificationDialog.showSuccess("Товар добавлен!")
                                }
                            }
                        }
                    }
                }
            }

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
}