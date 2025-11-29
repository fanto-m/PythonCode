// DeleteConfirmationDialog.qml - Диалог подтверждения удаления товара
// Расположение: qml/components/dialogs/items/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Подтверждение удаления"
    modal: true
    width: 500
    height: 400
    anchors.centerIn: parent

    // === СИГНАЛЫ ===
    signal confirmed(int itemIndex)

    // === СВОЙСТВА ===
    property int itemIndex: -1
    property string itemName: ""
    property string itemArticle: ""

    // === ФУНКЦИИ ===
    function openFor(index, name, article) {
        itemIndex = index
        itemName = name
        itemArticle = article
        open()
    }

    // === ЗАГОЛОВОК ===
    header: Item {
        height: 50

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 8
            color: "white"
            radius: Theme.smallRadius

            AppLabel {
                text: root.title
                level: "h3"
                anchors.centerIn: parent
                enterDelay: 0
            }

            // Нижняя граница заголовка
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                height: 1
                color: Theme.inputBorder
            }
        }
    }

    // === ОСНОВНОЙ КОНТЕНТ ===
    contentItem: Rectangle {
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 14

            // Иконка предупреждения
            AppLabel {
                text: "⚠️"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
                enterDelay: 0
            }

            // Основной текст
            AppLabel {
                text: "Вы уверены, что хотите удалить эту позицию?"
                level: "h3"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                enterDelay: 0
            }

            // Информация о товаре
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: Theme.backgroundColor
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    AppLabel {
                        text: "Название: " + itemName
                        level: "body"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        enterDelay: 0
                    }

                    AppLabel {
                        text: "Артикул: " + itemArticle
                        level: "body"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        enterDelay: 0
                    }
                }
            }

            // Предупреждение
            AppLabel {
                text: "Это действие нельзя отменить!"
                level: "caption"
                font.italic: true
                color: Theme.errorColor
                Layout.alignment: Qt.AlignHCenter
                enterDelay: 0
            }
        }
    }

    // === КНОПКИ ===
    footer: Item {
        height: 65

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 8
            color: Theme.backgroundColor
            radius: Theme.smallRadius

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                // Кнопка "Отмена"
                AppButton {
                    text: "Отмена"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    btnColor: Theme.backgroundColor
                    enterDelay: 0

                    contentItem: Text {
                        text: parent.text
                        font: Theme.defaultFont
                        color: Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                        border.color: Theme.inputBorder
                        border.width: 1
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    onClicked: root.close()
                }

                // Кнопка "Удалить"
                AppButton {
                    text: "🗑️ Удалить"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    btnColor: Theme.errorColor
                    enterDelay: 0

                    contentItem: Text {
                        text: parent.text
                        font: Theme.boldFont
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        root.confirmed(itemIndex)
                        root.close()
                    }
                }
            }
        }
    }

    // === АНИМАЦИИ ===
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
