// ViewSpecificationsMode.qml - Главный файл режима просмотра спецификаций
// Расположение: src/qml/components/dialogs/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common" as Common
import "../items" as ItemDialogs  // Для AddItemDialog
import "../../../tables" as Tables  // Для SpecificationItemsTable

Rectangle {
    id: root
    color: Theme.backgroundColor

    signal backToMain()
    signal editSpecification(int specId)

    property var allSpecifications: []
    property bool useLandscapeOrientation: false

    ListModel {
        id: specificationsListModel
    }

    // Диалог добавления товара
    ItemDialogs.AddItemDialog {
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

        // === HEADER ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#9b59b6"  // Фиолетовый для спецификаций

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                // Кнопка "Назад"
                Common.AppButton {
                    text: "← Главное меню"
                    btnColor: "transparent"
                    implicitHeight: 40
                    animateEntry: false
                    onClicked: backToMain()

                    background: Rectangle {
                        color: parent.down ? "#8e44ad" : (parent.hovered ? "#2c3e50" : "transparent")
                        radius: Theme.smallRadius
                        border.color: Theme.textOnPrimary
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                // Заголовок
                Text {
                    text: "Просмотр спецификаций"
                    font.pixelSize: Theme.sizeH2
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textOnPrimary
                    Layout.fillWidth: true
                }

                // Кнопка обновления
                Common.AppButton {
                    text: "🔄 Обновить"
                    btnColor: "transparent"
                    animateEntry: false
                    onClicked: loadSpecifications()

                    background: Rectangle {
                        color: parent.down ? "#8e44ad" : (parent.hovered ? "#2c3e50" : "transparent")
                        radius: Theme.smallRadius
                        border.color: Theme.textOnPrimary
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                // Иконка
                Text {
                    text: "📋"
                    font.pixelSize: 24
                }
            }
        }

        // === SEARCH BAR ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "white"
            border.color: Theme.inputBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Поиск:"
                    font: Theme.defaultFont
                    color: Theme.textColor
                }

                Common.AppTextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Введите название спецификации..."
                    enterDelay: 0
                    onTextChanged: filterSpecifications()
                }

                Common.AppComboBox {
                    id: statusFilterCombo
                    model: ["Все", "черновик", "утверждена", "архив"]
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 40
                    currentIndex: 0
                    onCurrentIndexChanged: filterSpecifications()
                }

                // Разделитель
                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.fillHeight: true
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    color: Theme.dividerColor
                }

                // Настройка PDF
                RowLayout {
                    spacing: 5

                    Text {
                        text: "📄 PDF:"
                        font.pixelSize: Theme.sizeSmall
                        font.family: Theme.defaultFont.family
                        color: Theme.textSecondary
                    }

                    Common.AppCheckBox {
                        id: landscapeCheckBox
                        text: "Альбомная"
                        checked: root.useLandscapeOrientation

                        onCheckedChanged: {
                            root.useLandscapeOrientation = checked
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: "Использовать альбомную ориентацию для экспорта PDF"
                        ToolTip.delay: 500
                    }
                }

                // Счётчик
                Text {
                    text: "Всего: " + specificationsListView.count
                    font: Theme.defaultFont
                    color: Theme.textSecondary
                }
            }
        }

        // === LIST ===
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
                    id: cardDelegate

                    // Передаём данные из модели
                    specId: model.id ?? 0
                    specName: model.name ?? ""
                    specDescription: model.description ?? ""
                    specStatus: model.status ?? ""
                    laborCost: model.labor_cost ?? 0
                    overheadPercentage: model.overhead_percentage ?? 0
                    finalPrice: model.final_price ?? 0
                    createdDate: model.created_date ?? ""
                    modifiedDate: model.modified_date ?? ""
                    useLandscapeOrientation: root.useLandscapeOrientation

                    onViewDetails: {
                        detailsDialog.openFor(
                            cardDelegate.specId,
                            cardDelegate.specName,
                            cardDelegate.specDescription,
                            cardDelegate.specStatus,
                            cardDelegate.laborCost,
                            cardDelegate.overheadPercentage,
                            cardDelegate.finalPrice,
                            cardDelegate.createdDate,
                            cardDelegate.modifiedDate
                        )
                    }

                    onEditClicked: {
                        editDialog.openFor(cardDelegate.specId)
                    }

                    onExportExcel: {
                        specificationsModel.exportToExcel(cardDelegate.specId)
                    }

                    onExportPDF: {
                        specificationsModel.exportToPDF(cardDelegate.specId, root.useLandscapeOrientation)
                    }

                    onDeleteClicked: {
                        deleteConfirmDialog.openFor(cardDelegate.specId, cardDelegate.specName)
                    }
                }

                // Пустой список
                Text {
                    anchors.centerIn: parent
                    text: "Нет спецификаций"
                    font.pixelSize: Theme.sizeH3
                    font.family: Theme.defaultFont.family
                    color: Theme.inputBorder
                    visible: specificationsListView.count === 0
                }
            }
        }
    }

    // === DIALOGS ===
    SpecificationDetailsDialog {
        id: detailsDialog
    }

    SpecificationEditDialog {
        id: editDialog
        onSpecificationSaved: {
            loadSpecifications()
            notificationDialog.showSuccess("Спецификация успешно обновлена!")
        }
        onSaveError: function(errorText) {
            notificationDialog.showError(errorText)
        }
    }

    // === ДИАЛОГ УДАЛЕНИЯ ===
    Dialog {
        id: deleteConfirmDialog
        title: "Подтверждение удаления"
        modal: true
        width: 400
        anchors.centerIn: parent

        property int specId: -1
        property string specName: ""

        function openFor(id, name) {
            specId = id
            specName = name
            open()
        }

        background: Rectangle {
            color: "white"
            border.color: Theme.errorColor
            border.width: 2
            radius: Theme.defaultRadius
        }

        contentItem: ColumnLayout {
            spacing: 15
            anchors.margins: 20

            Text {
                text: "🗑️"
                font.pixelSize: 32
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Вы уверены, что хотите удалить спецификацию\n\"" + deleteConfirmDialog.specName + "\"?\n\nЭто действие нельзя отменить."
                font: Theme.defaultFont
                color: Theme.textColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        footer: DialogButtonBox {
            alignment: Qt.AlignCenter
            spacing: 10
            padding: 12

            background: Rectangle {
                color: Theme.backgroundColor
                radius: Theme.smallRadius
            }

            Common.AppButton {
                text: "Да, удалить"
                btnColor: Theme.errorColor
                animateEntry: false
                onClicked: {
                    if (specificationsModel.deleteSpecification(deleteConfirmDialog.specId)) {
                        loadSpecifications()
                        notificationDialog.showSuccess("Спецификация успешно удалена")
                    } else {
                        notificationDialog.showError("Ошибка при удалении спецификации")
                    }
                    deleteConfirmDialog.close()
                }
            }

            Common.AppButton {
                text: "Отмена"
                btnColor: Theme.textSecondary
                animateEntry: false
                onClicked: deleteConfirmDialog.close()
            }
        }

        // Анимации
        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
        }

        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
                NumberAnimation { property: "scale"; from: 1; to: 0.9; duration: 150; easing.type: Easing.InCubic }
            }
        }
    }

    // === NOTIFICATION DIALOG ===
    Common.NotificationDialog {
        id: notificationDialog
    }
}
