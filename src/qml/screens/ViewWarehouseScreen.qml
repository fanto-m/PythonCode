// ViewWarehouseScreen.qml - Экран просмотра склада
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"
import "../components/tables"

Item {
    id: root

    signal backToMain()

    // Флаг активности экрана (для таймера)
    property bool isActive: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // === HEADER ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Theme.viewModeColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                AppButton {
                    text: "← Главное меню"
                    btnColor: "transparent"
                    implicitHeight: 40
                    enterDelay: 0

                    background: Rectangle {
                        color: parent.down ? Theme.viewModeDark :
                               (parent.hovered ? Qt.lighter(Theme.viewModeColor, 1.1) : "transparent")
                        radius: Theme.smallRadius
                        border.color: Theme.textOnPrimary
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    onClicked: root.backToMain()
                }

                Text {
                    text: "Просмотр склада"
                    font: Theme.headerFont
                    color: Theme.textOnPrimary
                    Layout.fillWidth: true
                }

                Text {
                    text: "👁️"
                    font.pixelSize: 24
                }
            }
        }

        // === FILTER PANEL (Simplified) ===
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            spacing: 10

            // Дата и время
            Text {
                id: dateTimeText
                text: Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                font: Theme.defaultFont
                color: Theme.textSecondary
                verticalAlignment: Text.AlignVCenter
            }

            Timer {
                interval: 1000
                repeat: true
                running: root.isActive
                onTriggered: {
                    dateTimeText.text = Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                }
            }

            // Поле поиска
            TextField {
                id: viewFilterField
                placeholderText: "Поиск по складу..."
                Layout.fillWidth: true
                onTextChanged: {
                    if (typeof itemsModel !== "undefined" && itemsModel) {
                        itemsModel.setFilterString(text)
                    }
                }
            }

            // Выбор поля фильтрации
            ComboBox {
                id: viewFilterComboBox
                textRole: "display"
                valueRole: "value"
                model: [
                    { display: "Название", value: "name" },
                    { display: "Артикул", value: "article" },
                    { display: "Описание", value: "description" },
                    { display: "Категория", value: "category" },
                    { display: "Цена", value: "price" },
                    { display: "Остаток", value: "stock" }
                ]
                Layout.preferredWidth: 200
                currentIndex: 0
                onCurrentValueChanged: {
                    if (typeof itemsModel !== "undefined" && itemsModel) {
                        itemsModel.setFilterField(currentValue)
                    }
                }
            }
        }

        // === ITEMS LIST (Read-Only) ===
        ItemList {
            id: viewItemList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            model: itemsModel
            readOnly: true
        }
    }
}
