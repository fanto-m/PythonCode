// ViewSpecificationsMode.qml - Главный файл (рефакторинг с разделением на компоненты)
// Расположение: src/qml/components/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Local  // Доступ к старым компонентам (AddItemDialog, SpecificationItemsTable)

Rectangle {
    id: root
    color: "#f5f5f5"

    signal backToMain()
    signal editSpecification(int specId)

    property var allSpecifications: []
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
            editDialog.hasChanges = true
            editDialog.calculateEditCosts()
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

        // HEADER
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

        // SEARCH BAR
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

                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.fillHeight: true
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    color: "#d0d0d0"
                }

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

                        onCheckedChanged: {
                            root.useLandscapeOrientation = checked
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

        // LIST
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

                delegate: SpecificationCard {
                    specId: model.id
                    specName: model.name
                    specDescription: model.description
                    specStatus: model.status
                    laborCost: model.labor_cost
                    overheadPercentage: model.overhead_percentage
                    finalPrice: model.final_price
                    createdDate: model.created_date
                    modifiedDate: model.modified_date
                    useLandscapeOrientation: root.useLandscapeOrientation

                    onViewDetails: {
                        detailsDialog.openFor(
                            model.id, model.name, model.description, model.status,
                            model.labor_cost, model.overhead_percentage, model.final_price,
                            model.created_date, model.modified_date
                        )
                    }

                    onEditClicked: {
                        editDialog.openFor(model.id)
                    }

                    onExportExcel: {
                        specificationsModel.exportToExcel(model.id)
                    }

                    onExportPDF: {
                        specificationsModel.exportToPDF(model.id, root.useLandscapeOrientation)
                    }

                    onDeleteClicked: {
                        deleteConfirmDialog.openFor(model.id, model.name)
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: "Нет спецификаций"
                    font.pointSize: 14
                    color: "#999"
                    visible: specificationsListView.count === 0
                }
            }
        }
    }

    // DIALOGS
    SpecificationDetailsDialog {
        id: detailsDialog
    }

    SpecificationEditDialog {
        id: editDialog
        onSpecificationSaved: {
            loadSpecifications()
            successMessage.text = "Спецификация успешно обновлена!"
            successMessage.open()
        }
        onSaveError: function(errorText) {
            errorMessage.text = errorText
            errorMessage.open()
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

    // TODO: Добавить остальные диалоги из оригинала
    // (из-за ограничения размера файла создайте их отдельно)
}
