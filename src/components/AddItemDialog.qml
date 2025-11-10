// AddItemDialog.qml - Компонент для выбора товара из склада (ОБНОВЛЕННАЯ ВЕРСИЯ)
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: addItemDialog
    title: "Добавить позицию из склада"
    modal: true
    width: 700
    height: 500
    anchors.centerIn: parent

    // Сигнал, который вызывается при выборе товара
    signal itemSelected(string article, string name, real quantity, string unit, real price, string imagePath, string category, string status)

    // Функция для открытия диалога
    function openDialog() {
        searchField.text = ""
        open()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Поиск товара..."
            font.pointSize: 10
            onTextChanged: {
                itemsModel.setFilterString(text)
            }

            background: Rectangle {
                color: "white"
                border.color: searchField.activeFocus ? "#9b59b6" : "#d0d0d0"
                border.width: searchField.activeFocus ? 2 : 1
                radius: 4
            }
        }

        ListView {
            id: warehouseListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: itemsModel

            delegate: Rectangle {
                width: warehouseListView.width
                height: 80
                color: mouseArea.containsMouse ? "#f8f9fa" : "white"
                border.color: "#d0d0d0"
                border.width: 1

                MouseArea {
                    id: mouseArea
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

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        color: "#f5f5f5"
                        border.color: "#d0d0d0"
                        border.width: 1
                        radius: 4

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            // Используем полный относительный путь от src
                            source: model.image_path ? "../" + model.image_path : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: model.image_path && model.image_path !== ""

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.warn("Failed to load image:", model.image_path)
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "📦"
                            font.pointSize: 24
                            visible: !model.image_path || model.image_path === "" || parent.children[0].status === Image.Error
                            color: "#999"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 2

                        Text {
                            text: model.name
                            font.pointSize: 10
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "Артикул: " + model.article + " | На складе: " + model.stock + " " + model.unit
                            font.pointSize: 9
                            color: "#666"
                        }

                        Text {
                            text: "Категория: " + (model.category || "Не указана")
                            font.pointSize: 8
                            color: "#999"
                            visible: model.category !== undefined
                        }
                    }

                    Text {
                        text: model.price.toFixed(2) + " ₽"
                        font.pointSize: 11
                        font.bold: true
                        color: "#2c3e50"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: warehouseListView.count === 0
                text: "Товары не найдены"
                font.pointSize: 10
                color: "#999"
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "Закрыть"
            onClicked: {
                addItemDialog.close()
                searchField.text = ""
            }

            background: Rectangle {
                color: parent.down ? "#5a6268" : (parent.hovered ? "#6c757d" : "#6c757d")
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font: parent.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
