// AppButton.qml
import QtQuick
import QtQuick.Controls
import "../../styles"


Button {
    id: control

    // Убираем рамку фокуса
    focusPolicy: Qt.NoFocus

    // Свойства внешнего вида
    property color btnColor: Theme.primaryColor

    // Свойство для задержки анимации (по умолчанию 0)
    property int enterDelay: 0

    // Свойство для отключения анимации появления
    property bool animateEntry: true

    // --- НАЧАЛЬНОЕ СОСТОЯНИЕ (скрыто по умолчанию) ---
    opacity: 0
    transform: Translate {
        id: slideTrans
        y: 30
    }

    // --- ВНУТРЕННЯЯ АНИМАЦИЯ ПОЯВЛЕНИЯ ---
    SequentialAnimation {
        id: entryAnimation
        running: false

        PauseAnimation { duration: control.enterDelay }

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

    // Таймер для отложенной инициализации (даёт время на установку свойств)
    Timer {
        id: initTimer
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            if (control.animateEntry) {
                entryAnimation.start()
            } else {
                // Без анимации - сразу показываем
                control.opacity = 1
                slideTrans.y = 0
            }
        }
    }

    // --- ОСТАЛЬНОЙ КОД (Поведение при наведении/нажатии) ---
    scale: control.enabled ? (control.down ? 0.95 : (control.hovered ? 1.02 : 1.0)) : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    contentItem: Text {
        text: control.text
        font: Theme.defaultFont
        color: Theme.textOnPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        opacity: control.enabled ? 1.0 : 0.6    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        radius: Theme.defaultRadius

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
