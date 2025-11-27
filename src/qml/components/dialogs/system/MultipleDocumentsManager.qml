// MultipleDocumentsManager.qml - Компонент для управления документами товара
// РЕФАКТОРИНГ: Использует Theme для стилизации
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// === ИМПОРТЫ ДЛЯ ТЕМЫ И КОМПОНЕНТОВ ===
import "../../../styles"
import "../../common"

GroupBox {
    id: root
    title: "📄 Документы"

    // === СВОЙСТВА ===
    property var documentsModel: null
    property string currentArticle: ""
    property var parentDialog: null

    // === СИГНАЛЫ ===
    signal documentOpened(string documentPath)

    Layout.fillWidth: true
    Layout.preferredHeight: 220

    Component.onCompleted: {
        console.log("=== MultipleDocumentsManager CREATED ===")
        console.log("documentsModel:", documentsModel ? "exists" : "null")
        console.log("currentArticle:", currentArticle)
        console.log("============================================")
    }

    // === СТИЛЬ GROUPBOX ===
    background: Rectangle {
        y: root.topPadding - root.bottomPadding
        width: parent.width
        height: parent.height - root.topPadding + root.bottomPadding
        color: "white"
        radius: Theme.smallRadius
        border.color: Theme.inputBorder
        border.width: 1
    }

    label: AppLabel {
        x: root.leftPadding
        text: root.title
        level: "h3"
        enterDelay: 0
    }

    // === ОБРАБОТЧИК ИЗМЕНЕНИЯ МОДЕЛИ ===
    Connections {
        target: documentsModel

        // Сигнал после загрузки документов
        function onDocumentsLoaded(count) {
            console.log("=== onDocumentsLoaded ===")
            console.log("count:", count)
            console.log("documentsComboBox.currentIndex BEFORE:", documentsComboBox.currentIndex)

            if (count > 0 && documentsComboBox.currentIndex < 0) {
                documentsComboBox.currentIndex = 0
                console.log("Auto-selected first document, currentIndex AFTER:", documentsComboBox.currentIndex)
            } else if (count === 0) {
                documentsComboBox.currentIndex = -1
            }
            console.log("======================")
        }

        // Сигнал после добавления документа
        function onDocumentAdded() {
            console.log("=== onDocumentAdded ===")
            console.log("documentsModel.count():", documentsModel ? documentsModel.count() : "null")
            // После добавления выбираем последний добавленный (или первый если был пустой)
            if (documentsModel && documentsModel.count() > 0) {
                documentsComboBox.currentIndex = documentsModel.count() - 1
                console.log("Selected last document, currentIndex:", documentsComboBox.currentIndex)
            }
            console.log("======================")
        }

        // Сигнал после удаления документа
        function onDocumentDeleted() {
            console.log("=== onDocumentDeleted ===")
            console.log("documentsModel.count():", documentsModel ? documentsModel.count() : "null")
            // После удаления корректируем индекс
            if (documentsModel && documentsModel.count() > 0) {
                if (documentsComboBox.currentIndex >= documentsModel.count()) {
                    documentsComboBox.currentIndex = documentsModel.count() - 1
                } else if (documentsComboBox.currentIndex < 0) {
                    documentsComboBox.currentIndex = 0
                }
            } else {
                documentsComboBox.currentIndex = -1
            }
            console.log("currentIndex AFTER:", documentsComboBox.currentIndex)
            console.log("======================")
        }
    }

    // Отладка изменения currentIndex
    Connections {
        target: documentsComboBox
        function onCurrentIndexChanged() {
            console.log(">>> ComboBox currentIndex changed to:", documentsComboBox.currentIndex)
            console.log(">>> Delete button should be enabled:",
                documentsModel && documentsModel.count() > 0 && documentsComboBox.currentIndex >= 0)
        }
    }

    // === ДИАЛОГ ВЫБОРА ДОКУМЕНТА ===
    DocumentFileDialog {
        id: documentDialog
        onDocumentSelected: function(relativePath, subdirectory) {
            console.log("Document selected:", relativePath)

            if (!documentsModel) {
                console.error("documentsModel is null!")
                return
            }

            if (!currentArticle || currentArticle === "") {
                console.error("currentArticle is empty!")
                return
            }

            var fileName = fileManager ? fileManager.get_file_name(relativePath) : relativePath
            var result = documentsModel.addDocument(relativePath, fileName)
            console.log("addDocument result:", result)
        }
    }

    // === ДИАЛОГ ПОДТВЕРЖДЕНИЯ УДАЛЕНИЯ ===
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
                font: Theme.defaultFont
                color: Theme.textColor
            }

            Text {
                text: "Файл будет удален из списка документов товара."
                font: Theme.smallFont
                color: Theme.textSecondary
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
                    color: parent.down ? Qt.darker(Theme.errorColor, 1.3)
                         : (parent.hovered ? Qt.lighter(Theme.errorColor, 1.1) : Theme.errorColor)
                    radius: Theme.smallRadius
                }

                contentItem: Text {
                    text: parent.text
                    color: Theme.textOnPrimary
                    font: Theme.defaultFont
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
                    border.color: Theme.inputBorder
                    border.width: 1
                    radius: Theme.smallRadius
                }

                contentItem: Text {
                    text: parent.text
                    color: Theme.textColor
                    font: Theme.defaultFont
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // --- ПАНЕЛЬ УПРАВЛЕНИЯ ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // ComboBox для выбора документа
            AppComboBox {
                id: documentsComboBox
                Layout.fillWidth: true

                model: documentsModel
                textRole: "name"

                displayText: currentIndex >= 0 ? currentText : "Нет документов"
                enabled: documentsModel && documentsModel.count() > 0

                Component.onCompleted: {
                    console.log(">>> AppComboBox CREATED, currentIndex:", currentIndex)
                }

                onModelChanged: {
                    console.log(">>> AppComboBox model changed, currentIndex:", currentIndex)
                }

                delegate: ItemDelegate {
                    width: documentsComboBox.width

                    contentItem: Text {
                        text: model.name
                        font: Theme.defaultFont
                        color: documentsComboBox.highlightedIndex === index ? Theme.textOnPrimary : Theme.textColor
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: documentsComboBox.highlightedIndex === index ? Theme.accentColor : "white"
                    }
                }
            }

            // Кнопка добавления документа
            Button {
                text: "➕"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                ToolTip.visible: hovered
                ToolTip.text: "Добавить документ"

                onClicked: {
                    console.log("Add document clicked, currentArticle:", currentArticle)

                    if (!currentArticle || currentArticle === "") {
                        if (parentDialog && parentDialog.autoSaveItem) {
                            var saved = parentDialog.autoSaveItem()
                            if (!saved) {
                                console.error("Failed to auto-save item")
                                return
                            }
                        } else {
                            console.error("parentDialog or autoSaveItem not available")
                            return
                        }
                    }

                    documentDialog.open()
                }

                background: Rectangle {
                    color: parent.down ? Qt.darker(Theme.successColor, 1.3)
                         : (parent.hovered ? Qt.lighter(Theme.successColor, 1.1) : "#e8f5e9")
                    border.color: Theme.successColor
                    border.width: 1
                    radius: Theme.smallRadius
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: Theme.successColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Кнопка удаления документа
            Button {
                id: deleteBtn
                text: "🗑️"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                ToolTip.visible: hovered
                ToolTip.text: "Удалить документ"

                enabled: documentsModel && documentsModel.count() > 0 && documentsComboBox.currentIndex >= 0

                // Отладка состояния кнопки
                onEnabledChanged: {
                    console.log(">>> DELETE BUTTON enabled changed to:", enabled)
                    console.log("    documentsModel:", documentsModel ? "exists" : "null")
                    console.log("    count:", documentsModel ? documentsModel.count() : "N/A")
                    console.log("    currentIndex:", documentsComboBox.currentIndex)
                }

                onClicked: {
                    console.log("Delete clicked, currentIndex:", documentsComboBox.currentIndex)
                    deleteConfirmDialog.documentIndex = documentsComboBox.currentIndex
                    deleteConfirmDialog.open()
                }

                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#f5f5f5"
                        if (parent.down) return Qt.darker(Theme.errorColor, 1.3)
                        if (parent.hovered) return Qt.lighter(Theme.errorColor, 1.1)
                        return "#ffebee"
                    }
                    border.color: parent.enabled ? Theme.errorColor : Theme.inputBorder
                    border.width: 1
                    radius: Theme.smallRadius
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: parent.enabled ? Theme.errorColor : Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // --- СПИСОК ДОКУМЕНТОВ ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.backgroundColor
            border.color: Theme.inputBorder
            border.width: 1
            radius: Theme.smallRadius

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
                        color: mouseArea.containsMouse ? Qt.lighter(Theme.accentColor, 1.8) : "white"
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

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
                                font.pixelSize: 14
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.name || "Без названия"
                                    font: Theme.boldFont
                                    color: Theme.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Добавлено: " + (model.date || "")
                                    font: Theme.smallFont
                                    color: Theme.textSecondary
                                }
                            }
                        }
                    }

                    // Текст когда нет документов
                    Label {
                        visible: documentsListView.count === 0
                        anchors.centerIn: parent
                        text: "Нет прикрепленных документов"
                        font: Theme.defaultFont
                        color: Theme.textSecondary
                    }
                }
            }
        }

        // --- ИНФОРМАЦИОННАЯ ПОДСКАЗКА ---
        AppLabel {
            text: documentsModel && documentsModel.count() > 0
                  ? "Всего документов: " + documentsModel.count()
                  : "Нажмите ➕ чтобы добавить документ"
            level: "caption"
            Layout.alignment: Qt.AlignRight
            enterDelay: 0
        }
    }

    // === ФУНКЦИИ ===
    function loadDocuments(article) {
        console.log("=== loadDocuments START ===")
        console.log("article:", article)

        currentArticle = article
        if (documentsModel) {
            // Сбрасываем индекс перед загрузкой
            documentsComboBox.currentIndex = -1

            documentsModel.loadDocuments(article)
            // Сигнал onDocumentsLoaded автоматически установит правильный индекс
        }
        console.log("=== loadDocuments END ===")
    }

    function clearDocuments() {
        console.log("clearDocuments called")
        currentArticle = ""
        documentsComboBox.currentIndex = -1
        if (documentsModel) {
            documentsModel.clear()
        }
    }
}
