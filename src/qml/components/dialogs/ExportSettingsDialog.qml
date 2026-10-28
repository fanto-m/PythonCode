// ExportSettingsDialog.qml
// Расположение: src/qml/components/dialogs/ExportSettingsDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform
import "../../styles"
import "../common" as Common

Dialog {
    id: exportDialog
    title: "Настройки экспорта в Excel"
    modal: true
    width: 720
    height: 640



    parent: Overlay.overlay
    anchors.centerIn: parent

    // Путь к выбранному файлу шаблона (пусто = без шаблона)
    property string templatePath: ""

    // Все доступные столбцы в нужном порядке
    readonly property var availableColumns: [
        "№",
        "Название",
        "Артикул",
        "Производитель",
        "Кол-во",
        "Ед.",
        "Цена без НДС",
        "Сумма без НДС",
        "Примечание"
    ]

    // Состояние выбранных столбцов и категорий
    property var selectedColumnsMap: ({})
    property var selectedCategoriesMap: ({})
    // Счетчик-триггер для реактивного обновления CheckBox без сброса прокрутки ListView
    property int selectionRevision: 0

    // === ФУНКЦИИ УПРАВЛЕНИЯ ВЫБОРОМ ===

    function selectAllColumns() {
        let cols = {}
        for (let i = 0; i < availableColumns.length; i++) {
            cols[availableColumns[i]] = true
        }
        selectedColumnsMap = cols
        selectionRevision++
    }

    function clearAllColumns() {
        let cols = {}
        for (let i = 0; i < availableColumns.length; i++) {
            cols[availableColumns[i]] = false
        }
        selectedColumnsMap = cols
        selectionRevision++
    }

    function selectAllCategories() {
        let cats = {}
        if (typeof categoryModel !== "undefined" && categoryModel) {
            let count = categoryModel.rowCount ? categoryModel.rowCount() : (categoryModel.count || 0)
            for (let i = 0; i < count; i++) {
                let name = ""
                if (categoryModel.get) {
                    let item = categoryModel.get(i)
                    name = item ? (item.name || "") : ""
                }
                if (name !== "") {
                    cats[name] = true
                }
            }
        }
        // Дополнительно отмечаем флаг "все выбраны", если модель не поддерживает get(i)
        selectedCategoriesMap = cats
        allCategoriesForceChecked = true
        selectionRevision++
    }

    function clearAllCategories() {
        selectedCategoriesMap = ({})
        allCategoriesForceChecked = false
        selectionRevision++
    }

    property bool allCategoriesForceChecked: false

    Component.onCompleted: {
        selectAllColumns()
    }

    background: Rectangle {
        color: Theme.backgroundColor
        border.color: Theme.accentColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    contentItem: ColumnLayout {
        spacing: 12
        anchors.fill: parent
        anchors.margins: 10

         // Прозрачный элемент для создания промежутка от title
        Item {
            implicitHeight: 15 // <--- Задает размер промежутка
        }
        // === ВЕРХНЯЯ ПАНЕЛЬ: ВЫБОР ШАБЛОНА EXCEL ===
        GroupBox {
            //title: "Шаблон таблицы Excel (необязательно)"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Common.AppTextField {
                        id: templateField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        readOnly: true
                        text: exportDialog.templatePath
                        placeholderText: "📄 Стандартная генерация (без шаблона)..."
                        enterDelay: 0
                    }

                    Common.AppButton {
                        text: "📂 Выбрать шаблон"
                        btnColor: Theme.primaryColor
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 38
                        enterDelay: 0
                        onClicked: templateFileDialog.open()
                    }

                    Common.AppButton {
                        text: "✖"
                        btnColor: Theme.errorColor
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 38
                        visible: exportDialog.templatePath !== ""
                        enterDelay: 0
                        ToolTip.visible: hovered
                        ToolTip.text: "Сбросить шаблон"
                        onClicked: exportDialog.templatePath = ""
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: exportDialog.templatePath !== ""
                          ? "💡 Оформление будет взято из выбранного шаблона (.xlsx)"
                          : "💡 Вы можете выбрать готовый .xlsx файл с вашей шапкой или маркерами {{article}}, {{name}}, {{price}} и др."
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                }
            }
        }

        // === ОСНОВНАЯ ПАНЕЛЬ: СТОЛБЦЫ И КАТЕГОРИИ ===
        RowLayout {
            spacing: 16
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ----------------------------------------------------
            // ЛЕВАЯ ПАНЕЛЬ: Управление столбцами
            // ----------------------------------------------------
            GroupBox {
                title: "Столбцы таблицы"
                Layout.fillHeight: true
                Layout.preferredWidth: 290

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Кнопки "Выбрать все" и "Очистить" для столбцов
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Common.AppButton {
                            text: "☑ Все"
                            btnColor: Theme.primaryColor
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            enterDelay: 0
                            onClicked: exportDialog.selectAllColumns()
                        }

                        Common.AppButton {
                            text: "☐ Очистить"
                            btnColor: Theme.textSecondary
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            enterDelay: 0
                            onClicked: exportDialog.clearAllColumns()
                        }
                    }

                    // Контейнер списка столбцов
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius

                        ListView {
                            id: columnsList
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            bottomMargin: 12
                            model: exportDialog.availableColumns

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }

                            delegate: CheckBox {
                                width: columnsList.width - 16
                                text: modelData
                                checked: {
                                    // Привязка к selectionRevision обновляет галочку без сброса скролла
                                    let _ = exportDialog.selectionRevision
                                    return exportDialog.selectedColumnsMap[modelData] !== false
                                }

                                onToggled: {
                                    exportDialog.selectedColumnsMap[modelData] = checked
                                    exportDialog.selectionRevision++
                                }
                            }
                        }
                    }
                }
            }

            // ----------------------------------------------------
            // ПРАВАЯ ПАНЕЛЬ: Фильтр по категориям
            // ----------------------------------------------------
            GroupBox {
                title: "Категории (пусто = все товары)"
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Кнопки "Выбрать все" и "Очистить" для категорий
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Common.AppButton {
                            text: "☑ Выбрать все"
                            btnColor: Theme.primaryColor
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            enterDelay: 0
                            onClicked: exportDialog.selectAllCategories()
                        }

                        Common.AppButton {
                            text: "☐ Очистить"
                            btnColor: Theme.textSecondary
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            enterDelay: 0
                            onClicked: exportDialog.clearAllCategories()
                        }
                    }

                    // Контейнер списка категорий с надежной прокруткой
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius

                        ListView {
                            id: categoriesList
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            // Отключаем отпружинивание назад у краев списка!
                            boundsBehavior: Flickable.StopAtBounds
                            // Запас снизу, чтобы последняя категория всегда была видна целиком
                            bottomMargin: 16
                            model: categoryModel

                            ScrollBar.vertical: ScrollBar {
                                id: catScrollBar
                                policy: ScrollBar.AlwaysOn
                            }

                            delegate: CheckBox {
                                width: categoriesList.width - catScrollBar.width - 8
                                property string catName: model.name !== undefined ? model.name : (modelData.name || "")
                                text: catName

                                checked: {
                                    let _ = exportDialog.selectionRevision
                                    if (exportDialog.selectedCategoriesMap[catName] !== undefined) {
                                        return exportDialog.selectedCategoriesMap[catName] === true
                                    }
                                    return exportDialog.allCategoriesForceChecked
                                }

                                onToggled: {
                                    if (exportDialog.allCategoriesForceChecked && !checked) {
                                        exportDialog.allCategoriesForceChecked = false
                                    }
                                    exportDialog.selectedCategoriesMap[catName] = checked
                                    exportDialog.selectionRevision++
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Диалог выбора файла ШАБЛОНА (.xlsx)
    Platform.FileDialog {
        id: templateFileDialog
        title: "Выберите файл шаблона Excel"
        fileMode: Platform.FileDialog.OpenFile
        nameFilters: ["Шаблоны Excel (*.xlsx)"]

        onAccepted: {
            exportDialog.templatePath = file.toString()
        }
    }

    // Системный диалог выбора пути СОХРАНЕНИЯ готового файла
    Platform.FileDialog {
        id: saveFileDialog
        title: "Сохранить список товаров в Excel"
        fileMode: Platform.FileDialog.SaveFile
        nameFilters: ["Excel files (*.xlsx)"]
        defaultSuffix: "xlsx"

        onAccepted: {
            // 1. Формируем упорядоченный список активных столбцов
            let activeColumns = []
            for (let i = 0; i < exportDialog.availableColumns.length; i++) {
                let colName = exportDialog.availableColumns[i]
                if (exportDialog.selectedColumnsMap[colName] !== false) {
                    activeColumns.push(colName)
                }
            }

            // 2. Формируем список выбранных категорий
            let selectedCategories = []
            if (!exportDialog.allCategoriesForceChecked) {
                for (let key in exportDialog.selectedCategoriesMap) {
                    if (exportDialog.selectedCategoriesMap[key] === true && key !== "") {
                        selectedCategories.push(key)
                    }
                }
            }
            // Примечание: если нажато "Выбрать все" (allCategoriesForceChecked == true),
            // передаем пустой массив selectedCategories = [], что в Python означает "выгрузить все категории"

            // 3. Вызываем слот в Python
            let targetModel = (typeof sourceModel !== "undefined") ? sourceModel : itemsModel
            let success = targetModel.exportToExcel(
                file.toString(),
                selectedCategories,
                activeColumns,
                exportDialog.templatePath
            )

            if (success) {
                if (typeof notificationDialog !== "undefined") {
                    notificationDialog.showSuccess("Таблица успешно выгружена в Excel!")
                }
                exportDialog.close()
            } else {
                if (typeof notificationDialog !== "undefined") {
                    notificationDialog.showError("Ошибка при экспорте в Excel (проверьте, не открыт ли файл)")
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Item {
        Layout.fillWidth: true
    }

        Common.AppButton {
            text: "Отмена"
            btnColor: Theme.textSecondary
            Layout.preferredWidth: 120
            Layout.preferredHeight: 38
            enterDelay: 0
            onClicked: exportDialog.close()
        }

        Common.AppButton {
            text: "Экспортировать"
            btnColor: "#27ae60"
            Layout.preferredWidth: 160
            Layout.preferredHeight: 38
            enterDelay: 0
            onClicked: saveFileDialog.open()
        }
    }
}