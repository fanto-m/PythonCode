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

    // --- НАЧАЛЬНОЕ СОСТОЯНИЕ ---
    // Кнопка невидима и смещена вниз
    opacity: 0
    transform: Translate {
        id: slideTrans
        y: 30 // Сдвиг вниз на 30 пикселей
    }

    // --- ВНУТРЕННЯЯ АНИМАЦИЯ ПОЯВЛЕНИЯ ---
    SequentialAnimation {
        running: true // Запускается сразу при создании кнопки

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

    // --- ОСТАЛЬНОЙ КОД (Поведение при наведении/нажатии) ---
    scale: control.down ? 0.95 : (control.hovered ? 1.05 : 1.0)
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    contentItem: Text {
        text: control.text
        font: Theme.defaultFont
        color: Theme.textOnPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        radius: Theme.defaultRadius
        color: control.down ? Qt.darker(control.btnColor, 1.1) :
               (control.hovered ? Qt.lighter(control.btnColor, 1.1) : control.btnColor)

        Behavior on color { ColorAnimation { duration: 200 } }
    }
}