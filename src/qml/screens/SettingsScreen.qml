// SettingsScreen.qml - Экран настроек (только для admin)
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components/common"
import "../components/dialogs/users"

Item {
    id: root

    signal backToMain()

    // Текущая вкладка
    property int currentTab: 0  // 0 - Пользователи, 1 - История входов

    // === HEADER ===
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Theme.settingsColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 15

            // Кнопка возврата
            Button {
                implicitWidth: 140
                implicitHeight: 40
                text: "← Главное меню"

                background: Rectangle {
                    color: parent.down ? Theme.settingsDark :
                           (parent.hovered ? Qt.lighter(Theme.settingsColor, 1.1) : "transparent")
                    radius: Theme.smallRadius
                    border.color: Theme.textOnPrimary
                    border.width: 2
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                contentItem: Text {
                    text: parent.text
                    font: Theme.defaultFont
                    color: Theme.textOnPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.backToMain()
            }

            // Заголовок
            AppLabel {
                text: "⚙️ Настройки системы"
                level: "h3"
                color: Theme.textOnPrimary
                Layout.fillWidth: true
            }

            // Информация о пользователе
            AppLabel {
                text: "Администратор: " + (typeof authManager !== "undefined" ? authManager.currentUser : "")
                level: "body"
                color: Theme.textSubtitle
            }
        }
    }

    // === TABS ===
    Rectangle {
        id: tabBar
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: Theme.backgroundColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            spacing: 5

            // Вкладка "Пользователи"
            TabButton {
                text: "👥 Пользователи"
                isActive: root.currentTab === 0
                onClicked: root.currentTab = 0
            }

            // Вкладка "История входов"
            TabButton {
                text: "📋 История входов"
                isActive: root.currentTab === 1
                onClicked: root.currentTab = 1
            }

            Item { Layout.fillWidth: true }
        }
    }

    // === CONTENT ===
    StackLayout {
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 15
        currentIndex: root.currentTab

        // === Вкладка 0: Управление пользователями ===
        UserManagementPanel {
            id: userManagementPanel
        }

        // === Вкладка 1: История входов ===
        LoginHistoryPanel {
            id: loginHistoryPanel
        }
    }

    // === Компонент кнопки вкладки ===
    component TabButton: Button {
        id: tabBtn
        property bool isActive: false

        implicitWidth: 180
        implicitHeight: 40

        background: Rectangle {
            color: tabBtn.isActive ? Theme.primaryColor :
                   (tabBtn.hovered ? Theme.inputBorderHover : "transparent")
            radius: Theme.smallRadius

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        contentItem: Text {
            text: tabBtn.text
            font: Theme.defaultFont
            color: tabBtn.isActive ? Theme.textOnPrimary : Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // === Компонент панели управления пользователями ===
    component UserManagementPanel: Rectangle {
        color: "white"
        radius: Theme.defaultRadius
        border.color: Theme.inputBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // Заголовок и кнопка добавления
            RowLayout {
                Layout.fillWidth: true

                AppLabel {
                    text: "Список пользователей"
                    level: "h3"
                }

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "+ Добавить пользователя"
                    btnColor: Theme.successColor
                    onClicked: addUserDialog.open()
                }
            }

            // Заголовок таблицы
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: Theme.tableHeaderColor
                radius: Theme.smallRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 10

                    Text { text: "Имя"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 150 }
                    Text { text: "Роль"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 100 }
                    Text { text: "Статус"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 100 }
                    Text { text: "Создан"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 150 }
                    Item { Layout.fillWidth: true }
                    Text { text: "Действия"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 120 }
                }
            }

            // Список пользователей
            ListView {
                id: usersListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: ListModel { id: usersModel }

                delegate: Rectangle {
                    width: usersListView.width
                    height: 50
                    color: index % 2 === 0 ? Theme.tableRowEven : Theme.tableRowOdd
                    radius: Theme.smallRadius

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text {
                            text: model.username
                            font: Theme.defaultFont
                            color: Theme.textColor
                            Layout.preferredWidth: 150
                        }

                        Text {
                            text: model.role === "admin" ? "Администратор" :
                                  model.role === "manager" ? "Менеджер" : "Пользователь"
                            font: Theme.defaultFont
                            color: model.role === "admin" ? Theme.errorColor : Theme.textColor
                            Layout.preferredWidth: 100
                        }

                        Text {
                            text: model.is_active ? "✅ Активен" : "❌ Отключён"
                            font: Theme.defaultFont
                            color: model.is_active ? Theme.successColor : Theme.errorColor
                            Layout.preferredWidth: 100
                        }

                        Text {
                            text: model.created_at
                            font: Theme.smallFont
                            color: Theme.textSecondary
                            Layout.preferredWidth: 150
                        }

                        Item { Layout.fillWidth: true }

                        // Кнопки действий
                        RowLayout {
                            Layout.preferredWidth: 120
                            spacing: 5

                            // Редактировать
                            Button {
                                implicitWidth: 32
                                implicitHeight: 32
                                visible: model.username !== "admin"

                                background: Rectangle {
                                    color: parent.hovered ? Theme.primaryColor : "transparent"
                                    radius: Theme.smallRadius
                                }

                                contentItem: Text {
                                    text: "✏️"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    editUserDialog.setUser(model.id, model.username, model.role, model.is_active)
                                    editUserDialog.open()
                                }

                                ToolTip.visible: hovered
                                ToolTip.text: "Редактировать"
                            }

                            // Сменить пароль
                            Button {
                                implicitWidth: 32
                                implicitHeight: 32

                                background: Rectangle {
                                    color: parent.hovered ? Theme.warningColor : "transparent"
                                    radius: Theme.smallRadius
                                }

                                contentItem: Text {
                                    text: "🔑"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    changePasswordDialog.setUser(model.id, model.username)
                                    changePasswordDialog.open()
                                }

                                ToolTip.visible: hovered
                                ToolTip.text: "Сменить пароль"
                            }

                            // Удалить навсегда
                            Button {
                                implicitWidth: 32
                                implicitHeight: 32
                                visible: model.username !== "admin"

                                background: Rectangle {
                                    color: parent.hovered ? Theme.errorColor : "transparent"
                                    radius: Theme.smallRadius
                                }

                                contentItem: Text {
                                    text: "🗑️"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    deleteUserDialog.setUser(model.id, model.username)
                                    deleteUserDialog.open()
                                }

                                ToolTip.visible: hovered
                                ToolTip.text: "Удалить навсегда"
                            }
                        }
                    }
                }
            }
        }

        // Загрузка списка пользователей
        function loadUsers() {
            usersModel.clear()
            if (typeof authManager !== "undefined" && authManager) {
                var users = authManager.getUsers()
                for (var i = 0; i < users.length; i++) {
                    usersModel.append(users[i])
                }
            }
        }

        Component.onCompleted: loadUsers()
    }

    // === Компонент панели истории входов ===
    component LoginHistoryPanel: Rectangle {
        color: "white"
        radius: Theme.defaultRadius
        border.color: Theme.inputBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // Заголовок
            RowLayout {
                Layout.fillWidth: true

                AppLabel {
                    text: "История входов в систему"
                    level: "h3"
                }

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "🔄 Обновить"
                    btnColor: Theme.primaryColor
                    onClicked: loadHistory()
                }
            }

            // Заголовок таблицы
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: Theme.tableHeaderColor
                radius: Theme.smallRadius

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 10

                    Text { text: "Пользователь"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 150 }
                    Text { text: "Вход"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 150 }
                    Text { text: "Выход"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 150 }
                    Text { text: "Причина"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 120 }
                    Text { text: "Длительность"; font: Theme.boldFont; color: Theme.textOnPrimary; Layout.preferredWidth: 100 }
                    Item { Layout.fillWidth: true }
                }
            }

            // Список истории
            ListView {
                id: historyListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: ListModel { id: historyModel }

                delegate: Rectangle {
                    width: historyListView.width
                    height: 45
                    color: {
                        if (model.logout_reason && model.logout_reason.indexOf("ошибка") >= 0)
                            return "#ffebee"
                        return index % 2 === 0 ? Theme.tableRowEven : Theme.tableRowOdd
                    }
                    radius: Theme.smallRadius

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text {
                            text: model.username
                            font: Theme.defaultFont
                            color: Theme.textColor
                            Layout.preferredWidth: 150
                        }

                        Text {
                            text: model.login_time
                            font: Theme.smallFont
                            color: Theme.textColor
                            Layout.preferredWidth: 150
                        }

                        Text {
                            text: model.logout_time
                            font: Theme.smallFont
                            color: Theme.textSecondary
                            Layout.preferredWidth: 150
                        }

                        Text {
                            text: model.logout_reason
                            font: Theme.smallFont
                            color: {
                                if (model.logout_reason === "таймаут") return Theme.warningColor
                                if (model.logout_reason && model.logout_reason.indexOf("ошибка") >= 0) return Theme.errorColor
                                return Theme.textSecondary
                            }
                            Layout.preferredWidth: 120
                        }

                        Text {
                            text: model.duration
                            font: Theme.smallFont
                            color: Theme.textSecondary
                            Layout.preferredWidth: 100
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }

        // Загрузка истории
        function loadHistory() {
            historyModel.clear()
            if (typeof authManager !== "undefined" && authManager) {
                var history = authManager.getLoginHistory()
                for (var i = 0; i < history.length; i++) {
                    historyModel.append(history[i])
                }
            }
        }

        Component.onCompleted: loadHistory()
    }

    // === ДИАЛОГИ (импортированы из components/dialogs/users) ===

    AddUserDialog {
        id: addUserDialog
        onUserCreated: userManagementPanel.loadUsers()
    }

    EditUserDialog {
        id: editUserDialog
        onUserUpdated: userManagementPanel.loadUsers()
    }

    ChangePasswordDialog {
        id: changePasswordDialog
    }

    DeleteUserDialog {
        id: deleteUserDialog
        onUserDeleted: userManagementPanel.loadUsers()
    }

    // Обновление данных при переключении вкладок
    onCurrentTabChanged: {
        if (currentTab === 0) {
            userManagementPanel.loadUsers()
        } else if (currentTab === 1) {
            loginHistoryPanel.loadHistory()
        }
    }

    // Загрузка данных при открытии экрана
    onVisibleChanged: {
        if (visible) {
            if (currentTab === 0) {
                userManagementPanel.loadUsers()
            } else {
                loginHistoryPanel.loadHistory()
            }
        }
    }

    Component.onCompleted: {
        userManagementPanel.loadUsers()
    }
}
