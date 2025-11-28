// styles/Theme.qml
// ВЕРСИЯ С ЦВЕТАМИ ИЗ ОРИГИНАЛЬНОГО AddCategoryDialog
pragma Singleton
import QtQuick

QtObject {
    // --- ОСНОВНЫЕ ЦВЕТА (адаптированы под AddCategoryDialog) ---

    property color primaryColor: "#007bff"              // Синий (для кнопок)
    property color accentColor: "#4682b4"               // 🔵 Steel Blue
    property color backgroundColor: "#F5F5F5"           // Светло-серый фон

    // --- ЦВЕТА ТЕКСТА ---
    property color textColor: "#000000"                 // Черный
    property color textSecondary: "#666666"             // Серый для описаний
    property color textOnPrimary: "#FFFFFF"             // Белый на цветном фоне
    property color errorColor: "#B00020"                // Красный для ошибок

    // --- ЦВЕТА СТАТУСОВ (для NotificationDialog и др.) ---
    property color successColor: "#4CAF50"              // 🟢 Зелёный - успех
    property color warningColor: "#FF9800"              // 🟠 Оранжевый - предупреждение
    property color infoColor: "#2196F3"                 // 🔵 Синий - информация

    // --- ЦВЕТА ДЛЯ ФОРМ И ДИАЛОГОВ ---
    property color inputBackground: "#e0e0e0"           // 💡 Светло-серый фон для input
    property color inputBorder: "#d0d0d0"               // Светло-серая рамка (обычное состояние)
    property color inputBorderHover: "#999999"          // Серая рамка (hover)
    property color inputBorderFocus: "#4682b4"          // 🔵 Steel Blue (фокус)

    property color dividerColor: "#cccccc"              // Разделители
    property color highlightColor: "#0066cc"            // 🔵 Темно-синий для акцентов

    // --- РАЗМЕРЫ ШРИФТОВ ---
    property int sizeH1: 32
    property int sizeH2: 24
    property int sizeH3: 16

    property int sizeBody: 16
    property int sizeCaption: 12
    property int sizeSmall: 9

    // --- РАДИУСЫ И ОТСТУПЫ ---
    property int defaultRadius: 8
    property int smallRadius: 5

    // --- БАЗОВЫЙ ШРИФТ ---
    property font defaultFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeBody
    })

    // --- ДОПОЛНИТЕЛЬНЫЕ ШРИФТЫ ---
    property font smallFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeSmall
    })

    property font boldFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeBody,
        bold: true
    })

    // --- УСТАРЕВШИЕ ИМЕНА (для обратной совместимости) ---
    // Можно использовать старые имена, они указывают на новые значения
    property color dialogBorderColor: inputBorderFocus          // #4682b4
    property color dialogInputBackground: inputBackground       // #e0e0e0
    property color previewTextColor: highlightColor             // #0066cc
}
