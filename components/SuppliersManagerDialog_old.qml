// components/SuppliersManagerDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels

Dialog {
    id: suppliersManagerDialog
    title: "Управление поставщиками"
    modal: true
    width: 1000
    height: 800

    property string currentArticle: ""
    property var selectedRows: []   // массив выбранных строк (для чекбоксов)
    property int selectedRow: -1    // текущая выбранная строка

    function isRowSelected(row) {
        return selectedRows.indexOf(row) >= 0
    }

    function toggleRowSelection(row) {
        var idx = selectedRows.indexOf(row)
        if (idx >= 0)
            selectedRows.splice(idx, 1)
        else
            selectedRows.push(row)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        // Заголовок таблицы
        HorizontalHeaderView {
            id: header
            syncView: suppliersTable
            Layout.fillWidth: true
            height: 30
            textRole: ""
            model: 7
            delegate: Rectangle {
                color: "#e0e0e0"
                border.color: "gray"
                Text {
                    anchors.centerIn: parent
                    font.bold: true
                    text: {
                        switch (modelData) {
                            case 0: return ""
                            case 1: return "ID"
                            case 2: return "ФИО"
                            case 3: return "Компания"
                            case 4: return "Email"
                            case 5: return "Телефон"
                            case 6: return "Сайт"
                            default: return ""
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
                switch (column) {
                    case 0: return 40
                    case 1: return 50
                    case 2: return 150
                    case 3: return 200
                    case 4: return 150
                    case 5: return 120
                    case 6: return 150
                    default: return 100
                }
            }
            rowHeightProvider: function() { return 40 }

            delegate: Rectangle {
                color: suppliersManagerDialog.isRowSelected(row)
                       ? "#e3f2fd"
                       : (row % 2 ? "#f5f5f5" : "white")

                Item {
                    anchors.fill: parent

                    // Чекбокс (только в первой колонке и если идёт привязка к товару)
                    CheckBox {
                        visible: column === 0 && suppliersManagerDialog.currentArticle !== ""
                        enabled: suppliersManagerDialog.currentArticle !== ""
                        checked: model.checked
                        anchors.centerIn: parent
                        onClicked: suppliersManagerDialog.toggleRowSelection(row)
                    }

                    // Текст в остальных колонках
                    Text {
                        visible: column > 0
                        text: {
                            switch (column) {
                                case 1: return model.id
                                case 2: return model.name
                                case 3: return model.company
                                case 4: return model.email
                                case 5: return model.phone
                                case 6: return model.website
                                default: return ""
                            }
                        }
                        anchors.fill: parent
                        anchors.margins: 5
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (column > 0 || !suppliersManagerDialog.currentArticle)
                            suppliersManagerDialog.selectedRow = row
                        if (suppliersManagerDialog.currentArticle !== "")
                            suppliersManagerDialog.toggleRowSelection(row)
                    }
                }
            }
        }

        // Кнопки
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "Редактировать"
                visible: currentArticle === ""
                enabled: suppliersManagerDialog.selectedRow >= 0
                onClicked: {
                    var r = suppliersManagerDialog.selectedRow
                    if (r < 0) return
                    var s = suppliersTable.model.get(r)
                    editSupplierDialog.openFor(
                        s.id, s.name, s.company, s.email, s.phone, s.website
                    )
                }
            }

            Button {
                text: "Удалить"
                visible: currentArticle === ""
                enabled: suppliersManagerDialog.selectedRow >= 0
                onClicked: {
                    var r = suppliersManagerDialog.selectedRow
                    if (r < 0) return
                    var s = suppliersTable.model.get(r)
                    deleteSupplierDialog.openFor(s.id, s.company)
                }
            }

            Button {
                text: "Добавить"
                visible: currentArticle === ""
                onClicked: addSupplierDialog.open()
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Сохранить привязку"
                visible: currentArticle !== ""
                enabled: suppliersManagerDialog.selectedRows.length > 0
                onClicked: {
                    var selectedIds = []
                    for (var i = 0; i < suppliersManagerDialog.selectedRows.length; i++) {
                        var row = suppliersManagerDialog.selectedRows[i]
                        var s = suppliersTable.model.get(row)
                        if (s && s.id)
                            selectedIds.push(parseInt(s.id))
                    }
                    suppliersTableModel.bindSuppliersToItem(currentArticle, selectedIds)
                    close()
                }
            }

            Button {
                text: "Закрыть"
                onClicked: close()
            }
        }
    }

    function openForManagement() {
        currentArticle = ""
        selectedRows = []
        selectedRow = -1
        open()
    }

    function openForBinding(article) {
        currentArticle = article
        selectedRows = []
        selectedRow = -1
        open()
    }
}
