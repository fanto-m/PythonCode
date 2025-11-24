import QtQuick
import "../../styles"

Text {
    id: root

    // Уровень заголовка: "h1", "h2", "h3", "body", "caption", "error"
    property string level: "body"

    // Возможность выравнивания (по умолчанию слева)
    horizontalAlignment: Text.AlignLeft

    // --- ЛОГИКА СТИЛЕЙ ---

    // 1. Размер шрифта зависит от level
    font.pixelSize: {
        switch(root.level) {
            case "h1": return Theme.sizeH1
            case "h2": return Theme.sizeH2
            case "h3": return Theme.sizeH3
            case "caption": return Theme.sizeCaption
            default: return Theme.sizeBody
        }
    }

    // 2. Жирность (Заголовки жирные)
    font.bold: (level === "h1" || level === "h2" || level === "h3")

    // 3. Семейство шрифта (берем из темы)
    font.family: Theme.defaultFont.family

    // 4. Цвет (Ошибки красные, Caption серые, остальные черные)
    color: {
        if (level === "error") return Theme.errorColor
        if (level === "caption") return Theme.textSecondary
        return Theme.textColor
    }

    // Перенос текста по словам, если не влезает
    wrapMode: Text.WordWrap

    // --- АНИМАЦИЯ ПОЯВЛЕНИЯ ---
    property int enterDelay: 0
    opacity: 0
    transform: Translate { id: slideTrans; y: 10 } // Чуть меньше сдвиг для текста

    SequentialAnimation {
        running: true
        PauseAnimation { duration: root.enterDelay }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation { target: slideTrans; property: "y"; to: 0; duration: 700; easing.type: Easing.OutQuint }
        }
    }
}