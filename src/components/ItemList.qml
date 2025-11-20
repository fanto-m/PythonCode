//ItemList.qml - ВЕРСИЯ с ComboBox для документов и кнопкой "Открыть"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 5

    property alias model: listView.model
    property bool readOnly: false

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

            // НОВОЕ: Модель документов для этого товара
            property var itemDocumentsModelInstance: null

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
                        "document": model.document
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
                        id: itemImage
                        anchors.fill: parent
                        anchors.margins: 2
                        source: model.image_path ? "../" + model.image_path : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        cache: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.warn("Failed to load image:", model.image_path)
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Нет\nфото"
                        visible: !model.image_path || itemImage.status === Image.Error
                        font.pointSize: 9
                        color: "#999"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: itemImage.status === Image.Loading
                        visible: running
                        width: 30
                        height: 30
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

                    // НОВОЕ: Показываем количество документов
                    /*Text {
                        text: {
                            if (!itemDocumentsModel) return ""
                            var count = itemDocumentsModel.count()
                            if (count === 0) return ""
                            if (count === 1) return "📄 Документ: 1"
                            return "📄 Документов: " + count
                        }
                        font.pointSize: 9
                        color: "#007bff"
                        font.bold: itemDocumentsModel && itemDocumentsModel.count() > 0
                        visible: itemDocumentsModel && itemDocumentsModel.count() > 0
                    }*/

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
                    visible: !readOnly

                    Button {
                        text: "Поставщики"
                        Layout.preferredWidth: 150
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

                    // ===============================================
                   // Меню с документами (объявляем ДО кнопки)
                    Menu {
                        id: documentsMenu

                        Repeater {
                            model: documentsButton.documentsList

                            MenuItem {
                                text: modelData ? modelData.name : ""

                                ToolTip.visible: hovered && modelData
                                ToolTip.text: modelData ? modelData.name : ""
                                ToolTip.delay: 300

                                onTriggered: {
                                    if (fileManager && modelData && modelData.path) {
                                        console.log("Opening document:", modelData.path)
                                        fileManager.open_file_externally(modelData.path)
                                    }
                                }

                                contentItem: RowLayout {
                                    spacing: 8

                                    Text {
                                        text: "📄"
                                        font.pointSize: 10
                                    }

                                    Text {
                                        text: parent.parent.text
                                        font.pointSize: 10
                                        color: parent.parent.highlighted ? "white" : "#333"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                background: Rectangle {
                                    color: parent.highlighted ? "#86ac41" : "transparent"
                                    radius: 2
                                }
                            }
                        }
                    }

                    // Кнопка "Документы"
                    Button {
                        id: documentsButton
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40

                        property string itemArticle: model.article
                        property var documentsList: []

                        text: {
                            if (documentsList.length === 0) return "Нет документов"
                            if (documentsList.length === 1) return "1 документ"
                            return documentsList.length + " документа"
                        }

                        enabled: documentsList.length > 0

                        font.pointSize: 9

                        // Загружаем список документов при создании
                        Component.onCompleted: {
                            if (itemDocumentsModel && itemArticle) {
                                itemDocumentsModel.loadDocuments(itemArticle)

                                // Копируем документы в локальный массив
                                var docs = []
                                for (var i = 0; i < itemDocumentsModel.count(); i++) {
                                    var docName = itemDocumentsModel.getDocumentName(i)
                                    var docPath = itemDocumentsModel.getDocumentPath(i)

                                    docs.push({
                                        name: docName,
                                        path: docPath
                                    })

                                    console.log("Document", i, ":", docName, "->", docPath)
                                }
                                documentsList = docs
                                console.log("Article", itemArticle, "loaded", docs.length, "documents")
                            }
                        }

                        onClicked: documentsMenu.popup(documentsButton)

                        background: Rectangle {
                            color: parent.enabled ? "white" : "#f5f5f5"
                            border.color: parent.enabled ? "#86ac41" : "#ccc"
                            border.width: 1
                            radius: 4
                        }

                        contentItem: RowLayout {
                            spacing: 6

                            Text {
                                text: "📄"
                                font.pointSize: 12
                                color: parent.parent.enabled ? "#86ac41" : "#999"
                            }

                            Text {
                                text: parent.parent.text
                                font: parent.parent.font
                                color: parent.parent.enabled ? "#333" : "#999"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "▼"
                                font.pointSize: 8
                                color: parent.parent.enabled ? "#86ac41" : "#999"
                                visible: parent.parent.enabled
                            }
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: enabled ? "Открыть список документов" : "Нет документов"
                        ToolTip.delay: 500
                    }


                    Button {
                        text: "Удалить"
                        Layout.preferredWidth: 150
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
                // --- View-only info button (shown in readOnly mode) ---
                ColumnLayout {
                    visible: readOnly
                    spacing: 10
                    Layout.rightMargin: 5

                    Button {
                        text: "📋 Поставщики"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignVCenter

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

                    // НОВОЕ: Кнопка "Документы" в режиме просмотра
                    Button {
                        id: documentsButtonReadOnly
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignVCenter

                        property string itemArticle: model.article
                        property var documentsList: []

                        text: {
                            if (documentsList.length === 0) return "Нет документов"
                            if (documentsList.length === 1) return "1 документ"
                            return documentsList.length + " документов"
                        }

                        enabled: documentsList.length > 0
                        font.pointSize: 9

                        // Загружаем список документов при создании
                        Component.onCompleted: {
                            if (itemDocumentsModel && itemArticle) {
                                itemDocumentsModel.loadDocuments(itemArticle)

                                var docs = []
                                for (var i = 0; i < itemDocumentsModel.count(); i++) {
                                    var docName = itemDocumentsModel.getDocumentName(i)
                                    var docPath = itemDocumentsModel.getDocumentPath(i)

                                    docs.push({
                                        name: docName,
                                        path: docPath
                                    })
                                }
                                documentsList = docs
                            }
                        }

                        onClicked: documentsMenuReadOnly.popup(documentsButtonReadOnly)

                        background: Rectangle {
                            color: parent.enabled ? "white" : "#f5f5f5"
                            border.color: parent.enabled ? "#86ac41" : "#ccc"
                            border.width: 1
                            radius: 4
                        }

                        contentItem: RowLayout {
                            spacing: 6

                            Text {
                                text: "📄"
                                font.pointSize: 12
                                color: parent.parent.enabled ? "#86ac41" : "#999"
                            }

                            Text {
                                text: parent.parent.text
                                font: parent.parent.font
                                color: parent.parent.enabled ? "#333" : "#999"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "▼"
                                font.pointSize: 8
                                color: parent.parent.enabled ? "#86ac41" : "#999"
                                visible: parent.parent.enabled
                            }
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: enabled ? "Открыть список документов" : "Нет документов"
                        ToolTip.delay: 500
                    }

                    // Меню документов для режима просмотра
                    Menu {
                        id: documentsMenuReadOnly

                        Repeater {
                            model: documentsButtonReadOnly.documentsList

                            MenuItem {
                                text: modelData ? modelData.name : ""

                                ToolTip.visible: hovered && modelData
                                ToolTip.text: modelData ? modelData.name : ""
                                ToolTip.delay: 300

                                onTriggered: {
                                    if (fileManager && modelData && modelData.path) {
                                        console.log("Opening document:", modelData.path)
                                        fileManager.open_file_externally(modelData.path)
                                    }
                                }

                                contentItem: RowLayout {
                                    spacing: 8

                                    Text {
                                        text: "📄"
                                        font.pointSize: 10
                                    }

                                    Text {
                                        text: parent.parent.text
                                        font.pointSize: 10
                                        color: parent.parent.highlighted ? "white" : "#333"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                background: Rectangle {
                                    color: parent.highlighted ? "#86ac41" : "transparent"
                                    radius: 2
                                }
                            }
                        }
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
