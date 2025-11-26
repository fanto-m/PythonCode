// qml/components/FilterPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import "../../styles"
import "../common"

Rectangle {
    id: filterPanel
    Layout.fillWidth: true
    Layout.preferredHeight: 60
    Layout.topMargin: 5
    Layout.leftMargin: 5
    Layout.rightMargin: 5

    color: Theme.backgroundColor
    border.color: Theme.dividerColor
    border.width: 1
    radius: Theme.smallRadius

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Часы
        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            color: "white"
            border.color: Theme.dividerColor
            radius: Theme.smallRadius

            AppLabel {
                id: dateTimeText
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                level: "body"
                font.bold: true
                color: Theme.textSecondary
            }

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    dateTimeText.text = Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                }
            }
        }

        // Поле поиска
        AppTextField {
            id: filterField
            placeholderText: "Введите запрос для фильтрации..."
            Layout.fillWidth: true
            Layout.fillHeight: true

            onTextChanged: {
                consoleHandler.log("Filter text changed to: " + text)
                itemsModel.setFilterString(text)
            }

            Component.onCompleted: {
                text = itemsModel.filterString
            }
        }

        // Выбор поля фильтрации
        ComboBox {
            id: filterComboBox
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            textRole: "display"
            valueRole: "value"

            model: [
                { display: "Название", value: "name" },
                { display: "Артикул", value: "article" },
                { display: "Описание", value: "description" },
                { display: "Категория", value: "category" },
                { display: "Производитель", value: "manufacturer" }
            ]

            background: Rectangle {
                color: "white"
                border.color: filterComboBox.pressed ? Theme.accentColor : Theme.dividerColor
                border.width: 1
                radius: Theme.smallRadius
            }

            contentItem: Text {
                text: filterComboBox.displayText
                font: Theme.defaultFont
                color: Theme.textColor
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }

            onCurrentValueChanged: {
                consoleHandler.log("Filter field changed to: " + currentValue)
                itemsModel.setFilterField(currentValue)
            }

            Component.onCompleted: {
                currentIndex = getIndexByValue(itemsModel.filterField)
            }

            function getIndexByValue(value) {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === value) {
                        return i
                    }
                }
                return 0
            }
        }

        // Выбор статуса товара
        ComboBox {
            id: statusComboBox
            Layout.preferredWidth: 180
            Layout.fillHeight: true

            model: ["Все", "в наличии", "под заказ", "нет в наличии", "снят с производства"]

            background: Rectangle {
                color: "white"
                border.color: statusComboBox.pressed ? Theme.accentColor : Theme.dividerColor
                border.width: 1
                radius: Theme.smallRadius
            }

            contentItem: Text {
                text: statusComboBox.displayText
                font: Theme.defaultFont
                color: Theme.textColor
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }

            onCurrentTextChanged: {
                itemsModel.setStatusFilter(currentText)
            }
        }

        // Кнопка сортировки
        AppButton {
            id: sortButton
            text: sortAscending ? "↑ Сортировать" : "↓ Сортировать"
            btnColor: "white"
            Layout.preferredWidth: 150
            Layout.fillHeight: true

            property bool sortAscending: true

            onClicked: {
                let field = filterComboBox.currentValue
                let order = sortAscending ? "ascending" : "descending"
                consoleHandler.log("Sorting by " + field + " (" + order + ")")
                itemsModel.setSort(field, order)
                sortAscending = !sortAscending
            }

            background: Rectangle {
                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "white")
                border.color: Theme.dividerColor
                border.width: 1
                radius: Theme.smallRadius
            }

            contentItem: Text {
                text: parent.text
                font: Theme.defaultFont
                color: Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Кнопка очистки
        AppButton {
            text: "Очистить"
            btnColor: "white"
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            enabled: filterField.text !== "" || statusComboBox.currentIndex !== 0

            onClicked: {
                filterField.text = ""
                filterComboBox.currentIndex = 0
                statusComboBox.currentIndex = 0  // Сбросить статус
            }

            background: Rectangle {
                color: parent.enabled ? (parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "white")) : "#e9ecef"
                border.color: Theme.dividerColor
                border.width: 1
                radius: Theme.smallRadius
            }

            contentItem: Text {
                text: parent.text
                font: Theme.defaultFont
                color: parent.enabled ? Theme.textSecondary : "#adb5bd"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
