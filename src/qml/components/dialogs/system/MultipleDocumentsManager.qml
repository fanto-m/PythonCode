// MultipleDocumentsManager.qml - Компонент для управления документами товара
// РЕФАКТОРИНГ: Использует Theme для стилизации
// ИСПРАВЛЕНО: Проблема с неактивной кнопкой удаления при одном документе
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
    property bool canDelete: false  // Явное свойство для кнопки удаления

    // === СИГНАЛЫ ===
    signal documentOpened(string documentPath)

    Layout.fillWidth: true
    Layout.preferredHeight: 440  // Увеличено в 2 раза для большего списка файлов

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

            // ИСПРАВЛЕНИЕ: Принудительно сбрасываем ComboBox ПОСЛЕ загрузки
            // Используем Qt.callLater чтобы дать модели время обновиться
            Qt.callLater(function() {
                documentsComboBox.currentIndex = -1
                canDelete = false
                console.log("ComboBox reset to -1, canDelete = false")
            })

            console.log("Documents loaded, waiting for user selection")
            console.log("======================")
        }

        // Сигнал после добавления документа
        function onDocumentAdded() {
            console.log("=== onDocumentAdded ===")
            // После добавления выбираем добавленный документ
            if (documentsModel && documentsModel.count() > 0) {
                // Используем Qt.callLater для корректной установки после обновления модели
                Qt.callLater(function() {
                    documentsComboBox.currentIndex = documentsModel.count() - 1
                    canDelete = true  // Явно устанавливаем, т.к. выбрали документ
                    console.log("Selected newly added document at index:", documentsModel.count() - 1)
                })
            }
            console.log("======================")
        }

        // Сигнал после удаления документа
        function onDocumentDeleted() {
            console.log("=== onDocumentDeleted ===")
            var count = documentsModel ? documentsModel.count() : 0
            console.log("Remaining documents:", count)

            // После удаления сбрасываем выбор - пользователь должен выбрать снова
            Qt.callLater(function() {
                documentsComboBox.currentIndex = -1
                canDelete = false
                console.log("After delete: ComboBox reset to -1, canDelete = false")
            })
            console.log("======================")
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

            AppLabel {
                text: "Вы уверены, что хотите удалить этот документ?"
                level: "body"
                enterDelay: 0
            }

            AppLabel {
                text: "Файл будет удален из списка документов товара."
                level: "caption"
                enterDelay: 0
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
                    color: parent.down ? "#d0d0d0" : (parent.hovered ? "#eeeeee" : "#f5f5f5")
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

                displayText: currentIndex >= 0 ? currentText : "Выберите документ..."
                enabled: documentsModel && documentsModel.count() > 0

                // Когда пользователь выбирает документ - разблокируем кнопку удаления
                onCurrentIndexChanged: {
                    console.log(">>> ComboBox onCurrentIndexChanged:", currentIndex)
                    // ИСПРАВЛЕНИЕ: Проверяем что индекс валидный И модель не пустая
                    if (currentIndex >= 0 && documentsModel && documentsModel.count() > 0) {
                        canDelete = true
                        console.log("canDelete set to TRUE")
                    } else {
                        canDelete = false
                        console.log("canDelete set to FALSE")
                    }
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
            AppButton {
                text: "➕"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                btnColor: Theme.successColor
                enterDelay: 0

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
            }

            // Кнопка удаления документа
            AppButton {
                id: deleteBtn
                text: "🗑️"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                btnColor: Theme.errorColor
                enterDelay: 0

                enabled: canDelete
                opacity: enabled ? 1.0 : 0.5

                ToolTip.visible: hovered
                ToolTip.text: "Удалить документ"

                onClicked: {
                    console.log("Delete clicked, currentIndex:", documentsComboBox.currentIndex)
                    console.log("canDelete:", canDelete)
                    if (documentsComboBox.currentIndex >= 0) {
                        deleteConfirmDialog.documentIndex = documentsComboBox.currentIndex
                        deleteConfirmDialog.open()
                    }
                }

                // Явно задаём белый цвет текста для видимости на красном фоне
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
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
                        height: 32  // Уменьшенная высота для одной строки
                        // Выделяем выбранный элемент
                        color: documentsComboBox.currentIndex === index
                               ? Qt.lighter(Theme.accentColor, 1.5)
                               : (mouseArea.containsMouse ? Qt.lighter(Theme.accentColor, 1.8) : "white")
                        border.color: documentsComboBox.currentIndex === index ? Theme.accentColor : Theme.inputBorder
                        border.width: documentsComboBox.currentIndex === index ? 2 : 1
                        radius: Theme.smallRadius

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // ИСПРАВЛЕНИЕ: Явно устанавливаем canDelete при клике на элемент списка
                                documentsComboBox.currentIndex = index
                                canDelete = true  // Явно активируем кнопку удаления
                                console.log("ListView item clicked, set currentIndex:", index, "canDelete:", true)
                            }

                            onDoubleClicked: {
                                if (fileManager) {
                                    fileManager.open_file_externally(model.path)
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            Text {
                                text: "📄"
                                font.pixelSize: 12
                            }

                            // Название файла
                            Text {
                                text: model.name || "Без названия"
                                font.family: Theme.defaultFont.family
                                font.pixelSize: Theme.sizeCaption
                                font.bold: true
                                color: Theme.textColor
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Дата добавления справа
                            Text {
                                text: model.date || ""
                                font: Theme.smallFont
                                color: Theme.textSecondary
                                Layout.alignment: Qt.AlignRight
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
        console.log("=== loadDocuments ===")
        console.log("article:", article)

        currentArticle = article

        // ИСПРАВЛЕНИЕ: Сбрасываем состояние ДО загрузки
        canDelete = false
        documentsComboBox.currentIndex = -1

        if (documentsModel) {
            documentsModel.loadDocuments(article)
        }
        console.log("=====================")
    }

    function clearDocuments() {
        console.log("clearDocuments called")
        currentArticle = ""
        documentsComboBox.currentIndex = -1
        canDelete = false
        if (documentsModel) {
            documentsModel.clear()
        }
    }
}
