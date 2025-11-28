// NotificationDialog.qml - Универсальный диалог уведомлений
// Расположение: qml/components/common/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../styles"

Dialog {
    id: root

    modal: true
    width: 400
    anchors.centerIn: parent

    // === СВОЙСТВА ===
    // Тип диалога: "success", "error", "warning", "info"
    property string dialogType: "info"

    // Текст сообщения
    property string message: ""

    // Показывать кнопку "Отмена"
    property bool showCancelButton: false

    // === ВЫЧИСЛЯЕМЫЕ СВОЙСТВА ===
    // Цвет рамки в зависимости от типа
    readonly property color borderColor: {
        switch (dialogType) {
            case "success": return Theme.successColor
            case "error": return Theme.errorColor
            case "warning": return Theme.warningColor
            case "info": return Theme.infoColor
            default: return Theme.inputBorder
        }
    }

    // Иконка в зависимости от типа
    readonly property string icon: {
        switch (dialogType) {
            case "success": return "✅"
            case "error": return "❌"
            case "warning": return "⚠️"
            case "info": return "ℹ️"
            default: return "ℹ️"
        }
    }

    // Цвет кнопки OK в зависимости от типа
    readonly property color okButtonColor: {
        switch (dialogType) {
            case "success": return Theme.successColor
            case "error": return Theme.errorColor
            case "warning": return Theme.warningColor
            case "info": return Theme.primaryColor
            default: return Theme.primaryColor
        }
    }

    // === ФОНОВЫЙ СТИЛЬ ===
    background: Rectangle {
        color: "white"
        border.color: root.borderColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    // === КОНТЕНТ ===
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Сообщение с иконкой
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Иконка
            Text {
                text: root.icon
                font.pixelSize: 24
                Layout.alignment: Qt.AlignTop
            }

            // Текст сообщения
            Text {
                text: root.message
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font: Theme.defaultFont
                color: Theme.textColor
                lineHeight: 1.3
            }
        }
    }

    // === КНОПКИ ===
    footer: DialogButtonBox {
        alignment: Qt.AlignRight
        spacing: 8
        padding: 12

        background: Rectangle {
            color: Theme.backgroundColor
            radius: Theme.defaultRadius
        }

        // Кнопка OK
        Button {
            text: "OK"
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            onClicked: root.accept()

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 36
                color: parent.down ? Qt.darker(root.okButtonColor, 1.2)
                     : (parent.hovered ? Qt.lighter(root.okButtonColor, 1.1) : root.okButtonColor)
                radius: Theme.smallRadius

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

        // Кнопка Отмена
        Button {
            text: "Отмена"
            visible: root.showCancelButton
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            onClicked: root.reject()

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 36
                color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e8e8e8" : "#f0f0f0")
                border.color: Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: parent.text
                color: Theme.textColor
                font: Theme.defaultFont
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
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

    // === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

    // Показать диалог успеха
    function showSuccess(msg) {
        dialogType = "success"
        message = msg
        showCancelButton = false
        open()
    }

    // Показать диалог ошибки
    function showError(msg) {
        dialogType = "error"
        message = msg
        showCancelButton = false
        open()
    }

    // Показать диалог предупреждения
    function showWarning(msg) {
        dialogType = "warning"
        message = msg
        showCancelButton = false
        open()
    }

    // Показать информационный диалог
    function showInfo(msg) {
        dialogType = "info"
        message = msg
        showCancelButton = false
        open()
    }

    // Показать диалог подтверждения (с кнопкой Отмена)
    function showConfirm(msg, type) {
        dialogType = type || "warning"
        message = msg
        showCancelButton = true
        open()
    }
}
