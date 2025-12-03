import QtQuick
import QtQuick.Controls
import "../../styles"

ComboBox {
    id: control

    // --- Модель данных ---
    delegate: ItemDelegate {
        width: control.width
        required property var model
        required property int index

        contentItem: Text {
            text: {
                // Если задан textRole, используем его
                if (control.textRole && control.textRole.length > 0) {
                    var value = model[control.textRole]
                    return value !== undefined ? value : ""
                }
                // Для простых строковых массивов используем modelData
                return model.modelData !== undefined ? model.modelData : ""
            }
            color: Theme.textColor
            font: Theme.defaultFont
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
        background: Rectangle {
            color: highlighted ? Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.3) : "transparent"
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
        border.color: control.activeFocus ? Theme.accentColor : Theme.inputBorder
        border.width: control.activeFocus ? 2 : 1
        radius: Theme.defaultRadius
    }

    // --- Стрелочка ---
    indicator: Canvas {
        id: indicatorCanvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() {
                indicatorCanvas.requestPaint()
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            if (!ctx) return;

            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            ctx.fillStyle = Theme.textSecondary ? Theme.textSecondary.toString() : "#666666";
            ctx.fill();
        }
    }
}
