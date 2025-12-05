// DeleteUserDialog.qml - Диалог полного удаления пользователя
// Расположение: src/qml/components/dialogs/users/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Удалить пользователя навсегда"
    modal: true
    anchors.centerIn: parent
    width: 450

    // Свойства пользователя
    property int userId: 0
    property string username: ""

    // Сигнал успешного удаления
    signal userDeleted()

    background: Rectangle {
        color: "white"
        radius: Theme.defaultRadius
        border.color: Theme.errorColor
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        AppLabel {
            text: "⚠️ ВНИМАНИЕ! Полное удаление!"
            level: "h3"
            color: Theme.errorColor
        }

        AppLabel {
            text: "Вы уверены, что хотите ПОЛНОСТЬЮ удалить пользователя \"" +
                  root.username + "\"?\n\n" +
                  "Будут удалены:\n" +
                  "• Учётная запись пользователя\n" +
                  "• Вся история входов\n\n" +
                  "Это действие НЕОБРАТИМО!"
            level: "body"
            Layout.fillWidth: true
            lineHeight: 1.3
        }

        // Поле подтверждения
        Column {
            Layout.fillWidth: true
            spacing: 5

            AppLabel {
                text: "Введите имя пользователя для подтверждения:"
                level: "caption"
            }

            AppTextField {
                id: confirmField
                width: parent.width
                placeholderText: root.username
            }
        }
    }

    footer: DialogButtonBox {
        AppButton {
            text: "Удалить навсегда"
            btnColor: Theme.errorColor
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            enabled: confirmField.text === root.username
        }
        AppButton {
            text: "Отмена"
            btnColor: Theme.inputBorderHover
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    onAccepted: {
        if (typeof authManager !== "undefined" && authManager) {
            authManager.deleteUserPermanently(root.userId)
            root.userDeleted()
        }
        confirmField.text = ""
    }

    onRejected: {
        confirmField.text = ""
    }

    // Установка данных пользователя
    function setUser(id, name) {
        userId = id
        username = name
        confirmField.text = ""
    }
}
