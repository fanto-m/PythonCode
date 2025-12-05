// AddUserDialog.qml - Диалог добавления пользователя
// Расположение: src/qml/components/dialogs/users/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Добавить пользователя"
    modal: true
    anchors.centerIn: parent
    width: 400

    // Сигнал успешного создания
    signal userCreated()

    // Проверка совпадения паролей
    property bool passwordsMatch: passwordField.text !== "" &&
                                  passwordField.text === confirmPasswordField.text

    background: Rectangle {
        color: "white"
        radius: Theme.defaultRadius
        border.color: Theme.successColor
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Имя пользователя
        Column {
            Layout.fillWidth: true
            spacing: 5

            AppLabel { text: "Имя пользователя"; level: "caption" }
            AppTextField {
                id: usernameField
                width: parent.width
                placeholderText: "Введите имя"
            }
        }

        // Пароль
        Column {
            Layout.fillWidth: true
            spacing: 5

            AppLabel { text: "Пароль"; level: "caption" }
            AppTextField {
                id: passwordField
                width: parent.width
                placeholderText: "Введите пароль"
                echoMode: TextInput.Password
            }
        }

        // Подтверждение пароля
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

            // Подсказка о совпадении
            AppLabel {
                text: confirmPasswordField.text === "" ? "" :
                      root.passwordsMatch ? "✅ Пароли совпадают" : "❌ Пароли не совпадают"
                level: "caption"
                color: root.passwordsMatch ? Theme.successColor : Theme.errorColor
                visible: confirmPasswordField.text !== ""
            }
        }

        // Роль
        Column {
            Layout.fillWidth: true
            spacing: 5

            AppLabel { text: "Роль"; level: "caption" }
            AppComboBox {
                id: roleComboBox
                width: parent.width
                model: ["user", "manager", "admin"]
                currentIndex: 0
            }
        }
    }

    footer: DialogButtonBox {
        AppButton {
            text: "Создать"
            btnColor: Theme.successColor
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            enabled: usernameField.text.trim() !== "" && root.passwordsMatch
        }
        AppButton {
            text: "Отмена"
            btnColor: Theme.inputBorderHover
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    onAccepted: {
        if (typeof authManager !== "undefined" && authManager) {
            var success = authManager.createUser(
                usernameField.text.trim(),
                passwordField.text,
                roleComboBox.currentText
            )
            if (success) {
                root.userCreated()
            }
        }
        clearFields()
    }

    onRejected: {
        clearFields()
    }

    function clearFields() {
        usernameField.text = ""
        passwordField.text = ""
        confirmPasswordField.text = ""
        roleComboBox.currentIndex = 0
    }
}
