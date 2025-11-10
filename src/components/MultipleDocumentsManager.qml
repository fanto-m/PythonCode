// MultipleDocumentsManager.qml - Компонент для управления документами товара
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GroupBox {
    id: root
    title: "📄 Документы"

    // Свойства
    property var documentsModel: null
    property string currentArticle: ""
    property var parentDialog: null  // НОВОЕ: Прямая ссылка на ProductCardDialog

    signal documentOpened(string documentPath)

    // Цвета темы
    readonly property color primaryColor: "#2196F3"
    readonly property color errorColor: "#f44336"
    readonly property color successColor: "#4caf50"
    readonly property color borderColor: "#e0e0e0"

    Layout.fillWidth: true
    Layout.preferredHeight: 220

    // Диалог выбора документа
    DocumentFileDialog {
        id: documentDialog
        onDocumentSelected: function(relativePath, subdirectory) {
            console.log("==================================================")
            console.log("STEP 9: DOCUMENT SELECTED")
            console.log("relativePath:", relativePath)
            console.log("subdirectory:", subdirectory)
            console.log("currentArticle:", currentArticle)
            console.log("documentsModel:", documentsModel)
            console.log("documentsModel.count() BEFORE:", documentsModel ? documentsModel.count() : "null")
            console.log("==================================================")

            if (!documentsModel) {
                console.error("STEP 10 ERROR: documentsModel is null!")
                return
            }

            if (!currentArticle || currentArticle === "") {
                console.error("STEP 10 ERROR: currentArticle is empty!")
                return
            }

            var fileName = fileManager ? fileManager.get_file_name(relativePath) : relativePath
            console.log("STEP 11: fileName:", fileName)
            console.log("STEP 12: Calling documentsModel.addDocument...")

            var result = documentsModel.addDocument(relativePath, fileName)

            console.log("==================================================")
            console.log("STEP 13: addDocument result:", result)
            console.log("documentsModel.count() AFTER:", documentsModel ? documentsModel.count() : "null")
            console.log("==================================================")
        }
    }

    // Диалог подтверждения удаления
    Dialog {
        id: deleteConfirmDialog
        title: "Подтверждение удаления"
        modal: true
        anchors.centerIn: parent

        property int documentIndex: -1

        ColumnLayout {
            spacing: 10

            Text {
                text: "Вы уверены, что хотите удалить этот документ?"
                font.pointSize: 10
            }

            Text {
                text: "Файл будет удален из списка документов товара."
                font.pointSize: 8
                color: "#666"
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "Удалить"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                onClicked: {
                    if (documentsModel) {
                        documentsModel.deleteDocument(deleteConfirmDialog.documentIndex)
                    }
                    deleteConfirmDialog.close()
                }

                background: Rectangle {
                    color: parent.down ? Qt.darker(errorColor, 1.3) : (parent.hovered ? Qt.lighter(errorColor, 1.1) : errorColor)
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

            Button {
                text: "Отмена"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                onClicked: deleteConfirmDialog.close()

                background: Rectangle {
                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
                    border.color: borderColor
                    border.width: 1
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "#333"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Панель управления
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // ComboBox для выбора документа
            ComboBox {
                id: documentsComboBox
                Layout.fillWidth: true

                model: documentsModel
                textRole: "name"

                displayText: currentIndex >= 0 ? currentText : "Нет документов"

                enabled: documentsModel && documentsModel.count() > 0

                background: Rectangle {
                    color: "white"
                    border.color: documentsComboBox.activeFocus ? primaryColor : borderColor
                    border.width: documentsComboBox.activeFocus ? 2 : 1
                    radius: 4
                }

                delegate: ItemDelegate {
                    width: documentsComboBox.width

                    contentItem: Text {
                        text: model.name
                        font: documentsComboBox.font
                        color: documentsComboBox.highlightedIndex === index ? "white" : "#333"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: documentsComboBox.highlightedIndex === index ? primaryColor : "white"
                    }
                }
            }

            // Кнопка добавления документа
            Button {
                text: "➕"
                Layout.preferredWidth: 40
                ToolTip.visible: hovered
                ToolTip.text: "Добавить документ"

                onClicked: {
                    console.log("==================================================")
                    console.log("STEP 1: Add document button clicked")
                    console.log("currentArticle:", currentArticle)
                    console.log("documentsModel:", documentsModel)
                    console.log("documentsModel.count():", documentsModel ? documentsModel.count() : "null")
                    console.log("parentDialog:", parentDialog)
                    console.log("==================================================")

                    // Проверяем нужно ли сохранить товар
                    if (!currentArticle || currentArticle === "") {
                        console.log("STEP 2: No article, attempting auto-save...")

                        if (parentDialog && parentDialog.autoSaveItem) {
                            console.log("STEP 3: Calling parentDialog.autoSaveItem()")
                            var saved = parentDialog.autoSaveItem()
                            console.log("STEP 4: Auto-save result:", saved)

                            if (!saved) {
                                console.error("STEP 5: Failed to auto-save item - STOPPING")
                                return
                            }
                            console.log("STEP 6: Item auto-saved successfully")
                            console.log("STEP 6a: currentArticle after save:", currentArticle)
                        } else {
                            console.error("STEP 5 ERROR: parentDialog or autoSaveItem not available")
                            return
                        }
                    } else {
                        console.log("STEP 2: Article already exists:", currentArticle)
                    }

                    console.log("STEP 7: Opening document dialog...")
                    console.log("STEP 7a: currentArticle before opening dialog:", currentArticle)
                    documentDialog.open()
                    console.log("STEP 8: Document dialog opened")
                    console.log("==================================================")
                }

                background: Rectangle {
                    color: parent.down ? Qt.darker(successColor, 1.3) : (parent.hovered ? Qt.lighter(successColor, 1.1) : "#e8f5e9")
                    border.color: successColor
                    border.width: 1
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    font.pointSize: 10
                    color: successColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Кнопка удаления документа
            Button {
                text: "🗑️"
                Layout.preferredWidth: 40
                ToolTip.visible: hovered
                ToolTip.text: "Удалить документ"

                enabled: documentsModel && documentsModel.count() > 0 && documentsComboBox.currentIndex >= 0

                onClicked: {
                    deleteConfirmDialog.documentIndex = documentsComboBox.currentIndex
                    deleteConfirmDialog.open()
                }

                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#f5f5f5"
                        if (parent.down) return Qt.darker(errorColor, 1.3)
                        if (parent.hovered) return Qt.lighter(errorColor, 1.1)
                        return "#ffebee"
                    }
                    border.color: parent.enabled ? errorColor : borderColor
                    border.width: 1
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    font.pointSize: 10
                    color: parent.enabled ? errorColor : "#999"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Список документов
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#fafafa"
            border.color: borderColor
            border.width: 1
            radius: 4

            ScrollView {
                anchors.fill: parent
                anchors.margins: 4
                clip: true

                ListView {
                    id: documentsListView
                    model: documentsModel
                    spacing: 4

                    delegate: Rectangle {
                        width: documentsListView.width
                        height: 40
                        color: mouseArea.containsMouse ? "#e3f2fd" : "white"
                        border.color: borderColor
                        border.width: 1
                        radius: 4

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onDoubleClicked: {
                                if (fileManager) {
                                    fileManager.open_file_externally(model.path)
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                text: "📄"
                                font.pointSize: 12
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.name || "Без названия"
                                    font.pointSize: 9
                                    font.bold: true
                                    color: "#333"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Добавлено: " + (model.date || "")
                                    font.pointSize: 7
                                    color: "#666"
                                }
                            }
                        }
                    }

                    // Текст когда нет документов
                    Label {
                        visible: documentsListView.count === 0
                        anchors.centerIn: parent
                        text: "Нет прикрепленных документов"
                        font.pointSize: 9
                        color: "#999"
                    }
                }
            }
        }

        // Информационная подсказка
        Text {
            text: documentsModel && documentsModel.count() > 0
                  ? `Всего документов: ${documentsModel.count()}`
                  : "Нажмите ➕ чтобы добавить документ"
            font.pointSize: 8
            color: "#666"
            Layout.alignment: Qt.AlignRight
        }
    }

    // Функции
    function loadDocuments(article) {
        currentArticle = article
        if (documentsModel) {
            documentsModel.loadDocuments(article)
        }
    }

    function clearDocuments() {
        currentArticle = ""
        if (documentsModel) {
            documentsModel.clear()
        }
        documentsComboBox.currentIndex = -1
    }
}
