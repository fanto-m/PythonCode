// ItemList.qml - Список товаров с карточками
// Расположение: qml/tables/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"
import "../common"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 5

    // === СВОЙСТВА ===
    property alias model: listView.model
    property bool readOnly: false

    // === СИГНАЛЫ ===
    signal itemSelected(var itemData)
    signal deleteRequested(int index, string name, string article)

    // === СПИСОК ТОВАРОВ ===
    ListView {
        id: listView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 10
        model: itemsModel
        clip: true
        cacheBuffer: 400

        // Пустое состояние
        AppLabel {
            anchors.centerIn: parent
            visible: listView.count === 0
            text: "Нет товаров для отображения"
            level: "body"
            color: Theme.textSecondary
            enterDelay: 0
        }

        delegate: Rectangle {
            id: delegateRoot
            width: listView.width
            height: 200
            radius: Theme.smallRadius
            border.width: listView.currentIndex === index ? 2 : 1
            border.color: listView.currentIndex === index ? Theme.primaryColor : Theme.inputBorder

            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on border.width { NumberAnimation { duration: 150 } }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: {
                    if (listView.currentIndex !== index) {
                        delegateRoot.color = Theme.backgroundColor
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

                // --- Изображение ---
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    color: Theme.backgroundColor
                    radius: Theme.smallRadius
                    border.color: Theme.inputBorder
                    border.width: 1

                    Image {
                        id: itemImage
                        anchors.fill: parent
                        anchors.margins: 2
                        source: model.image_path ? "../../../" + model.image_path : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        cache: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.warn("Failed to load image:", model.image_path)
                            }
                        }
                    }

                    AppLabel {
                        anchors.centerIn: parent
                        text: "Нет\nфото"
                        visible: !model.image_path || itemImage.status === Image.Error
                        level: "caption"
                        color: Theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        enterDelay: 0
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: itemImage.status === Image.Loading
                        visible: running
                        width: 30
                        height: 30
                    }
                }

                // --- Основная информация ---
                ColumnLayout {
                    spacing: 3
                    Layout.preferredWidth: 250

                    AppLabel {
                        text: model.name
                        level: "body"
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        enterDelay: 0
                    }

                    AppLabel {
                        text: "Артикул: " + model.article
                        level: "caption"
                        enterDelay: 0
                    }

                    AppLabel {
                        text: "Категория: " + (model.category || "Без категории")
                        level: "caption"
                        enterDelay: 0
                    }

                    AppLabel {
                        text: "Цена: " + model.price.toFixed(2) + " ₽"
                        level: "body"
                        font.bold: true
                        color: Theme.primaryColor
                        enterDelay: 0
                    }

                    RowLayout {
                        spacing: 5
                        AppLabel {
                            text: "На складе: " + model.stock + " " + (model.unit || "шт.")
                            level: "caption"
                            color: model.stock > 0 ? Theme.successColor : Theme.errorColor
                            font.bold: model.stock <= 5
                            enterDelay: 0
                        }
                        Rectangle {
                            visible: model.stock <= 5 && model.stock > 0
                            width: 8
                            height: 8
                            radius: 4
                            color: Theme.warningColor
                        }
                    }

                    AppLabel {
                        text: "Статус: " + (model.status || "в наличии")
                        level: "caption"
                        enterDelay: 0
                    }

                    AppLabel {
                        text: model.manufacturer ? "Производитель: " + model.manufacturer : ""
                        level: "caption"
                        color: Theme.textSecondary
                        visible: model.manufacturer !== undefined && model.manufacturer !== null && model.manufacturer !== ""
                        enterDelay: 0
                    }

                    AppLabel {
                        text: "Добавлено: " + (model.created_date ? model.created_date.split(" ")[0] : "")
                        level: "caption"
                        color: Theme.textSecondary
                        enterDelay: 0
                    }
                }

                // --- Левый спейсер ---
                Item { Layout.fillWidth: true }

                // --- Описание ---
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    color: Theme.backgroundColor
                    border.color: Theme.inputBorder
                    border.width: 1
                    radius: Theme.smallRadius

                    AppLabel {
                        anchors.centerIn: parent
                        anchors.margins: 10
                        width: parent.width - 20
                        text: model.description || "Нет описания"
                        wrapMode: Text.WordWrap
                        level: "body"
                        color: model.description ? Theme.textColor : Theme.textSecondary
                        font.italic: !model.description
                        horizontalAlignment: Text.AlignJustify
                        verticalAlignment: Text.AlignVCenter
                        enterDelay: 0
                    }
                }

                // --- Правый спейсер ---
                Item { Layout.fillWidth: true }

                // === КНОПКИ ДЕЙСТВИЙ (режим редактирования) ===
                ColumnLayout {
                    spacing: 10
                    Layout.rightMargin: 5
                    visible: !readOnly

                    AppButton {
                        text: "Поставщики"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        btnColor: Theme.primaryColor
                        enterDelay: 0

                        ToolTip.visible: hovered
                        ToolTip.text: "Управление поставщиками товара"
                        ToolTip.delay: 500

                        onClicked: {
                            itemSuppliersDialog.openFor(model.article)
                        }
                    }

                    // Меню документов
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
                                        font.pixelSize: Theme.sizeCaption
                                    }
                                    Text {
                                        text: parent.parent.text
                                        font: Theme.defaultFont
                                        color: parent.parent.highlighted ? "white" : Theme.textColor
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
                        font: Theme.defaultFont

                        Component.onCompleted: {
                            if (itemDocumentsModel && itemArticle) {
                                itemDocumentsModel.loadDocuments(itemArticle)
                                var docs = []
                                for (var i = 0; i < itemDocumentsModel.count(); i++) {
                                    var docName = itemDocumentsModel.getDocumentName(i)
                                    var docPath = itemDocumentsModel.getDocumentPath(i)
                                    docs.push({ name: docName, path: docPath })
                                }
                                documentsList = docs
                            }
                        }

                        onClicked: documentsMenu.popup(documentsButton)

                        background: Rectangle {
                            color: parent.enabled ? "white" : Theme.backgroundColor
                            border.color: parent.enabled ? "#86ac41" : Theme.inputBorder
                            border.width: 1
                            radius: Theme.smallRadius
                        }

                        contentItem: RowLayout {
                            spacing: 6
                            Text {
                                text: "📄"
                                font.pixelSize: 12
                                color: parent.parent.enabled ? "#86ac41" : Theme.textSecondary
                            }
                            Text {
                                text: parent.parent.text
                                font: parent.parent.font
                                color: parent.parent.enabled ? Theme.textColor : Theme.textSecondary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "▼"
                                font.pixelSize: 8
                                color: parent.parent.enabled ? "#86ac41" : Theme.textSecondary
                                visible: parent.parent.enabled
                            }
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: enabled ? "Открыть список документов" : "Нет документов"
                        ToolTip.delay: 500
                    }

                    AppButton {
                        text: "Удалить"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        btnColor: Theme.errorColor
                        enterDelay: 0

                        ToolTip.visible: hovered
                        ToolTip.text: "Удалить товар из базы данных"
                        ToolTip.delay: 500

                        onClicked: {
                            deleteRequested(index, model.name, model.article)
                        }
                    }
                }

                // === КНОПКИ (режим только для чтения) ===
                ColumnLayout {
                    visible: readOnly
                    spacing: 10
                    Layout.rightMargin: 5

                    AppButton {
                        text: "📋 Поставщики"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40
                        btnColor: Theme.primaryColor
                        enterDelay: 0

                        ToolTip.visible: hovered
                        ToolTip.text: "Просмотр поставщиков товара"
                        ToolTip.delay: 500

                        onClicked: {
                            itemSuppliersDialog.openFor(model.article)
                        }
                    }

                    // Кнопка документов (режим чтения)
                    Button {
                        id: documentsButtonReadOnly
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40

                        property string itemArticle: model.article
                        property var documentsList: []

                        text: {
                            if (documentsList.length === 0) return "Нет документов"
                            if (documentsList.length === 1) return "1 документ"
                            return documentsList.length + " документов"
                        }

                        enabled: documentsList.length > 0
                        font: Theme.defaultFont

                        Component.onCompleted: {
                            if (itemDocumentsModel && itemArticle) {
                                itemDocumentsModel.loadDocuments(itemArticle)
                                var docs = []
                                for (var i = 0; i < itemDocumentsModel.count(); i++) {
                                    var docName = itemDocumentsModel.getDocumentName(i)
                                    var docPath = itemDocumentsModel.getDocumentPath(i)
                                    docs.push({ name: docName, path: docPath })
                                }
                                documentsList = docs
                            }
                        }

                        onClicked: documentsMenuReadOnly.popup(documentsButtonReadOnly)

                        background: Rectangle {
                            color: parent.enabled ? "white" : Theme.backgroundColor
                            border.color: parent.enabled ? "#86ac41" : Theme.inputBorder
                            border.width: 1
                            radius: Theme.smallRadius
                        }

                        contentItem: RowLayout {
                            spacing: 6
                            Text {
                                text: "📄"
                                font.pixelSize: 12
                                color: parent.parent.enabled ? "#86ac41" : Theme.textSecondary
                            }
                            Text {
                                text: parent.parent.text
                                font: parent.parent.font
                                color: parent.parent.enabled ? Theme.textColor : Theme.textSecondary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "▼"
                                font.pixelSize: 8
                                color: parent.parent.enabled ? "#86ac41" : Theme.textSecondary
                                visible: parent.parent.enabled
                            }
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: enabled ? "Открыть список документов" : "Нет документов"
                        ToolTip.delay: 500
                    }

                    // Меню документов (режим чтения)
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
                                        font.pixelSize: Theme.sizeCaption
                                    }
                                    Text {
                                        text: parent.parent.text
                                        font: Theme.defaultFont
                                        color: parent.parent.highlighted ? "white" : Theme.textColor
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

    // === ИНФОРМАЦИОННАЯ ПАНЕЛЬ ===
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        color: Theme.backgroundColor
        border.color: Theme.inputBorder
        border.width: 1
        radius: Theme.smallRadius

        AppLabel {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: "Всего товаров: " + listView.count
            level: "body"
            color: Theme.textSecondary
            enterDelay: 0
        }
    }
}
