// ImageFileDialog.qml - Диалог выбора изображения (УЛУЧШЕННАЯ ВЕРСИЯ с навигацией)
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: imageDialog
    title: "Выбор изображения"
    modal: true
    width: 500
    height: 350
    anchors.centerIn: parent

    // Перезагружаем config при открытии
    onAboutToShow: {
        console.log("ImageFileDialog opening, reloading config...")
        if (configManager) {
            configManager.reloadConfig()
        }
        updateCategories()
    }

    signal imageSelected(string relativePath, string subdirectory)

    property string selectedSubdirectory: "other"

    // Функция обновления списка категорий
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

    // НОВОЕ: Функция для получения пути к выбранной директории
    function getSelectedDirectoryPath() {
        if (!fileManager) {
            console.warn("FileManager is not available")
            return ""
        }

        // Получаем корневую директорию images
        var imagesRoot = fileManager.get_images_root_path()

        // Добавляем поддиректорию
        if (selectedSubdirectory && selectedSubdirectory !== "") {
            // Получаем настройки из конфига
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

    // Обновляем при открытии диалога
    onOpened: {
        updateCategories()
    }

    // Также обновляем при первой загрузке
    Component.onCompleted: {
        updateCategories()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Выбор категории изображения
        GroupBox {
            title: "Категория изображения"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                ComboBox {
                    id: subdirComboBox
                    Layout.fillWidth: true
                    model: []  // Будет заполнена динамически

                    onCurrentIndexChanged: {
                        if (configManager && currentIndex >= 0) {
                            var subdirs = configManager.getImageSubdirectories()
                            if (currentIndex < subdirs.length) {
                                selectedSubdirectory = subdirs[currentIndex].id
                                console.log("Selected image subdirectory:", selectedSubdirectory)
                            }
                        }
                    }

                    background: Rectangle {
                        color: "white"
                        border.color: subdirComboBox.activeFocus ? "#2196F3" : "#d0d0d0"
                        border.width: subdirComboBox.activeFocus ? 2 : 1
                        radius: 4
                    }
                }

                Text {
                    text: "Выберите категорию для лучшей организации файлов"
                    font.pointSize: 8
                    color: "#666"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        // Кнопка выбора файла
        Button {
            text: "📁 Выбрать файл..."
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            onClicked: {
                // НОВОЕ: Устанавливаем текущую директорию перед открытием
                var dirPath = getSelectedDirectoryPath()
                if (dirPath !== "") {
                    fileDialogInternal.currentFolder = dirPath
                }
                fileDialogInternal.open()
            }

            background: Rectangle {
                color: parent.down ? "#1976D2" : (parent.hovered ? "#42A5F5" : "#2196F3")
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                font.pointSize: 10
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            text: "Поддерживаемые форматы: JPG, JPEG, PNG, BMP"
            font.pointSize: 8
            color: "#999"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Внутренний FileDialog для выбора файла
    FileDialog {
        id: fileDialogInternal
        title: "Выберите изображение"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp)"]
        // currentFolder будет установлена программно перед открытием

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

    footer: DialogButtonBox {
        Button {
            text: "Отмена"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            onClicked: imageDialog.close()

            background: Rectangle {
                color: parent.down ? "#5a6268" : (parent.hovered ? "#6c757d" : "#f5f5f5")
                border.color: "#d0d0d0"
                border.width: 1
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                color: parent.parent.down || parent.parent.hovered ? "white" : "#333"
                font: parent.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}