import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../../styles"

Button {
    id: control // Даем ID самому компоненту

    // 1. СВОИ кастомные свойства (которых нет у Button)
    property color primaryColor: Theme_CSM.primaryColor
    property color textColor: "white"

    // 2. ПЕРЕОПРЕДЕЛЕНИЕ ВИЗУАЛА (Background)
    // Мы полностью заменяем стандартный фон своим прямоугольником
    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        radius: 4
        // Логика цветов: нажата, наведена, обычная
        color: control.down ? Qt.darker(control.primaryColor, 1.2) :
               (control.hovered ? Qt.lighter(control.primaryColor, 1.1) : control.primaryColor)

        border.color: control.activeFocus ? Theme_CSM.accentColor : "transparent"
        border.width: control.activeFocus ? 2 : 0
    }

    // 3. ПЕРЕОПРЕДЕЛЕНИЕ КОНТЕНТА (Текст/Иконка)
    contentItem: Text {
        text: control.text // БЕРЕМ ТЕКСТ ИЗ РОДИТЕЛЯ, не создаем свой alias
        font: control.font // ИСПОЛЬЗУЕМ ШРИФТ РОДИТЕЛЯ
        opacity: enabled ? 1.0 : 0.3
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}