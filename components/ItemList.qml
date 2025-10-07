import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 5

    property alias model: listView.model
    property bool readOnly: false  // NEW: Controls whether editing features are visible

    signal itemSelected(var itemData)
    signal deleteRequested(int index, string name, string article)

    ListView {
        id: listView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 10
        model: itemsModel
        clip: true
        cacheBuffer: 400

        // Empty state message
        Label {
            anchors.centerIn: parent
            visible: listView.count === 0
            text: "Нет товаров для отображения"
            font.pointSize: 12
            color: "#999"
        }

        delegate: Rectangle {
            id: delegateRoot
            width: listView.width
            height: 200
            radius: 4
            border.width: listView.currentIndex === index ? 2 : 1
            border.color: listView.currentIndex === index ? "#007bff" : "#ccc"

            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on border.width { NumberAnimation { duration: 150 } }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: {
                    if (listView.currentIndex !== index) {
                        delegateRoot.color = "#f5f5f5"
                    }
                }
                onExited: {
                    delegateRoot.color = "white"
                }

                onClicked: {
                    listView.currentIndex = index
                    var selectedData = {
                        "index": index,
                        "article": model.article,
                        "name": model.name,
                        "description": model.description,
                        "image_path": model.image_path,
                        "category": model.category,
                        "price": model.price,
                        "stock": model.stock,
                        "created_date": model.created_date,
                        "status": model.status,
                        "unit": model.unit,
                        "manufacturer": model.manufacturer,
                        "barcode": model.barcode
                    }
                    itemSelected(selectedData)
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // --- Image ---
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    color: "#f0f0f0"
                    radius: 4
                    border.color: "#ddd"
                    border.width: 1

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: model.image_path ? "../images/" + model.image_path : ""
                        fillMode: Image.PreserveAspectFit

                        Text {
                            anchors.centerIn: parent
                            text: "Нет\nфото"
                            visible: parent.status !== Image.Ready
                            font.pointSize: 9
                            color: "#999"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // --- Main Info ---
                ColumnLayout {
                    spacing: 3
                    Layout.preferredWidth: 250

                    Text {
                        text: model.name
                        font.bold: true
                        font.pointSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "Артикул: " + model.article
                        font.pointSize: 10
                        color: "#555"
                    }
                    Text {
                        text: "Категория: " + (model.category || "Без категории")
                        font.pointSize: 10
                        color: "#555"
                    }
                    Text {
                        text: "Цена: " + model.price.toFixed(2) + " ₽"
                        font.pointSize: 10
                        font.bold: true
                        color: "#007bff"
                    }

                    RowLayout {
                        spacing: 5
                        Text {
                            text: "На складе: " + model.stock + " " + (model.unit || "шт.")
                            font.pointSize: 10
                            color: model.stock > 0 ? "#28a745" : "#dc3545"
                            font.bold: model.stock <= 5
                        }
                        Rectangle {
                            visible: model.stock <= 5 && model.stock > 0
                            width: 8
                            height: 8
                            radius: 4
                            color: "#ffc107"
                        }
                    }

                    Text {
                        text: "Статус: " + (model.status || "в наличии")
                        font.pointSize: 10
                        color: "#555"
                    }

                    Text {
                        text: model.manufacturer ? "Производитель: " + model.manufacturer : ""
                        font.pointSize: 9
                        color: "#777"
                        visible: model.manufacturer !== undefined && model.manufacturer !== null && model.manufacturer !== ""
                    }
                    Text {
                        text: model.barcode ? "Штрихкод: " + model.barcode : ""
                        font.pointSize: 9
                        color: "#777"
                        visible: model.barcode !== undefined && model.barcode !== null && model.barcode !== ""
                    }
                    Text {
                        text: "Добавлено: " + (model.created_date ? model.created_date.split(" ")[0] : "")
                        font.pointSize: 9
                        color: "#999"
                    }
                }

                // --- Left Spacer ---
                Item {
                    Layout.fillWidth: true
                }

                // --- Description ---
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    color: "#f9f9f9"
                    border.color: "#ddd"
                    border.width: 1
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        anchors.margins: 10
                        width: parent.width - 20
                        text: model.description || "Нет описания"
                        wrapMode: Text.WordWrap
                        font.pointSize: 10
                        color: model.description ? "#333" : "#999"
                        font.italic: !model.description
                        horizontalAlignment: Text.AlignJustify
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // --- Right Spacer ---
                Item {
                    Layout.fillWidth: true
                }

                // --- Action Buttons ---
                ColumnLayout {
                    spacing: 10
                    Layout.rightMargin: 5
                    visible: !readOnly  // HIDE buttons in readOnly mode

                    Button {
                        text: "Поставщики"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40

                        ToolTip.visible: hovered
                        ToolTip.text: "Управление поставщиками товара"
                        ToolTip.delay: 500

                        onClicked: {
                            itemSuppliersDialog.openFor(model.article)
                        }

                        background: Rectangle {
                            color: parent.down ? "#0056b3" : (parent.hovered ? "#0069d9" : "#007bff")
                            radius: 4
                            border.color: "#0056b3"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 10
                        }
                    }

                    Button {
                        text: "Удалить"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40

                        ToolTip.visible: hovered
                        ToolTip.text: "Удалить товар из базы данных"
                        ToolTip.delay: 500

                        onClicked: {
                            deleteRequested(index, model.name, model.article)
                        }

                        background: Rectangle {
                            color: parent.down ? "#c82333" : (parent.hovered ? "#e02535" : "#dc3545")
                            radius: 4
                            border.color: "#bd2130"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 10
                        }
                    }
                }

                // --- View-only info button (shown in readOnly mode) ---
                Button {
                    visible: readOnly
                    text: "📋 Поставщики"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 5

                    ToolTip.visible: hovered
                    ToolTip.text: "Просмотр поставщиков товара"
                    ToolTip.delay: 500

                    onClicked: {
                        itemSuppliersDialog.openFor(model.article)
                    }

                    background: Rectangle {
                        color: parent.down ? "#0056b3" : (parent.hovered ? "#0069d9" : "#007bff")
                        radius: 4
                        border.color: "#0056b3"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 10
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    // --- Info Panel ---
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        color: "#f8f9fa"
        border.color: "#dee2e6"
        border.width: 1
        radius: 3

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: "Всего товаров: " + listView.count
            font.pointSize: 10
            color: "#495057"
        }
    }
}