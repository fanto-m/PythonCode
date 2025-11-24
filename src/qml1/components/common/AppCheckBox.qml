import QtQuick
import QtQuick.Controls
import "../../styles"

CheckBox {
    id: control

    // Свойства текста (если он есть)
    font: Theme.defaultFont
    palette.text: Theme.textColor // Используем стандартную палитру Qt6

    // Настройка размеров
    property int boxSize: 20

    // --- 1. ИНДИКАТОР (Сам квадратик) ---
    indicator: Rectangle {
        implicitWidth: control.boxSize
        implicitHeight: control.boxSize
        x: control.leftPadding
        y: parent.height / 2 - height / 2

        radius: 4

        // Логика цвета рамки:
        // Если отмечен -> Акцентный цвет
        // Если ошибка (можно добавить свойство error) -> Красный
        // Если наведен -> Темно-серый
        // Иначе -> Светло-серый
        border.color: control.checked ? Theme.primaryColor :
                      (control.hovered ? "#999" : "#d0d0d0")

        border.width: control.checked ? 0 : 2 // Убираем рамку, если залит цветом

        // Логика фона:
        // Если отмечен -> Акцентный цвет
        // Иначе -> Прозрачный (или белый)
        color: control.checked ? Theme.primaryColor : "transparent"

        // Анимация цвета
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // ГАЛОЧКА (Рисуем вручную)
        Canvas {
            anchors.fill: parent
            anchors.margins: 3 // Отступ галочки от края квадрата
            visible: control.checked
            contextType: "2d"

            // Перерисовка при изменении состояния
            onPaint: {
                var ctx = context;
                ctx.reset();
                ctx.beginPath();
                ctx.lineWidth = 2.5; // Толщина линии галочки
                ctx.strokeStyle = "white"; // Цвет галочки всегда белый
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

                // Координаты галочки (относительно canvas)
                // Начало (левый ус)
                ctx.moveTo(width * 0.15, height * 0.5);
                // Середина (низ)
                ctx.lineTo(width * 0.4, height * 0.75);
                // Конец (правый длинный ус)
                ctx.lineTo(width * 0.85, height * 0.25);

                ctx.stroke();
            }
        }
    }

    // --- 2. ТЕКСТ (Лейбл рядом) ---
    contentItem: Text {
        text: control.text
        font: control.font
        color: Theme.textColor
        opacity: enabled ? 1.0 : 0.5
        verticalAlignment: Text.AlignVCenter

        // Сдвигаем текст, чтобы он не наезжал на квадратик
        leftPadding: control.indicator.width + control.spacing
    }
}