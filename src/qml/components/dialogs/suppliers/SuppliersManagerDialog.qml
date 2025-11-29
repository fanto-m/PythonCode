// SuppliersManagerDialog.qml - Диалог управления поставщиками
// Расположение: qml/components/dialogs/suppliers/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels
import QtQuick.Window
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: currentArticle === "" ? "Управление поставщиками" : "Привязка поставщиков к артикулу: " + currentArticle
    modal: true
    width: Math.min(Screen.width * 0.9, 1400)
    height: Math.min(Screen.height * 0.8, 900)
    anchors.centerIn: parent

    // === СВОЙСТВА ===
    property string currentArticle: ""
    property int selectedRow: -1
    property bool isLoading: false

    // Цвета для таблицы
    readonly property color selectedColor: "#fde3ee"
    readonly property color alternateRowColor: "#f5f5f5"
    readonly property color headerColor: "#e0e0e0"

    // Конфигурация колонок
    readonly property var columnConfig: [
        { proportion: 0.03, minWidth: 40, role: "checkbox" },
        { proportion: 0.03, minWidth: 40, role: "number" },
        { proportion: 0.21, minWidth: 120, role: "name" },
        { proportion: 0.21, minWidth: 120, role: "company" },
        { proportion: 0.21, minWidth: 140, role: "email" },
        { proportion: 0.17, minWidth: 100, role: "phone" },
        { proportion: 0.14, minWidth: 150, role: "website" }
    ]

    // === ЗАГОЛОВОК ===
    header: Item {
        height: 50

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 8
            color: "white"
            radius: Theme.smallRadius

            AppLabel {
                text: root.title
                level: "h3"
                anchors.centerIn: parent
                enterDelay: 0
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                height: 1
                color: Theme.inputBorder
            }
        }
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    contentItem: Rectangle {
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Keys.onPressed: function(event) {
                if (currentArticle !== "" || suppliersTable.rows === 0)
                    return

                if (event.key === Qt.Key_Up && selectedRow > 0) {
                    selectedRow--
                    event.accepted = true
                } else if (event.key === Qt.Key_Down && selectedRow < suppliersTable.rows - 1) {
                    selectedRow++
                    event.accepted = true
                }
            }

            // --- Панель поиска ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: currentArticle === ""

                AppTextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: "🔍 Поиск по имени, компании, email..."
                    enterDelay: 0

                    onTextChanged: {
                        suppliersTableModel.setFilterString(text)
                    }
                }

                AppButton {
                    text: "Очистить"
                    implicitWidth: 100
                    implicitHeight: 40
                    btnColor: Theme.backgroundColor
                    enabled: searchField.text.length > 0
                    enterDelay: 0

                    contentItem: Text {
                        text: parent.text
                        font: Theme.defaultFont
                        color: Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    onClicked: searchField.text = ""
                }
            }

            // --- Информационный баннер для режима привязки ---
            Rectangle {
                Layout.fillWidth: true
                height: 40
                visible: currentArticle !== ""
                color: "#fff3cd"
                border.color: Theme.warningColor
                border.width: 1
                radius: Theme.smallRadius

                AppLabel {
                    anchors.fill: parent
                    anchors.margins: 10
                    text: "⚠️ Выберите поставщиков для артикула: " + currentArticle
                    level: "body"
                    verticalAlignment: Text.AlignVCenter
                    color: "#856404"
                    enterDelay: 0
                }
            }

            // --- Контейнер таблицы ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Заголовок таблицы
                    HorizontalHeaderView {
                        id: header
                        syncView: suppliersTable
                        Layout.fillWidth: true
                        height: 35
                        textRole: "name"
                        clip: true

                        delegate: Rectangle {
                            implicitWidth: suppliersTable.columnWidthProvider(column)
                            implicitHeight: 35
                            color: headerColor
                            border.color: Theme.inputBorder
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 5

                                Text {
                                    Layout.fillWidth: true
                                    font: Theme.boldFont
                                    horizontalAlignment: column === 1 ? Text.AlignHCenter : Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    text: {
                                        switch (column) {
                                            case 0: return currentArticle !== "" ? "✓" : ""
                                            case 1: return "№"
                                            default:
                                                return (suppliersTable.model && suppliersTable.model.headerData)
                                                    ? suppliersTable.model.headerData(column, Qt.Horizontal, Qt.DisplayRole) || ""
                                                    : ""
                                        }
                                    }
                                }

                                Text {
                                    visible: column > 1
                                    text: "⇅"
                                    font.pixelSize: Theme.sizeCaption
                                    color: Theme.textSecondary
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: column > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (column > 1) {
                                        // Сортировка (для будущей реализации)
                                    }
                                }
                            }
                        }
                    }

                    // Таблица
                    TableView {
                        id: suppliersTable
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: suppliersTableModel
                        clip: true

                        columnWidthProvider: function(column) {
                            var config = columnConfig[column]
                            var calculated = width * config.proportion
                            return Math.max(config.minWidth, calculated)
                        }

                        rowHeightProvider: function() { return 45 }

                        onWidthChanged: forceLayout()

                        // Индикатор загрузки
                        Rectangle {
                            anchors.fill: parent
                            visible: isLoading
                            color: "#80ffffff"
                            z: 100

                            BusyIndicator {
                                anchors.centerIn: parent
                                running: parent.visible
                            }
                        }

                        // Пустое состояние
                        Item {
                            anchors.centerIn: parent
                            visible: suppliersTable.rows === 0 && !isLoading
                            width: parent.width * 0.6
                            height: 200

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "📦"
                                    font.pixelSize: 48
                                }

                                AppLabel {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: searchField.text.length > 0
                                        ? "Поставщики не найдены"
                                        : "Нет поставщиков"
                                    level: "h3"
                                    color: Theme.textSecondary
                                    enterDelay: 0
                                }

                                AppLabel {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: searchField.text.length > 0
                                        ? "Попробуйте изменить критерии поиска"
                                        : "Нажмите 'Добавить' для создания нового поставщика"
                                    level: "body"
                                    color: Theme.textSecondary
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    enterDelay: 0
                                }
                            }
                        }

                        delegate: DelegateChooser {
                            // Колонка с чекбоксом
                            DelegateChoice {
                                column: 0
                                Rectangle {
                                    required property int row
                                    required property int column

                                    implicitWidth: suppliersTable.columnWidthProvider(0)
                                    implicitHeight: 45
                                    color: (selectedRow === row) ? selectedColor : (row % 2 ? alternateRowColor : "white")
                                    border.color: Theme.inputBorder
                                    border.width: 0.5

                                    CheckBox {
                                        id: checkboxControl
                                        anchors.centerIn: parent
                                        visible: currentArticle !== ""
                                        checked: model.checkState === Qt.Checked

                                        onClicked: {
                                            console.log("Checkbox clicked: row=" + row + ", checked=" + checked)
                                            model.checkState = checked ? Qt.Checked : Qt.Unchecked
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        propagateComposedEvents: true
                                        z: -1
                                        cursorShape: currentArticle === "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (currentArticle === "") {
                                                selectedRow = row
                                            }
                                        }
                                    }
                                }
                            }

                            // Остальные колонки
                            DelegateChoice {
                                Rectangle {
                                    required property int row
                                    required property int column

                                    implicitWidth: suppliersTable.columnWidthProvider(column)
                                    implicitHeight: 45
                                    color: (selectedRow === row) ? selectedColor : (row % 2 ? alternateRowColor : "white")
                                    border.color: Theme.inputBorder
                                    border.width: 0.5

                                    TextEdit {
                                        text: {
                                            switch (column) {
                                                case 1: return row + 1
                                                case 2: return model.name || ""
                                                case 3: return model.company || ""
                                                case 4: return model.email || ""
                                                case 5: return model.phone || ""
                                                case 6: return model.website || ""
                                                default: return ""
                                            }
                                        }
                                        anchors.fill: parent
                                        anchors.margins: column === 1 ? 0 : 8
                                        horizontalAlignment: column === 1 ? Text.AlignHCenter : Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        font: Theme.defaultFont
                                        color: Theme.textColor
                                        wrapMode: TextEdit.NoWrap
                                        clip: true
                                        readOnly: true
                                        selectByMouse: true
                                        selectByKeyboard: true
                                        cursorVisible: false
                                        z: 1
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: currentArticle === "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        z: 0
                                        onClicked: {
                                            if (currentArticle === "") {
                                                selectedRow = row
                                            }
                                        }
                                        propagateComposedEvents: true
                                    }

                                    // Hover эффект
                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.primaryColor
                                        opacity: 0
                                        visible: currentArticle === ""

                                        Behavior on opacity {
                                            NumberAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            propagateComposedEvents: true
                                            onEntered: parent.opacity = 0.05
                                            onExited: parent.opacity = 0
                                            onClicked: mouse.accepted = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Подвал таблицы с количеством записей
                    Rectangle {
                        Layout.fillWidth: true
                        height: 35
                        color: headerColor
                        border.color: Theme.inputBorder
                        border.width: 1

                        AppLabel {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            text: "Всего записей: " + suppliersTable.rows +
                                  (currentArticle !== "" ? " | Выбрано: " + suppliersTableModel.getSelectedSupplierIds().length : "")
                            level: "body"
                            font.bold: true
                            color: Theme.textSecondary
                            enterDelay: 0
                        }
                    }
                }
            }
        }
    }

    // === КНОПКИ ===
    footer: Item {
        height: 65

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 8
            color: Theme.backgroundColor
            radius: Theme.smallRadius

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // Кнопки режима управления
                AppButton {
                    text: "✏️ Редактировать"
                    visible: currentArticle === ""
                    enabled: selectedRow >= 0
                    implicitWidth: 140
                    implicitHeight: 40
                    btnColor: Theme.primaryColor
                    enterDelay: 0

                    onClicked: {
                        var r = selectedRow
                        if (r < 0) return
                        var s = suppliersTableModel.getSupplierRow(r)
                        editSupplierDialog.openFor(s.id, s.name, s.company, s.email, s.phone, s.website)
                    }
                }

                AppButton {
                    text: "🗑️ Удалить"
                    visible: currentArticle === ""
                    enabled: selectedRow >= 0
                    implicitWidth: 110
                    implicitHeight: 40
                    btnColor: Theme.errorColor
                    enterDelay: 0

                    onClicked: {
                        var r = selectedRow
                        if (r < 0) return
                        var s = suppliersTableModel.getSupplierRow(r)
                        deleteSupplierDialog.openFor(s.id, s.company)
                    }
                }

                AppButton {
                    text: "➕ Добавить"
                    visible: currentArticle === ""
                    implicitWidth: 120
                    implicitHeight: 40
                    btnColor: Theme.successColor
                    enterDelay: 0

                    onClicked: addSupplierDialog.open()
                }

                Item { Layout.fillWidth: true }

                // Кнопки режима привязки
                AppButton {
                    text: "💾 Сохранить привязку"
                    visible: currentArticle !== ""
                    implicitWidth: 180
                    implicitHeight: 40
                    btnColor: Theme.successColor
                    enterDelay: 0

                    onClicked: {
                        console.log("Saving supplier binding...")
                        isLoading = true
                        var selectedIds = suppliersTableModel.getSelectedSupplierIds()
                        console.log("Selected IDs:", selectedIds)
                        suppliersTableModel.bindSuppliersToItem(currentArticle, selectedIds)
                        isLoading = false
                        root.close()
                    }
                }

                AppButton {
                    text: "Отмена"
                    visible: currentArticle !== ""
                    implicitWidth: 100
                    implicitHeight: 40
                    btnColor: Theme.backgroundColor
                    enterDelay: 0

                    contentItem: Text {
                        text: parent.text
                        font: Theme.defaultFont
                        color: Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    onClicked: root.close()
                }

                AppButton {
                    text: "Закрыть"
                    visible: currentArticle === ""
                    implicitWidth: 100
                    implicitHeight: 40
                    btnColor: Theme.backgroundColor
                    enterDelay: 0

                    contentItem: Text {
                        text: parent.text
                        font: Theme.defaultFont
                        color: Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    onClicked: root.close()
                }
            }
        }
    }

    // === АНИМАЦИИ ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.95; duration: 150; easing.type: Easing.InCubic }
        }
    }

    // === ФУНКЦИИ ===

    function openForManagement() {
        console.log("Opening suppliers manager for management mode")
        currentArticle = ""
        selectedRow = -1
        searchField.text = ""
        isLoading = true
        suppliersTableModel.load()
        isLoading = false
        open()
    }

    function openForBinding(article) {
        console.log("Opening suppliers manager for binding to article:", article)
        currentArticle = article
        selectedRow = -1
        isLoading = true
        suppliersTableModel.loadForArticle(article)
        isLoading = false
        open()
    }

    // Сброс фильтра при закрытии
    onClosed: {
        console.log("Dialog closed, clearing filter")
        searchField.text = ""
        suppliersTableModel.setFilterString("")
    }
}
