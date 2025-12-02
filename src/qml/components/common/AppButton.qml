// AppButton.qml
import QtQuick
import QtQuick.Controls
import "../../styles"


Button {
    id: control

    // Свойства внешнего вида
    property color btnColor: Theme.primaryColor

    // Свойство для задержки анимации (по умолчанию 0)
    property int enterDelay: 0

    // Свойство для отключения анимации появления
    property bool animateEntry: true

    // --- НАЧАЛЬНОЕ СОСТОЯНИЕ ---
    opacity: 1
    transform: Translate {
        id: slideTrans
        y: 0
    }

    // --- ВНУТРЕННЯЯ АНИМАЦИЯ ПОЯВЛЕНИЯ ---
    SequentialAnimation {
        id: entryAnimation

        // 1. Ждем (если задана задержка)
        PauseAnimation { duration: control.enterDelay }

        // 2. Параллельно проявляем и поднимаем
        ParallelAnimation {
            NumberAnimation {
                target: control
                property: "opacity"
                to: 1
                duration: 600
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: slideTrans
                property: "y"
                to: 0
                duration: 800
                easing.type: Easing.OutQuint
            }
        }
    }

    // Запускаем анимацию после полной инициализации компонента
    Component.onCompleted: {
        if (animateEntry) {
            opacity = 0
            slideTrans.y = 30
            entryAnimation.start()
        }
    }

    // --- ОСТАЛЬНОЙ КОД (Поведение при наведении/нажатии) ---
    // Отключаем эффекты масштабирования когда кнопка неактивна
    scale: control.enabled ? (control.down ? 0.95 : (control.hovered ? 1.05 : 1.0)) : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    contentItem: Text {
        text: control.text
        font: Theme.defaultFont
        color: Theme.textOnPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        // Полупрозрачный текст когда кнопка неактивна
        opacity: control.enabled ? 1.0 : 0.6
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        radius: Theme.defaultRadius

        // Серый цвет когда кнопка неактивна
        color: {
            if (!control.enabled) {
                return "#CCCCCC"
            }
            if (control.down) {
                return Qt.darker(control.btnColor, 1.1)
            }
            if (control.hovered) {
                return Qt.lighter(control.btnColor, 1.1)
            }
            return control.btnColor
        }

        Behavior on color { ColorAnimation { duration: 200 } }
    }
}
