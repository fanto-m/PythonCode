// ViewWarehouseScreen.qml - Экран просмотра склада
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"
import "../components/tables"

Rectangle {
    id: root
    color: Theme.backgroundColor

    signal backToMain()

    // Свойства для связи с внешними моделями
    property var itemsModel

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
                anchors.margins: Theme.defaultSpacing
                spacing: 15

                Button {
                    text: "← Главное меню"
                    focusPolicy: Qt.NoFocus
                    onClicked: root.backToMain()

                    background: Rectangle {
                        color: parent.down ? Theme.viewModeDark : (parent.hovered ? Theme.menuTitleColor : "transparent")
                        radius: Theme.smallRadius
                        border.color: Theme.textOnPrimary
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.textOnPrimary
                        font: Theme.defaultFont
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
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

        // === FILTER PANEL ===
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
                running: root.visible
                onTriggered: {
                    dateTimeText.text = Qt.formatDateTime(new Date(), "dd.MM.yyyy HH:mm:ss")
                }
            }

            // Поиск
            AppTextField {
                id: viewFilterField
                placeholderText: "Поиск по складу..."
                Layout.fillWidth: true
                enterDelay: 0
                onTextChanged: {
                    if (root.itemsModel) {
                        root.itemsModel.setFilterString(text)
                    }
                }
            }

            // Фильтр по полю
            AppComboBox {
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
                Layout.preferredHeight: 40
                currentIndex: 0
                onCurrentValueChanged: {
                    if (root.itemsModel) {
                        root.itemsModel.setFilterField(currentValue)
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
            model: root.itemsModel
            readOnly: true
        }
    }
}
