// ViewSpecificationsMode.qml - Полностью переписан
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./" as Local

Rectangle {
    id: root
    color: "#f5f5f5"

    signal backToMain()
    signal editSpecification(int specId)

    property var allSpecifications: []

    ListModel {
        id: specificationsListModel
    }

    function loadSpecifications() {
        allSpecifications = specificationsModel.loadAllSpecifications()
        filterSpecifications()
        console.log("DEBUG: Loaded", allSpecifications.length, "specifications")
    }

    function filterSpecifications() {
        specificationsListModel.clear()

        var searchText = searchField.text.toLowerCase()
        var statusFilter = statusFilterCombo.currentText

        for (var i = 0; i < allSpecifications.length; i++) {
            var spec = allSpecifications[i]

            var matchesSearch = searchText === "" ||
                               spec.name.toLowerCase().indexOf(searchText) >= 0 ||
                               (spec.description && spec.description.toLowerCase().indexOf(searchText) >= 0)

            var matchesStatus = statusFilter === "Все" || spec.status === statusFilter

            if (matchesSearch && matchesStatus) {
                specificationsListModel.append(spec)
            }
        }
    }

    Component.onCompleted: {
        loadSpecifications()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========================================
        // HEADER
        // ========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#9b59b6"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Button {
                    text: "← Главное меню"
                    onClicked: backToMain()

                    background: Rectangle {
                        color: parent.down ? "#8e44ad" : (parent.hovered ? "#2c3e50" : "transparent")
                        radius: 4
                        border.color: "white"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pointSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    text: "Просмотр спецификаций"
                    font.pointSize: 18
                    font.bold: true
                    color: "white"
                    Layout.fillWidth: true
                }

                Button {
                    text: "🔄 Обновить"
                    onClicked: loadSpecifications()

                    background: Rectangle {
                        color: parent.down ? "#8e44ad" : (parent.hovered ? "#2c3e50" : "transparent")
                        radius: 4
                        border.color: "white"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pointSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    text: "📋"
                    font.pointSize: 24
                }
            }
        }

        // ========================================
        // FILTER / SEARCH BAR
        // ========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "white"
            border.color: "#d0d0d0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Поиск:"
                    font.pointSize: 10
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Введите название спецификации..."
                    font.pointSize: 10
                    onTextChanged: filterSpecifications()

                    background: Rectangle {
                        color: "white"
                        border.color: searchField.activeFocus ? "#9b59b6" : "#d0d0d0"
                        border.width: searchField.activeFocus ? 2 : 1
                        radius: 4
                    }
                }

                ComboBox {
                    id: statusFilterCombo
                    model: ["Все", "черновик", "утверждена", "архив"]
                    Layout.preferredWidth: 150
                    font.pointSize: 10
                    currentIndex: 0
                    onCurrentIndexChanged: filterSpecifications()
                }

                Text {
                    text: "Всего: " + specificationsListView.count
                    font.pointSize: 10
                    color: "#666"
                }
            }
        }

        // ========================================
        // SPECIFICATIONS LIST
        // ========================================
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: specificationsListView
                anchors.fill: parent
                spacing: 10
                anchors.margins: 15
                model: specificationsListModel

                delegate: Rectangle {
                    width: specificationsListView.width - 30
                    height: 180
                    color: "white"
                    radius: 8
                    border.color: "#d0d0d0"
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        color: mouseArea.containsMouse ? "#f8f9fa" : "transparent"
                        radius: 8
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: detailsDialog.openFor(model.id, model.name, model.description, model.status, model.labor_cost, model.overhead_percentage, model.final_price, model.created_date, model.modified_date)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: model.name
                                font.pointSize: 14
                                font.bold: true
                                color: "#2c3e50"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.description || "Нет описания"
                                font.pointSize: 9
                                color: model.description ? "#555" : "#999"
                                font.italic: !model.description
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: statusText.width + 20
                                Layout.preferredHeight: 25
                                radius: 12
                                color: {
                                    switch(model.status) {
                                        case "черновик": return "#ffc107"
                                        case "утверждена": return "#28a745"
                                        case "архив": return "#6c757d"
                                        default: return "#6c757d"
                                    }
                                }

                                Text {
                                    id: statusText
                                    anchors.centerIn: parent
                                    text: model.status
                                    color: "white"
                                    font.pointSize: 9
                                    font.bold: true
                                }
                            }

                            RowLayout {
                                spacing: 15

                                Text {
                                    text: "Создана: " + model.created_date.split(" ")[0]
                                    font.pointSize: 8
                                    color: "#999"
                                }
                                Text {
                                    text: "Изменена: " + model.modified_date.split(" ")[0]
                                    font.pointSize: 8
                                    color: "#999"
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 180
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#e8f5e9"
                                border.color: "#28a745"
                                border.width: 2
                                radius: 6

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Итоговая цена"
                                        font.pointSize: 8
                                        color: "#666"
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: model.final_price.toFixed(2) + " ₽"
                                        font.pointSize: 14
                                        font.bold: true
                                        color: "#28a745"
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Button {
                                    text: "✏️"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    font.pointSize: 12
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Редактировать"
                                    onClicked: editSpecificationDialog.openFor(model.id)

                                    background: Rectangle {
                                        color: parent.down ? "#0056b3" : (parent.hovered ? "#0069d9" : "#007bff")
                                        radius: 4
                                    }
                                }

                                Button {
                                    text: "📄"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    font.pointSize: 12
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Экспорт Excel"
                                    onClicked: specificationsModel.exportToExcel(model.id)

                                    background: Rectangle {
                                        color: parent.down ? "#117a8b" : (parent.hovered ? "#138496" : "#17a2b8")
                                        radius: 4
                                    }
                                }

                                Button {
                                    text: "📕"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    font.pointSize: 12
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Экспорт PDF"
                                    onClicked: specificationsModel.exportToPDF(model.id)

                                    background: Rectangle {
                                        color: parent.down ? "#c82333" : (parent.hovered ? "#e02535" : "#dc3545")
                                        radius: 4
                                    }
                                }

                                Button {
                                    text: "🗑️"
                                    font.pointSize: 12
                                    font.family: "Segoe UI Emoji"
                                    Layout.preferredWidth: 35
                                    Layout.preferredHeight: 35
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Удалить"
                                    onClicked: deleteConfirmDialog.openFor(model.id, model.name)

                                    background: Rectangle {
                                        color: parent.down ? "#a71d2a" : (parent.hovered ? "#c82333" : "#dc3545")
                                        radius: 4
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: specificationsListView.count === 0
                    text: "Нет спецификаций\nСоздайте новую в разделе 'Создать спецификацию'"
                    font.pointSize: 12
                    color: "#999"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    // ========================================
    // DETAILS DIALOG - ПЕРЕПИСАН ПОЛНОСТЬЮ
    // ========================================
    Dialog {
        id: detailsDialog
        title: "Детали спецификации"
        modal: true
        width: 1400  // ✅ Увеличена ширина
        height: 900  // ✅ Увеличена высота
        anchors.centerIn: parent

        property int specId: -1
        property string specName: ""
        property string specDescription: ""
        property string specStatus: ""
        property real laborCost: 0
        property real overheadPercentage: 0
        property real finalPrice: 0
        property string createdDate: ""
        property string modifiedDate: ""

        function openFor(id, name, desc, status, labor, overhead, price, created, modified) {
            specId = id
            specName = name
            specDescription = desc
            specStatus = status
            laborCost = labor
            overheadPercentage = overhead
            finalPrice = price
            createdDate = created
            modifiedDate = modified

            console.log("=== Opening spec details for ID:", id, "===")

            specificationItemsModel.clear()
            var items = specificationsModel.loadSpecificationItems(id)
            console.log("Loaded items from DB:", items.length)

            if (items.length > 0) {
                console.log("First item:", JSON.stringify(items[0]))
            }

            specificationItemsModel.loadItems(items)
            console.log("Model rowCount after load:", specificationItemsModel.rowCount())

            open()
        }
        // ✅ ДОБАВИТЬ: Очистка при закрытии
        onClosed: {
            console.log("Details dialog closed - clearing model")
            specificationItemsModel.clear()
        }

        // ✅ КРИТИЧНО: contentItem БЕЗ ScrollView на верхнем уровне
        contentItem: ScrollView {
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 15

                // Header info - компактный блок
                GroupBox {
                    Layout.fillWidth: true
                    title: "Информация"

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d0d0"
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 4
                        columnSpacing: 15
                        rowSpacing: 6

                        Text { text: "Название:"; font.bold: true; font.pointSize: 9 }
                        Text { text: detailsDialog.specName; Layout.columnSpan: 3; font.pointSize: 9 }

                        Text { text: "Статус:"; font.bold: true; font.pointSize: 9 }
                        Text { text: detailsDialog.specStatus; font.pointSize: 9 }

                        Text { text: "Создана:"; font.bold: true; font.pointSize: 9 }
                        Text { text: detailsDialog.createdDate; font.pointSize: 9 }
                    }
                }

                // Материалы
                GroupBox {
                    Layout.fillWidth: true
                    title: "Материалы и комплектующие (" + (specificationItemsModel ? specificationItemsModel.rowCount() : 0) + " поз.)"

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d0d0"
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "#e3f2fd"
                            radius: 4
                            visible: itemsTable.rowCount > 0

                            Text {
                                anchors.centerIn: parent
                                text: "📦 Позиций: " + itemsTable.rowCount + " | Стоимость материалов: " + (specificationItemsModel ? specificationItemsModel.getTotalMaterialsCost().toFixed(2) : "0.00") + " ₽"
                                font.pointSize: 10
                                font.bold: true
                                color: "#2196F3"
                            }
                        }

                        Local.SpecificationItemsTable {
                            id: itemsTable
                            Layout.fillWidth: true
                            Layout.preferredHeight: 500
                            model: specificationItemsModel
                            enabled: false
                            readOnly: true  // ✅ ДОБАВЛЕНО - скрываем кнопку удаления
                        }
                    }
                }

                // Калькуляция
                GroupBox {
                    Layout.fillWidth: true
                    title: "Калькуляция"

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d0d0"
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        columnSpacing: 15
                        rowSpacing: 6

                        property real materialsCost: specificationItemsModel ? specificationItemsModel.getTotalMaterialsCost() : 0
                        property real overheadCost: materialsCost * (detailsDialog.overheadPercentage / 100)

                        Text { text: "Материалы:"; font.pointSize: 9 }
                        Text {
                            text: parent.materialsCost.toFixed(2) + " ₽"
                            font.pointSize: 9
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#007bff"
                        }

                        Text { text: "Работа:"; font.pointSize: 9 }
                        Text {
                            text: detailsDialog.laborCost.toFixed(2) + " ₽"
                            font.pointSize: 9
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#007bff"
                        }

                        Text { text: "Накладные (" + detailsDialog.overheadPercentage + "%):"; font.pointSize: 9 }
                        Text {
                            text: parent.overheadCost.toFixed(2) + " ₽"
                            font.pointSize: 9
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#007bff"
                        }

                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 1
                            color: "#28a745"
                        }

                        Text { text: "ИТОГО:"; font.pointSize: 11; font.bold: true; color: "#28a745" }
                        Text {
                            text: detailsDialog.finalPrice.toFixed(2) + " ₽"
                            font.pointSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#28a745"
                        }
                    }
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "Закрыть"
                onClicked: detailsDialog.close()

                background: Rectangle {
                    color: parent.down ? "#5a6268" : (parent.hovered ? "#6c757d" : "#6c757d")
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
        }
    }

    // Edit dialog (placeholder)
    Dialog {
        id: editSpecificationDialog
        title: "Редактирование спецификации"
        modal: true
        width: 400
        height: 150
        anchors.centerIn: parent

        property int specId: -1

        function openFor(id) {
            specId = id
            open()
        }

        contentItem: Text {
            text: "Функция редактирования находится в разработке.\n\nПока вы можете удалить старую спецификацию\nи создать новую."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent
        }

        footer: DialogButtonBox {
            Button {
                text: "OK"
                onClicked: editSpecificationDialog.close()
            }
        }
    }

    // Delete confirmation dialog
    Dialog {
        id: deleteConfirmDialog
        title: "Подтверждение удаления"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        width: 400
        height: 150
        anchors.centerIn: parent

        property int specId: -1
        property string specName: ""

        function openFor(id, name) {
            specId = id
            specName = name
            open()
        }

        contentItem: Text {
            text: "Вы уверены, что хотите удалить спецификацию\n\"" + deleteConfirmDialog.specName + "\"?\n\nЭто действие нельзя отменить."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent
            padding: 20
        }

        onAccepted: {
            if (specificationsModel.deleteSpecification(deleteConfirmDialog.specId)) {
                loadSpecifications()
                successMessage.text = "Спецификация успешно удалена"
                successMessage.open()
            }
        }
    }

    // Success message
    Dialog {
        id: successMessage
        title: "Успех"
        modal: true
        width: 300
        height: 120
        anchors.centerIn: parent

        property alias text: messageText.text

        contentItem: Text {
            id: messageText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent
        }

        footer: DialogButtonBox {
            Button {
                text: "OK"
                onClicked: successMessage.close()
            }
        }
    }
}