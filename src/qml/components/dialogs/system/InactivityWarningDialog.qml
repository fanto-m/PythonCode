// InactivityWarningDialog.qml - Предупреждение о неактивности
// Расположение: src/qml/components/dialogs/system/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"

Dialog {
    id: root

    modal: true
    width: 400
    anchors.centerIn: parent
    closePolicy: Dialog.NoAutoClose  // Нельзя закрыть кликом снаружи

    property int secondsLeft: 120

    title: ""

    background: Rectangle {
        color: "white"
        border.color: Theme.warningColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Иконка и заголовок
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "⚠️"
                font.pixelSize: 32
            }

            Text {
                text: "Сессия истекает"
                font: Theme.headerFont
                color: Theme.warningColor
            }
        }

        // Сообщение
        Text {
            Layout.fillWidth: true
            text: "Вы будете автоматически выведены из системы из-за неактивности."
            font: Theme.defaultFont
            color: Theme.textColor
            wrapMode: Text.WordWrap
        }

        // Таймер
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Theme.backgroundColor
            radius: Theme.smallRadius

            Text {
                anchors.centerIn: parent
                text: formatTime(root.secondsLeft)
                font.pixelSize: 32
                font.bold: true
                color: root.secondsLeft <= 30 ? Theme.errorColor : Theme.warningColor
            }
        }

        // Подсказка
        Text {
            Layout.fillWidth: true
            text: "Нажмите «Продолжить», чтобы остаться в системе"
            font.pixelSize: Theme.sizeCaption
            color: Theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
        }
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignRight
        spacing: 10
        padding: 15

        background: Rectangle {
            color: Theme.backgroundColor
            radius: Theme.defaultRadius
        }

        // Кнопка "Продолжить работу"
        Button {
            text: "Продолжить работу"
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 40
                color: parent.down ? Qt.darker(Theme.successColor, 1.2) :
                       (parent.hovered ? Qt.lighter(Theme.successColor, 1.1) : Theme.successColor)
                radius: Theme.smallRadius
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: parent.text
                font: Theme.defaultFont
                color: Theme.textOnPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                if (typeof authManager !== "undefined" && authManager) {
                    authManager.resetInactivityTimer()
                }
                root.close()
            }
        }

        // Кнопка "Выйти"
        Button {
            text: "Выйти"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                border.color: Theme.inputBorder
                radius: Theme.smallRadius
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: parent.text
                font: Theme.defaultFont
                color: Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                if (typeof authManager !== "undefined" && authManager) {
                    authManager.logout("manual")
                }
                root.close()
            }
        }
    }

    // Форматирование времени MM:SS
    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = seconds % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    // Обновление счётчика
    function updateSeconds(seconds) {
        root.secondsLeft = seconds
        if (!root.opened) {
            root.open()
        }
    }

    // Анимация появления
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200 }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "scale"; from: 1; to: 0.9; duration: 150 }
        }
    }
}
