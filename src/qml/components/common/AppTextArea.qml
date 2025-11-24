import QtQuick
import QtQuick.Controls
import "../../styles"

TextArea {
    id: control

    // --- ТИПОГРАФИКА И ЦВЕТА ---
    font: Theme.defaultFont
    color: Theme.textColor
    placeholderTextColor: Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b, 0.5)
    selectionColor: Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.4)
    selectedTextColor: Theme.textColor

    // --- ПОВЕДЕНИЕ ---
    selectByMouse: true
    wrapMode: Text.WordWrap // Перенос слов

    // Важно: текст начинается сверху
    verticalAlignment: Text.AlignTop

    // Внутренние отступы
    leftPadding: 12
    rightPadding: 12
    topPadding: 12
    bottomPadding: 12

    // --- АНИМАЦИЯ ПОЯВЛЕНИЯ ---
    property int enterDelay: 0
    opacity: 0
    transform: Translate { id: slideTrans; y: 20 }

    SequentialAnimation {
        running: true
        PauseAnimation { duration: control.enterDelay }
        ParallelAnimation {
            NumberAnimation { target: control; property: "opacity"; to: 1; duration: 600; easing.type: Easing.OutCubic }
            NumberAnimation { target: slideTrans; property: "y"; to: 0; duration: 800; easing.type: Easing.OutQuint }
        }
    }

    // --- ФОН И РАМКА ---
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 100 // Высота по умолчанию больше, чем у TextField
        radius: Theme.defaultRadius

        color: control.enabled ? "#FFFFFF" : "#E0E0E0"

        border.color: control.activeFocus ? Theme.accentColor :
                      (control.hovered ? "#999999" : "#E0E0E0")
        border.width: control.activeFocus ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }
}