// components/FilterPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

Rectangle {
    id: filterPanel
    Layout.fillWidth: true
    Layout.preferredHeight: 60
    Layout.topMargin: 5
    Layout.leftMargin: 5
    Layout.rightMargin: 5

    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 1
    radius: 4

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            color: "white"
            border.color: "#ccc"
            radius: 3

            Text {
                id: dateTimeText
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                font.pixelSize: 13
                font.bold: true
                color: "#495057"
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

        TextField {
            id: filterField
            placeholderText: "Введите запрос для фильтрации..."
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: 12

            background: Rectangle {
                color: "white"
                border.color: filterField.activeFocus ? "#007bff" : "#ced4da"
                border.width: filterField.activeFocus ? 2 : 1
                radius: 4
            }

            onTextChanged: {
                consoleHandler.log("Filter text changed to: " + text)
                itemsModel.setFilterString(text)
            }

            Component.onCompleted: {
                text = itemsModel.filterString
            }
        }

        ComboBox {
            id: filterComboBox
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            textRole: "display"
            valueRole: "value"
            font.pixelSize: 12

            model: [
                { display: "Название", value: "name" },
                { display: "Артикул", value: "article" },
                { display: "Описание", value: "description" },
                { display: "Категория", value: "category" },
                { display: "Цена", value: "price" },
                { display: "Остаток", value: "stock" }
            ]

            background: Rectangle {
                color: "white"
                border.color: filterComboBox.pressed ? "#007bff" : "#ced4da"
                border.width: 1
                radius: 4
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

        Button {
            id: sortButton
            text: sortAscending ? "↑ Сортировать" : "↓ Сортировать"
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            property bool sortAscending: true

            onClicked: {
                let field = filterComboBox.currentValue
                let order = sortAscending ? "ascending" : "descending"
                consoleHandler.log("Sorting by " + field + " (" + order + ")")
                itemsModel.setSort(field, order)
                sortAscending = !sortAscending // Toggle sort order
            }

            background: Rectangle {
                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "white")
                border.color: "#ced4da"
                border.width: 1
                radius: 4
            }
        }

        Button {
            text: "Очистить"
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            enabled: filterField.text !== ""

            onClicked: {
                filterField.text = ""
                filterComboBox.currentIndex = 0
            }

            background: Rectangle {
                color: parent.enabled ? (parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "white")) : "#e9ecef"
                border.color: "#ced4da"
                border.width: 1
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 12
                color: parent.enabled ? "#495057" : "#adb5bd"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}