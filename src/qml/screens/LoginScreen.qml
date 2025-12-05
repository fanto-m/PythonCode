// LoginScreen.qml - Экран авторизации
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Item {
    id: root

    signal loginSuccessful()

    // Модель пользователей
    ListModel { id: usersModel }

    // Фон с градиентом
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.menuGradientTop }
            GradientStop { position: 1.0; color: Theme.menuGradientBottom }
        }
    }

    // Центральная форма
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 400
        height: 520
        radius: Theme.defaultRadius
        color: "white"
        border.color: Theme.inputBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 16

            // Иконка
            Text {
                text: "🔐"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }

            // Заголовок
            Text {
                text: "Вход в систему"
                font.family: Theme.defaultFont.family
                font.pixelSize: Theme.sizeH2
                font.bold: true
                color: Theme.menuTitleColor
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Система управления складом"
                font.pixelSize: Theme.sizeCaption
                color: Theme.textMuted
                Layout.alignment: Qt.AlignHCenter
            }

            // Разделитель
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.dividerColor
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            // Выбор пользователя
            Column {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "Пользователь"
                    font: Theme.defaultFont
                    color: Theme.textSecondary
                }

                ComboBox {
                    id: userComboBox
                    width: parent.width
                    height: 45
                    model: usersModel
                    textRole: "username"
                    editable: true

                    background: Rectangle {
                        radius: Theme.smallRadius
                        color: "white"
                        border.color: userComboBox.activeFocus ? Theme.accentColor : Theme.inputBorder
                        border.width: userComboBox.activeFocus ? 2 : 1
                    }

                    contentItem: TextInput {
                        leftPadding: 12
                        rightPadding: 30
                        text: userComboBox.editText
                        font: Theme.defaultFont
                        color: Theme.textColor
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: true

                        onAccepted: passwordField.focus = true
                    }

                    indicator: Text {
                        x: userComboBox.width - width - 12
                        y: (userComboBox.height - height) / 2
                        text: "▼"
                        font.pixelSize: 10
                        color: Theme.textSecondary
                    }

                    delegate: ItemDelegate {
                        width: userComboBox.width
                        height: 45

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: model.role === "admin" ? "👑" :
                                      model.role === "manager" ? "📋" : "👤"
                                font.pixelSize: 16
                            }

                            Text {
                                text: model.username
                                font: Theme.defaultFont
                                color: Theme.textColor
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.role === "admin" ? "админ" :
                                      model.role === "manager" ? "менеджер" : ""
                                font.pixelSize: Theme.sizeSmall
                                color: Theme.textMuted
                                visible: model.role !== "user"
                            }
                        }

                        highlighted: userComboBox.highlightedIndex === index

                        background: Rectangle {
                            color: highlighted ? Theme.tableRowHover :
                                   (index % 2 === 0 ? "white" : "#f8f8f8")
                        }
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && usersModel.count > 0) {
                            editText = usersModel.get(currentIndex).username
                        }
                    }
                }
            }

            // Поле пароля
            Column {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "Пароль"
                    font: Theme.defaultFont
                    color: Theme.textSecondary
                }

                TextField {
                    id: passwordField
                    width: parent.width
                    height: 45
                    placeholderText: "Введите пароль"
                    echoMode: TextInput.Password
                    font: Theme.defaultFont
                    leftPadding: 12
                    rightPadding: 12

                    background: Rectangle {
                        radius: Theme.smallRadius
                        color: "white"
                        border.color: passwordField.activeFocus ? Theme.accentColor : Theme.inputBorder
                        border.width: passwordField.activeFocus ? 2 : 1

                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    onAccepted: loginButton.clicked()
                }
            }

            // Сообщение об ошибке
            Text {
                id: errorMessage
                Layout.fillWidth: true
                text: ""
                color: Theme.errorColor
                font.pixelSize: Theme.sizeCaption
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: text !== ""
            }

            // Кнопка входа
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.topMargin: 8
                text: "Войти"
                enabled: userComboBox.editText.trim() !== "" && passwordField.text !== ""

                background: Rectangle {
                    radius: Theme.defaultRadius
                    color: {
                        if (!loginButton.enabled) return "#cccccc"
                        if (loginButton.down) return Qt.darker(Theme.primaryColor, 1.2)
                        if (loginButton.hovered) return Qt.lighter(Theme.primaryColor, 1.1)
                        return Theme.primaryColor
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                contentItem: Text {
                    text: loginButton.text
                    font.family: Theme.defaultFont.family
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    color: loginButton.enabled ? Theme.textOnPrimary : "#888888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (typeof authManager !== "undefined" && authManager) {
                        errorMessage.text = ""
                        var success = authManager.login(
                            userComboBox.editText.trim(),
                            passwordField.text
                        )
                        if (success) {
                            passwordField.text = ""
                            root.loginSuccessful()
                        }
                    } else {
                        errorMessage.text = "Ошибка: AuthManager не инициализирован"
                    }
                }
            }

            // Пустое пространство
            Item { Layout.fillHeight: true }

            // Подсказка
            Text {
                text: "По умолчанию: admin / admin123"
                font.pixelSize: Theme.sizeSmall
                color: Theme.textMuted
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Подключение к AuthManager
    Connections {
        target: typeof authManager !== "undefined" ? authManager : null

        function onLoginFailed(reason) {
            errorMessage.text = reason
            passwordField.text = ""
            passwordField.focus = true
        }
    }

    // Загрузка списка пользователей
    function loadUsers() {
        usersModel.clear()
        if (typeof authManager !== "undefined" && authManager) {
            var users = authManager.getActiveUsers()
            for (var i = 0; i < users.length; i++) {
                usersModel.append(users[i])
            }
            // Выбираем первого пользователя по умолчанию
            if (usersModel.count > 0) {
                userComboBox.currentIndex = 0
            }
        }
    }

    Component.onCompleted: {
        loadUsers()
    }

    // Сброс формы
    function reset() {
        loadUsers()
        passwordField.text = ""
        errorMessage.text = ""
        if (usersModel.count > 0) {
            userComboBox.currentIndex = 0
        }
    }
}
