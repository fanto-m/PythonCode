// qml/components/common/AppTextField.qml
// ОБНОВЛЕН ДЛЯ ИСПОЛЬЗОВАНИЯ ЦВЕТОВ ИЗ Theme
import QtQuick
import QtQuick.Controls
import "../../styles"


TextField {
    id: control

    // --- НАСТРОЙКИ ТЕКСТА ---
    font: Theme.defaultFont
    color: Theme.textColor

    // Цвет плейсхолдера (текст подсказки) с прозрачностью 50%
    placeholderTextColor: Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b, 0.5)

    // Цвет выделения текста мышкой
    selectionColor: Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.4)
    selectedTextColor: Theme.textColor

    // Важно для десктопа: разрешить выделение мышкой
    selectByMouse: true

    // Внутренние отступы, чтобы текст не прилипал к рамке
    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10

    // --- АНИМАЦИЯ ПОЯВЛЕНИЯ (как у кнопок) ---
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

    // --- ФОН И РАМКА (используем цвета из Theme) ---
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 45
        radius: Theme.smallRadius                    // 5px (как в оригинале)

        // 🎨 ИСПОЛЬЗУЕМ ЦВЕТА ИЗ THEME
        color: control.enabled ? Theme.inputBackground : "#E0E0E0"    // #e0e0e0 или серый если disabled

        // Логика рамки (как в оригинальном AddCategoryDialog):
        // Если в фокусе -> Steel Blue (#4682b4)
        // Если навели мышь -> Темно-серый (#999999)
        // Иначе -> Светло-серый (#d0d0d0)
        border.color: control.activeFocus ? Theme.inputBorderFocus :
                      (control.hovered ? Theme.inputBorderHover : Theme.inputBorder)

        // Толщина рамки: Жирнее при фокусе (как в оригинале)
        border.width: control.activeFocus ? 2 : 1

        // Плавная анимация смены цвета рамки
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }

        // Плавная анимация толщины
        Behavior on border.width {
            NumberAnimation { duration: 150 }
        }
    }
}
