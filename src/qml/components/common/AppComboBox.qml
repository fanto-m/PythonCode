import QtQuick
import QtQuick.Controls
import "../../styles"

ComboBox {
    id: control

    // --- Модель данных ---
    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            // Поддержка как простых массивов (modelData), так и моделей с textRole
            text: control.textRole ? model[control.textRole] : (modelData ?? "")
            color: Theme.textColor
            font: Theme.defaultFont
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
        background: Rectangle {
            color: highlighted ? Theme.accentColor : "transparent"
            opacity: 0.3
        }
    }

    // --- Внешний вид поля ---
    contentItem: Text {
        leftPadding: 10
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font: Theme.defaultFont
        color: Theme.textColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 40
        color: "white"
        border.color: control.activeFocus ? Theme.accentColor : "#d0d0d0"
        border.width: control.activeFocus ? 2 : 1
        radius: Theme.defaultRadius
    }

    // --- Стрелочка ---
    indicator: Canvas {
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"
        onPaint: {
            var ctx = getContext("2d");
            if (!ctx) return;

            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            // Безопасное получение цвета с fallback
            ctx.fillStyle = (Theme && Theme.textSecondary) ? Theme.textSecondary.toString() : "#666666";
            ctx.fill();
        }
    }
}
