// ChangePasswordDialog.qml - Диалог смены пароля
// Расположение: src/qml/components/dialogs/users/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Сменить пароль"
    modal: true
    anchors.centerIn: parent
    width: 400

    // Свойства пользователя
    property int userId: 0
    property string username: ""

    // Проверка совпадения паролей
    property bool passwordsMatch: newPasswordField.text !== "" &&
                                  newPasswordField.text === confirmPasswordField.text

    // Сигнал успешной смены
    signal passwordChanged()

    background: Rectangle {
        color: "white"
        radius: Theme.defaultRadius
        border.color: Theme.warningColor
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        AppLabel {
            text: "Пользователь: " + root.username
            level: "h3"
        }

        Column {
            Layout.fillWidth: true
            spacing: 5

            AppLabel { text: "Новый пароль"; level: "caption" }
            AppTextField {
                id: newPasswordField
                width: parent.width
                placeholderText: "Введите новый пароль"
                echoMode: TextInput.Password
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: 5

            AppLabel { text: "Подтверждение пароля"; level: "caption" }
            AppTextField {
                id: confirmPasswordField
                width: parent.width
                placeholderText: "Повторите пароль"
                echoMode: TextInput.Password
            }

            AppLabel {
                text: confirmPasswordField.text === "" ? "" :
                      root.passwordsMatch ? "✅ Пароли совпадают" : "❌ Пароли не совпадают"
                level: "caption"
                color: root.passwordsMatch ? Theme.successColor : Theme.errorColor
                visible: confirmPasswordField.text !== ""
            }
        }
    }

    footer: DialogButtonBox {
        AppButton {
            text: "Сменить"
            btnColor: Theme.warningColor
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            enabled: root.passwordsMatch
        }
        AppButton {
            text: "Отмена"
            btnColor: Theme.inputBorderHover
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    onAccepted: {
        if (typeof authManager !== "undefined" && authManager) {
            authManager.changeUserPassword(root.userId, newPasswordField.text)
            root.passwordChanged()
        }
        clearFields()
    }

    onRejected: {
        clearFields()
    }

    function clearFields() {
        newPasswordField.text = ""
        confirmPasswordField.text = ""
    }

    // Установка данных пользователя
    function setUser(id, name) {
        userId = id
        username = name
        clearFields()
    }
}
