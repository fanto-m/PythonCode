// EditUserDialog.qml - Диалог редактирования пользователя
// Расположение: src/qml/components/dialogs/users/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Редактировать пользователя"
    modal: true
    anchors.centerIn: parent
    width: 400

    // Свойства пользователя
    property int userId: 0
    property string username: ""
    property string userRole: "user"
    property bool isActive: true

    // Сигнал успешного сохранения
    signal userUpdated()

    background: Rectangle {
        color: "white"
        radius: Theme.defaultRadius
        border.color: Theme.primaryColor
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        AppLabel {
            text: "Пользователь: " + root.username
            level: "h3"
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
                currentIndex: model.indexOf(root.userRole)
            }
        }

        // Статус
        AppCheckBox {
            id: activeCheckBox
            text: "Активен"
            checked: root.isActive
        }
    }

    footer: DialogButtonBox {
        AppButton {
            text: "Сохранить"
            btnColor: Theme.primaryColor
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
        AppButton {
            text: "Отмена"
            btnColor: Theme.inputBorderHover
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    onAccepted: {
        if (typeof authManager !== "undefined" && authManager) {
            authManager.updateUser(
                root.userId,
                roleComboBox.currentText,
                activeCheckBox.checked
            )
            root.userUpdated()
        }
    }

    // Установка данных пользователя
    function setUser(id, name, role, active) {
        userId = id
        username = name
        userRole = role
        isActive = active
        roleComboBox.currentIndex = roleComboBox.model.indexOf(role)
        activeCheckBox.checked = active
    }
}
