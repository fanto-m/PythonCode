// SuppliersManagerDialog.qml - FIXED VERSION with proper checkbox binding
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels
import QtQuick.Window

Dialog {
    id: suppliersManagerDialog
    title: currentArticle === "" ? "Управление поставщиками" : "Привязка поставщиков к артикулу: " + currentArticle
    modal: true
    width: Math.min(Screen.width * 0.9, 1400)
    height: Math.min(Screen.height * 0.8, 900)

    // Theme constants for easy customization
    readonly property color primaryColor: "#2196F3"
    readonly property color selectedColor: "#fde3ee"
    readonly property color alternateRowColor: "#f5f5f5"
    readonly property color headerColor: "#e0e0e0"
    readonly property color borderColor: "#d0d0d0"
    readonly property int baseSpacing: 10
    readonly property int baseFontSize: 10

    property string currentArticle: ""
    property int selectedRow: -1
    property bool isLoading: false

    // Column configuration for easier maintenance
    readonly property var columnConfig: [
        { proportion: 0.03, minWidth: 40, role: "checkbox" },
        { proportion: 0.03, minWidth: 40, role: "number" },
        { proportion: 0.21, minWidth: 120, role: "name" },
        { proportion: 0.21, minWidth: 120, role: "company" },
        { proportion: 0.21, minWidth: 140, role: "email" },
        { proportion: 0.17, minWidth: 100, role: "phone" },
        { proportion: 0.14, minWidth: 150, role: "website" }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: baseSpacing
        spacing: baseSpacing

        // Search/Filter bar
        RowLayout {
            Layout.fillWidth: true
            spacing: baseSpacing
            visible: currentArticle === ""

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Поиск по имени, компании, email..."
                leftPadding: 35

                // Search icon
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "🔍"
                    font.pointSize: baseFontSize
                    color: "#757575"
                }

                onTextChanged: {
                    // Применяем фильтр при изменении текста
                    suppliersTableModel.setFilterString(text)
                }
            }

            Button {
                text: "Очистить"
                enabled: searchField.text.length > 0
                onClicked: searchField.text = ""
            }
        }

        // Info banner for binding mode
        Rectangle {
            Layout.fillWidth: true
            height: 40
            visible: currentArticle !== ""
            color: "#fff3cd"
            border.color: "#ffc107"
            radius: 4

            Text {
                anchors.fill: parent
                anchors.margins: baseSpacing
                text: "Выберите поставщиков для артикула: " + currentArticle
                verticalAlignment: Text.AlignVCenter
                font.pointSize: baseFontSize
                color: "#856404"
            }
        }

        // Table container with shadow effect
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            border.color: borderColor
            border.width: 1
            radius: 4

            // Drop shadow effect
            layer.enabled: true
            layer.effect: ShaderEffect {
                property color shadowColor: "#40000000"
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
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
                        border.color: borderColor
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5

                            Text {
                                Layout.fillWidth: true
                                font.bold: true
                                font.pointSize: baseFontSize
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

                            // Sort indicator (placeholder for future implementation)
                            Text {
                                visible: column > 1
                                text: "⇅"
                                font.pointSize: baseFontSize - 1
                                color: "#757575"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: column > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (column > 1) {
                                    // Implement sorting
                                    // suppliersTableModel.sortByColumn(column)
                                }
                            }
                        }
                    }
                }

                // Table
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

                    // Loading overlay
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

                    // Empty state
                    Item {
                        anchors.centerIn: parent
                        visible: suppliersTable.rows === 0 && !isLoading
                        width: parent.width * 0.6
                        height: 200

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: baseSpacing

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "📦"
                                font.pointSize: 48
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: searchField.text.length > 0
                                    ? "Поставщики не найдены"
                                    : "Нет поставщиков"
                                font.pointSize: baseFontSize + 4
                                font.bold: true
                                color: "#757575"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: searchField.text.length > 0
                                    ? "Попробуйте изменить критерии поиска"
                                    : "Нажмите 'Добавить' для создания нового поставщика"
                                font.pointSize: baseFontSize
                                color: "#9e9e9e"
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    delegate: DelegateChooser {
                        // Checkbox column
                        DelegateChoice {
                            column: 0
                            Rectangle {
                                required property int row
                                required property int column

                                implicitWidth: suppliersTable.columnWidthProvider(0)
                                implicitHeight: 45
                                color: (selectedRow === row) ? selectedColor : (row % 2 ? alternateRowColor : "white")
                                border.color: borderColor
                                border.width: 0.5

                                CheckBox {
                                    id: checkboxControl
                                    anchors.centerIn: parent
                                    visible: currentArticle !== ""

                                    // ✅ ИСПРАВЛЕНО: Используем прямой биндинг вместо Component.onCompleted
                                    // Это гарантирует что checkbox всегда синхронизирован с моделью
                                    checked: model.checkState === Qt.Checked

                                    // Обработка клика
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

                        // Other columns
                        DelegateChoice {
                            Rectangle {
                                required property int row
                                required property int column

                                implicitWidth: suppliersTable.columnWidthProvider(column)
                                implicitHeight: 45
                                color: (selectedRow === row) ? selectedColor : (row % 2 ? alternateRowColor : "white")
                                border.color: borderColor
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
                                    font.pointSize: baseFontSize + 1
                                    color: "#212121"
                                    wrapMode: TextEdit.NoWrap
                                    clip: true

                                    // Делаем текст выделяемым и копируемым
                                    readOnly: true
                                    selectByMouse: true
                                    selectByKeyboard: true
                                    cursorVisible: false

                                    // ВАЖНО: поднимаем выше MouseArea
                                    z: 1
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: currentArticle === "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    z: 0  // ниже чем TextEdit
                                    onClicked: {
                                        if (currentArticle === "") {
                                            selectedRow = row
                                        }
                                    }
                                    // Пропускаем события, если они не обработаны
                                    propagateComposedEvents: true
                                }

                                // Hover effect
                                Rectangle {
                                    anchors.fill: parent
                                    color: primaryColor
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

                // Footer with record count
                Rectangle {
                    Layout.fillWidth: true
                    height: 35
                    color: headerColor
                    border.color: borderColor
                    border.width: 1

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: baseSpacing
                        verticalAlignment: Text.AlignVCenter
                        text: "Всего записей: " + suppliersTable.rows +
                              (currentArticle !== "" ? " | Выбрано: " + suppliersTableModel.getSelectedSupplierIds().length : "")
                        font.pointSize: baseFontSize
                        font.bold: true
                        color: "#424242"
                    }
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: baseSpacing

            Button {
                text: "✏️ Редактировать"
                visible: currentArticle === ""
                enabled: selectedRow >= 0
                font.pointSize: baseFontSize
                onClicked: {
                    var r = selectedRow
                    if (r < 0) return
                    var s = suppliersTableModel.getSupplierRow(r)
                    editSupplierDialog.openFor(s.id, s.name, s.company, s.email, s.phone, s.website)
                }
            }

            Button {
                text: "🗑️ Удалить"
                visible: currentArticle === ""
                enabled: selectedRow >= 0
                font.pointSize: baseFontSize
                onClicked: {
                    var r = selectedRow
                    if (r < 0) return
                    var s = suppliersTableModel.getSupplierRow(r)
                    deleteSupplierDialog.openFor(s.id, s.company)
                }
            }

            Button {
                text: "➕ Добавить"
                visible: currentArticle === ""
                highlighted: true
                font.pointSize: baseFontSize
                onClicked: addSupplierDialog.open()
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "💾 Сохранить привязку"
                visible: currentArticle !== ""
                highlighted: true
                font.pointSize: baseFontSize
                onClicked: {
                    console.log("Saving supplier binding...")
                    isLoading = true
                    var selectedIds = suppliersTableModel.getSelectedSupplierIds()
                    console.log("Selected IDs:", selectedIds)
                    suppliersTableModel.bindSuppliersToItem(currentArticle, selectedIds)
                    isLoading = false
                    close()
                }
            }

            Button {
                text: "Отмена"
                visible: currentArticle !== ""
                font.pointSize: baseFontSize
                onClicked: close()
            }

            Button {
                text: "Закрыть"
                visible: currentArticle === ""
                font.pointSize: baseFontSize
                onClicked: close()
            }
        }
    }

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

    // Сброс фильтра при закрытии диалога
    onClosed: {
        console.log("Dialog closed, clearing filter")
        searchField.text = ""
        suppliersTableModel.setFilterString("")
    }

    // Keyboard navigation
    Keys.onPressed: function(event) {
        if (currentArticle !== "" || suppliersTable.rows === 0) return

        if (event.key === Qt.Key_Up && selectedRow > 0) {
            selectedRow--
            event.accepted = true
        } else if (event.key === Qt.Key_Down && selectedRow < suppliersTable.rows - 1) {
            selectedRow++
            event.accepted = true
        }
    }
}
