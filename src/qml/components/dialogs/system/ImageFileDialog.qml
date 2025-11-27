// ImageFileDialog.qml - Диалог выбора изображения
// РЕФАКТОРИНГ: Использует кастомные компоненты и Theme
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

// === ИМПОРТЫ ДЛЯ ТЕМЫ И КОМПОНЕНТОВ ===
// Путь зависит от расположения файла в проекте.
// Если файл в qml/components/dialogs/items/:
import "../../../styles"
import "../../common"

Dialog {
    id: imageDialog
    title: "Выбор изображения"
    modal: true
    width: 520
    height: 380

    // Убираем стандартный заголовок диалога
    header: Item {}

    // === СИГНАЛЫ И СВОЙСТВА ===
    signal imageSelected(string relativePath, string subdirectory)
    property string selectedSubdirectory: "other"

    // === ПОЗИЦИОНИРОВАНИЕ ===
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // === ПЕРЕЗАГРУЗКА КОНФИГА ПРИ ОТКРЫТИИ ===
    onAboutToShow: {
        console.log("ImageFileDialog opening, reloading config...")
        if (configManager) {
            configManager.reloadConfig()
        }
        updateCategories()
    }

    onOpened: {
        updateCategories()
    }

    Component.onCompleted: {
        updateCategories()
    }

    // === ФУНКЦИИ ===
    function updateCategories() {
        console.log("=== Updating image categories ===")

        if (!configManager) {
            console.error("ConfigManager is not available")
            return
        }

        var subdirs = configManager.getImageSubdirectories()
        console.log("Found", subdirs.length, "image subdirectories from config")

        var modelList = []

        for (var i = 0; i < subdirs.length; i++) {
            console.log("  - Adding:", subdirs[i].display_name, "(", subdirs[i].id, ")")
            modelList.push(subdirs[i].display_name + " (" + subdirs[i].id + ")")
        }

        subdirComboBox.model = modelList

        // Находим индекс "other" для установки по умолчанию
        for (var j = 0; j < subdirs.length; j++) {
            if (subdirs[j].id === "other") {
                subdirComboBox.currentIndex = j
                selectedSubdirectory = "other"
                break
            }
        }

        console.log("Image categories updated:", modelList.length, "categories")
        console.log("=================================")
    }

    function getSelectedDirectoryPath() {
        if (!fileManager) {
            console.warn("FileManager is not available")
            return ""
        }

        var imagesRoot = fileManager.get_images_root_path()

        if (selectedSubdirectory && selectedSubdirectory !== "") {
            var subdirs = configManager.getImageSubdirectories()
            for (var i = 0; i < subdirs.length; i++) {
                if (subdirs[i].id === selectedSubdirectory) {
                    var subdirName = subdirs[i].name
                    var fullPath = imagesRoot + "/" + subdirName
                    console.log("Opening directory:", fullPath)
                    return "file:///" + fullPath
                }
            }
        }

        return "file:///" + imagesRoot
    }

    // === ФОН ДИАЛОГА ===

    background: Rectangle {
        color: Theme.backgroundColor
        radius: Theme.defaultRadius
        border.color: Theme.inputBorderFocus
        border.width: 2
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    contentItem: ColumnLayout {
        spacing: 0

        // --- КАСТОМНЫЙ ЗАГОЛОВОК (перетаскиваемый) ---
        Rectangle {
            id: headerBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Theme.accentColor
            radius: Theme.defaultRadius

            // Скругляем только верхние углы
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }

            // Заголовок
            AppLabel {
                anchors.centerIn: parent
                text: "🖼️ Выбор изображения"
                level: "h3"
                color: Theme.textOnPrimary
                enterDelay: 100
            }

            // Кнопка закрытия
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                text: "✕"
                font.pixelSize: 18
                font.bold: true
                color: closeHover.containsMouse ? "#ffcccc" : Theme.textOnPrimary

                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    anchors.margins: -5
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: imageDialog.reject()
                }
            }

            // Перетаскивание окна
            MouseArea {
                id: dragArea
                anchors.fill: parent
                anchors.rightMargin: 50 // Оставляем место для кнопки закрытия
                cursorShape: Qt.OpenHandCursor
                property point lastMousePos

                onPressed: {
                    lastMousePos = Qt.point(mouseX, mouseY)
                    cursorShape = Qt.ClosedHandCursor
                }

                onReleased: {
                    cursorShape = Qt.OpenHandCursor
                }

                onMouseXChanged: {
                    if (pressed) {
                        imageDialog.x += mouseX - lastMousePos.x
                    }
                }

                onMouseYChanged: {
                    if (pressed) {
                        imageDialog.y += mouseY - lastMousePos.y
                    }
                }
            }
        }

        // --- ОСНОВНАЯ ОБЛАСТЬ ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: 20

            // --- СЕКЦИЯ: Категория изображения ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: categoryContent.implicitHeight + 30
                color: "white"
                radius: Theme.smallRadius
                border.color: Theme.inputBorder
                border.width: 1

                ColumnLayout {
                    id: categoryContent
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    AppLabel {
                        text: "Категория изображения"
                        level: "h3"
                        enterDelay: 150
                    }

                    AppComboBox {
                        id: subdirComboBox
                        Layout.fillWidth: true
                        model: []

                        onCurrentIndexChanged: {
                            if (configManager && currentIndex >= 0) {
                                var subdirs = configManager.getImageSubdirectories()
                                if (currentIndex < subdirs.length) {
                                    selectedSubdirectory = subdirs[currentIndex].id
                                    console.log("Selected image subdirectory:", selectedSubdirectory)
                                }
                            }
                        }
                    }

                    AppLabel {
                        text: "Выберите категорию для лучшей организации файлов"
                        level: "caption"
                        enterDelay: 250
                        Layout.fillWidth: true
                    }
                }
            }

            // --- КНОПКА ВЫБОРА ФАЙЛА ---
            AppButton {
                id: selectFileBtn
                text: "📁 Выбрать файл..."
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                btnColor: Theme.primaryColor
                enterDelay: 300

                onClicked: {
                    var dirPath = getSelectedDirectoryPath()
                    if (dirPath !== "") {
                        fileDialogInternal.currentFolder = dirPath
                    }
                    fileDialogInternal.open()
                }
            }

            // --- ПОДСКАЗКА О ФОРМАТАХ ---
            AppLabel {
                text: "Поддерживаемые форматы: JPG, JPEG, PNG, BMP"
                level: "caption"
                Layout.alignment: Qt.AlignHCenter
                enterDelay: 350
            }

            // Растягиваем пространство
            Item {
                Layout.fillHeight: true
            }

            // --- КНОПКА ОТМЕНЫ ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.fillWidth: true }

                AppButton {
                    id: cancelBtn
                    text: "Отмена"
                    Layout.preferredWidth: 120
                    btnColor: "#6c757d"
                    enterDelay: 400

                    onClicked: imageDialog.reject()
                }
            }
        }
    }

    // === ВНУТРЕННИЙ FILEDIALOG ===
    FileDialog {
        id: fileDialogInternal
        title: "Выберите изображение"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp)"]

        onAccepted: {
            var fileUrl = selectedFile.toString()
            var localPath = fileUrl.replace(/^file:\/\/\//, "")

            // Для Windows убираем лишний слеш в начале
            if (Qt.platform.os === "windows" && localPath.startsWith("/")) {
                localPath = localPath.substring(1)
            }

            // Вызываем FileManager для копирования файла
            if (fileManager) {
                var relativePath = fileManager.copy_image_to_storage(localPath, selectedSubdirectory)
                if (relativePath) {
                    imageSelected(relativePath, selectedSubdirectory)
                    imageDialog.close()
                } else {
                    console.error("Failed to copy image to storage")
                }
            } else {
                console.error("FileManager is not available")
            }
        }
    }

    // Убираем стандартный footer
    footer: Item {}
}
