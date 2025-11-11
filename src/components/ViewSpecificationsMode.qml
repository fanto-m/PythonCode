// ViewSpecificationsMode.qml - Оптимизированная версия с SpecificationItemsTable
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
    // Глобальная настройка ориентации PDF
    property bool useLandscapeOrientation: false

    ListModel {
        id: specificationsListModel
    }

    Local.AddItemDialog {
    id: addItemDialog

    onItemSelected: function(article, name, quantity, unit, price, imagePath, category, status) {
        specificationItemsModel.addItem(
            article, name, quantity, unit, price,
            imagePath, category, status
        )
        editSpecificationDialog.hasChanges = true
        editSpecificationDialog.calculateEditCosts()
    }
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

        /// ========================================
        // ИЗМЕНИТЬ СЕКЦИЮ FILTER / SEARCH BAR
        // Добавить CheckBox для ориентации
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

                // ✅ ДОБАВИТЬ ЭТО - Разделитель
                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.fillHeight: true
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    color: "#d0d0d0"
                }

                // ✅ ДОБАВИТЬ ЭТО - CheckBox для ориентации
                RowLayout {
                    spacing: 5

                    Text {
                        text: "📄 PDF:"
                        font.pointSize: 9
                        color: "#666"
                    }

                    CheckBox {
                        id: landscapeCheckBox
                        text: "Альбомная"
                        font.pointSize: 9
                        checked: root.useLandscapeOrientation

                        Component.onCompleted: {
                            console.log("✅ CheckBox created!")  // ✅ ДОБАВЬТЕ ЭТО
                        }

                        onCheckedChanged: {
                            root.useLandscapeOrientation = checked
                            console.log("📄 Ориентация изменена:", checked ? "альбомная" : "портретная")  // ✅ И ЭТО
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: "Использовать альбомную ориентацию для экспорта PDF"
                        ToolTip.delay: 500
                    }
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
                            Layout.preferredWidth: 100
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
                                        color: parent.down ? "#1E2D44" : (parent.hovered ? "#3B5278" : "#2D4262")
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
                                        color: parent.down ? "#4D6F6E" : (parent.hovered ? "#78A5A3" : "#66908F")
                                        radius: 4
                                    }
                                }

                                Button {
                                    text: "📄"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    font.pointSize: 12
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Экспорт PDF"
                                    onClicked: specificationsModel.exportToPDF(model.id, root.useLandscapeOrientation)  // ✅ ИЗМЕНЕНО

                                    background: Rectangle {
                                        color: parent.down ? "#CC5A1A" : (parent.hovered ? "#FA812F" : "#E66F20")
                                        radius: 4
                                    }
                                }


                                Button {
                                    text: "🗑️"  // trash — это emoji
                                    font.pointSize: 12
                                    font.family: "Segoe UI Emoji, Apple Color Emoji, Noto Color Emoji, Twemoji Mozilla"

                                    Layout.preferredWidth: 35
                                    Layout.preferredHeight: 35

                                    ToolTip.visible: hovered
                                    ToolTip.text: "Удалить"

                                    onClicked: deleteConfirmDialog.openFor(model.id, model.name)

                                    // ЯВНО ЗАДАЁМ ЦВЕТ ТЕКСТА
                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: "white"  // КЛЮЧЕВАЯ СТРОКА!
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: parent.down ? "#C41C1C" : (parent.hovered ? "#E63535" : "#F34A4A")
                                        radius: 8
                                        border.width: 0
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
    // DETAILS DIALOG (только просмотр)
    // ========================================
    Dialog {
        id: detailsDialog
        title: "Детали спецификации"
        modal: true
        width: 1400
        height: 900
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

            specificationItemsModel.clear()
            var items = specificationsModel.loadSpecificationItems(id)
            specificationItemsModel.loadItems(items)
            open()
        }

        onClosed: {
            specificationItemsModel.clear()
        }

        contentItem: ScrollView {
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 15

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
                            readOnly: true
                        }
                    }
                }

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

    // ========================================
    // EDIT SPECIFICATION DIALOG
    // ========================================
    Dialog {
        id: editSpecificationDialog
        title: "Редактирование спецификации"
        modal: true
        width: 1400
        height: 900
        anchors.centerIn: parent

        property int specId: -1
        property bool hasChanges: false
        property real materialsCost: 0
        property real laborCost: 0
        property real overheadCost: 0
        property real totalCost: 0

        function openFor(id) {
            specId = id
            hasChanges = false

            var specs = specificationsModel.loadAllSpecifications()
            var spec = null
            for (var i = 0; i < specs.length; i++) {
                if (specs[i].id === id) {
                    spec = specs[i]
                    break
                }
            }

            if (!spec) {
                console.error("Specification not found:", id)
                return
            }

            editNameField.text = spec.name
            editDescriptionField.text = spec.description || ""
            editLaborCostField.text = spec.labor_cost.toString()
            editOverheadField.text = spec.overhead_percentage.toString()

            var statuses = ["черновик", "утверждена", "архив"]
            editStatusComboBox.currentIndex = statuses.indexOf(spec.status)

            specificationItemsModel.clear()
            var items = specificationsModel.loadSpecificationItems(id)
            specificationItemsModel.loadItems(items)

            calculateEditCosts()
            open()
        }

        function calculateEditCosts() {
            materialsCost = specificationItemsModel.getTotalMaterialsCost() || 0
            laborCost = parseFloat(editLaborCostField.text) || 0
            var overheadPercent = parseFloat(editOverheadField.text) || 0
            overheadCost = materialsCost * (overheadPercent / 100)
            totalCost = materialsCost + laborCost + overheadCost
        }

        function saveChanges() {
            var result = specificationsModel.saveSpecification(
                specId,
                editNameField.text,
                editDescriptionField.text,
                editStatusComboBox.currentText,
                laborCost,
                parseFloat(editOverheadField.text) || 0
            )

            if (result > 0) {
                hasChanges = false
                loadSpecifications()
                successMessage.text = "Спецификация успешно обновлена!"
                successMessage.open()
                editSpecificationDialog.close()
            } else {
                errorMessage.text = "Ошибка при сохранении спецификации!"
                errorMessage.open()
            }
        }

        onClosed: {
            specificationItemsModel.clear()
        }

        contentItem: ScrollView {
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 15

                GroupBox {
                    Layout.fillWidth: true
                    title: "Основная информация"
                    font.pointSize: 11
                    font.bold: true

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d0d0"
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Название изделия *"
                                    font.pointSize: 10
                                    font.bold: true
                                }

                                TextField {
                                    id: editNameField
                                    Layout.fillWidth: true
                                    placeholderText: "Например: Изделие А-123"
                                    font.pointSize: 10
                                    onTextChanged: editSpecificationDialog.hasChanges = true

                                    background: Rectangle {
                                        color: "white"
                                        border.color: editNameField.activeFocus ? "#9b59b6" : "#d0d0d0"
                                        border.width: editNameField.activeFocus ? 2 : 1
                                        radius: 4
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 4

                                Text {
                                    text: "Статус"
                                    font.pointSize: 10
                                    font.bold: true
                                }

                                ComboBox {
                                    id: editStatusComboBox
                                    Layout.fillWidth: true
                                    model: ["черновик", "утверждена", "архив"]
                                    font.pointSize: 10
                                    onCurrentIndexChanged: editSpecificationDialog.hasChanges = true

                                    background: Rectangle {
                                        color: "white"
                                        border.color: editStatusComboBox.activeFocus ? "#9b59b6" : "#d0d0d0"
                                        border.width: editStatusComboBox.activeFocus ? 2 : 1
                                        radius: 4
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Описание"
                                font.pointSize: 10
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                clip: true

                                TextArea {
                                    id: editDescriptionField
                                    placeholderText: "Подробное описание изделия..."
                                    wrapMode: TextEdit.Wrap
                                    font.pointSize: 10
                                    selectByMouse: true
                                    onTextChanged: editSpecificationDialog.hasChanges = true

                                    background: Rectangle {
                                        color: "white"
                                        border.color: editDescriptionField.activeFocus ? "#9b59b6" : "#d0d0d0"
                                        border.width: editDescriptionField.activeFocus ? 2 : 1
                                        radius: 4
                                    }
                                }
                            }
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Материалы и комплектующие"
                    font.pointSize: 11
                    font.bold: true

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
                            visible: editItemsTable.rowCount > 0

                            Text {
                                anchors.centerIn: parent
                                text: "📦 Позиций: " + editItemsTable.rowCount + " | Стоимость материалов: " + editSpecificationDialog.materialsCost.toFixed(2) + " ₽"
                                font.pointSize: 10
                                font.bold: true
                                color: "#2196F3"
                            }
                        }

                        Button {
                            text: "➕ Добавить позицию из склада"
                            Layout.fillWidth: true
                            font.pointSize: 10

                            background: Rectangle {
                                color: parent.down ? "#218838" : (parent.hovered ? "#1e7e34" : "#28a745")
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: addItemDialog.open()
                        }

                        Local.SpecificationItemsTable {
                            id: editItemsTable
                            Layout.fillWidth: true
                            Layout.preferredHeight: 400
                            model: specificationItemsModel
                            readOnly: false

                            onItemQuantityChanged: function(row, newQuantity) {
                                specificationItemsModel.updateQuantity(row, newQuantity)
                                editSpecificationDialog.hasChanges = true
                                editSpecificationDialog.calculateEditCosts()
                            }

                            onItemRemoved: function(row) {
                                specificationItemsModel.removeItem(row)
                                editSpecificationDialog.hasChanges = true
                                editSpecificationDialog.calculateEditCosts()
                            }
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Калькуляция стоимости"
                    font.pointSize: 11
                    font.bold: true

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d0d0"
                        radius: 6
                        y: parent.topPadding - parent.bottomPadding
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 15

                        Text {
                            text: "Стоимость работы (₽):"
                            font.pointSize: 10
                        }
                        TextField {
                            id: editLaborCostField
                            Layout.fillWidth: true
                            text: "0"
                            font.pointSize: 10
                            horizontalAlignment: Text.AlignRight
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            onTextChanged: {
                                editSpecificationDialog.hasChanges = true
                                editSpecificationDialog.calculateEditCosts()
                            }

                            background: Rectangle {
                                color: "white"
                                border.color: editLaborCostField.activeFocus ? "#9b59b6" : "#d0d0d0"
                                border.width: editLaborCostField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        Text {
                            text: "Накладные расходы (%):"
                            font.pointSize: 10
                        }
                        TextField {
                            id: editOverheadField
                            Layout.fillWidth: true
                            text: "0"
                            font.pointSize: 10
                            horizontalAlignment: Text.AlignRight
                            validator: DoubleValidator { bottom: 0; top: 100; decimals: 2 }
                            onTextChanged: {
                                editSpecificationDialog.hasChanges = true
                                editSpecificationDialog.calculateEditCosts()
                            }

                            background: Rectangle {
                                color: "white"
                                border.color: editOverheadField.activeFocus ? "#9b59b6" : "#d0d0d0"
                                border.width: editOverheadField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: "#e0e0e0"
                        }

                        Text {
                            text: "Материалы:"
                            font.pointSize: 10
                            color: "#666"
                        }
                        Text {
                            text: editSpecificationDialog.materialsCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: "Работа:"
                            font.pointSize: 10
                            color: "#666"
                        }
                        Text {
                            text: editSpecificationDialog.laborCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: "Накладные:"
                            font.pointSize: 10
                            color: "#666"
                        }
                        Text {
                            text: editSpecificationDialog.overheadCost.toFixed(2) + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.fillWidth: true
                            color: "#2c3e50"
                        }

                        Rectangle {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            height: 2
                            color: "#28a745"
                        }

                        Text {
                            text: "ИТОГО:"
                            font.pointSize: 12
                            font.bold: true
                            color: "#28a745"
                        }
                        Text {
                            text: editSpecificationDialog.totalCost.toFixed(2) + " ₽"
                            font.pointSize: 14
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
                text: "💾 Сохранить изменения"
                enabled: editNameField.text.trim().length > 0 && editItemsTable.rowCount > 0

                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#cccccc"
                        if (parent.down) return "#218838"
                        if (parent.hovered) return "#1e7e34"
                        return "#28a745"
                    }
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : "#999"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: editSpecificationDialog.saveChanges()
            }

            Button {
                text: "❌ Отмена"

                background: Rectangle {
                    color: parent.down ? "#5a6268" : (parent.hovered ? "#545b62" : "#6c757d")
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (editSpecificationDialog.hasChanges) {
                        confirmCancelEditDialog.open()
                    } else {
                        editSpecificationDialog.close()
                    }
                }
            }
        }
    }

    // ========================================
    // CONFIRMATION DIALOGS
    // ========================================
    Dialog {
        id: confirmCancelEditDialog
        title: "Подтверждение"
        modal: true
        width: 400
        height: 150
        anchors.centerIn: parent

        contentItem: Text {
            text: "У вас есть несохраненные изменения.\nВыйти без сохранения?"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent
            padding: 20
        }

        footer: DialogButtonBox {
            Button {
                text: "Да, выйти"
                onClicked: {
                    confirmCancelEditDialog.close()
                    editSpecificationDialog.close()
                }

                background: Rectangle {
                    color: parent.down ? "#c82333" : (parent.hovered ? "#bd2130" : "#dc3545")
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
                onClicked: confirmCancelEditDialog.close()

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

    Dialog {
        id: deleteConfirmDialog
        title: "Подтверждение удаления"
        modal: true
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

        footer: DialogButtonBox {
            Button {
                text: "Да, удалить"
                onClicked: {
                    if (specificationsModel.deleteSpecification(deleteConfirmDialog.specId)) {
                        loadSpecifications()
                        successMessage.text = "Спецификация успешно удалена"
                        successMessage.open()
                    }
                    deleteConfirmDialog.close()
                }

                background: Rectangle {
                    color: parent.down ? "#c82333" : (parent.hovered ? "#bd2130" : "#dc3545")
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
                onClicked: deleteConfirmDialog.close()

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

    // ========================================
    // MESSAGE DIALOGS
    // ========================================
    Dialog {
        id: successMessage
        title: "✅ Успех"
        modal: true
        width: 350
        height: 200
        anchors.centerIn: parent

        property alias text: messageText.text

        contentItem: Text {
            id: messageText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.pointSize: 10
        }

        footer: DialogButtonBox {
            Button {
                text: "OK"
                onClicked: successMessage.close()

                background: Rectangle {
                    color: parent.down ? "#218838" : (parent.hovered ? "#1e7e34" : "#28a745")
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

    Dialog {
        id: errorMessage
        title: "❌ Ошибка"
        modal: true
        width: 350
        height: 120
        anchors.centerIn: parent

        property alias text: errorMessageText.text

        contentItem: Text {
            id: errorMessageText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.pointSize: 10
            color: "#dc3545"
        }

        footer: DialogButtonBox {
            Button {
                text: "OK"
                onClicked: errorMessage.close()

                background: Rectangle {
                    color: parent.down ? "#c82333" : (parent.hovered ? "#bd2130" : "#dc3545")
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
}