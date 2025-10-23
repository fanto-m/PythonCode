// components/DeleteConfirmationDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: deleteDialogInternal
    title: "Подтверждение удаления"
    modal: true
    width: 550
    height: 550

    signal confirmed(int itemIndex)

    property int itemIndex: -1
    property string itemName: ""
    property string itemArticle: ""

    function openFor(index, name, article) {
        itemIndex = index
        itemName = name
        itemArticle = article
        open()
    }

    // Основной контент
    contentItem: Rectangle {
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Иконка предупреждения
            Text {
                text: "⚠️"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }

            // Основной текст
            Text {
                text: "Вы уверены, что хотите удалить эту позицию?"
                font.pixelSize: 18
                font.bold: true
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: "#333"
            }

            // Информация о товаре
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#f8f9fa"
                border.color: "#dee2e6"
                border.width: 1
                radius: 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    Text {
                        text: "Название: " + itemName
                        font.pixelSize: 18
                        color: "#495057"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "Артикул: " + itemArticle
                        font.pixelSize: 18
                        color: "#495057"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // Предупреждение
            Text {
                text: "Это действие нельзя отменить!"
                font.pixelSize: 14
                font.italic: true
                color: "#dc3545"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Кнопки в footer
    footer: DialogButtonBox {
        Button {
            text: "Удалить"
            Layout.preferredHeight: 40
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            background: Rectangle {
                color: parent.down ? "#c82333" : (parent.hovered ? "#e02535" : "#dc3545")
                radius: 4
                border.color: "#bd2130"
                border.width: 1
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 12
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                confirmed(itemIndex)
                close()
            }
        }

        Button {
            text: "Отмена"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            background: Rectangle {
                color: parent.down ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "white")
                radius: 4
                border.color: "#ced4da"
                border.width: 1
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 12
                color: "#495057"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: close()
        }
    }
}