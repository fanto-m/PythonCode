// styles/Theme.qml
// РАСШИРЕННАЯ ВЕРСИЯ С ЦВЕТАМИ ГЛАВНОГО МЕНЮ
pragma Singleton
import QtQuick

QtObject {
    // =====================================================
    // ОСНОВНЫЕ ЦВЕТА ПРИЛОЖЕНИЯ
    // =====================================================

    property color primaryColor: "#3498db"              // 🔵 Синий (редактирование)
    property color accentColor: "#4682b4"               // 🔵 Steel Blue
    property color backgroundColor: "#F5F5F5"           // Светло-серый фон

    // =====================================================
    // ЦВЕТА РЕЖИМОВ / ЭКРАНОВ (из MainMenuScreen)
    // =====================================================

    // Редактирование склада
    property color editModeColor: "#3498db"             // 🔵 Синий
    property color editModeDark: "#2980b9"              // 🔵 Тёмно-синий

    // Просмотр склада
    property color viewModeColor: "#2ecc71"             // 🟢 Зелёный
    property color viewModeDark: "#27ae60"              // 🟢 Тёмно-зелёный

    // Создание спецификации
    property color specCreateColor: "#f39c12"           // 🟠 Оранжевый
    property color specCreateDark: "#d68910"            // 🟠 Тёмно-оранжевый

    // Просмотр спецификаций
    property color specViewColor: "#9b59b6"             // 🟣 Фиолетовый
    property color specViewDark: "#8e44ad"              // 🟣 Тёмно-фиолетовый

    // Настройки (только admin)
    property color settingsColor: "#7f8c8d"             // ⚙️ Серый
    property color settingsDark: "#636e72"              // ⚙️ Тёмно-серый

    // =====================================================
    // ЦВЕТА ТЕКСТА
    // =====================================================

    property color textColor: "#000000"                 // Чёрный (основной)
    property color textSecondary: "#666666"             // Серый (описания)
    property color textMuted: "#7f8c8d"                 // Приглушённый серый
    property color textOnPrimary: "#FFFFFF"             // Белый (на цветном фоне)
    property color textSubtitle: "#ecf0f1"              // Светлый (подзаголовки на цветном)

    // =====================================================
    // ЦВЕТА СТАТУСОВ
    // =====================================================

    property color successColor: "#2ecc71"              // 🟢 Зелёный - успех
    property color errorColor: "#e74c3c"                // 🔴 Красный - ошибка
    property color warningColor: "#f39c12"              // 🟠 Оранжевый - предупреждение
    property color infoColor: "#3498db"                 // 🔵 Синий - информация

    // =====================================================
    // ЦВЕТА ГЛАВНОГО МЕНЮ
    // =====================================================

    property color menuGradientTop: "#f5f7fa"           // Верх градиента
    property color menuGradientBottom: "#c3cfe2"        // Низ градиента
    property color menuTitleColor: "#2c3e50"            // Заголовок меню
    property color menuDividerColor: "#bdc3c7"          // Разделители
    property color menuVersionColor: "#95a5a6"          // Версия приложения

    // =====================================================
    // ЦВЕТА ДЛЯ ФОРМ И ДИАЛОГОВ
    // =====================================================

    property color inputBackground: "#FFFFFF"           // Белый фон для полей
    property color inputBackgroundDisabled: "#e0e0e0"   // Серый фон (disabled)
    property color inputBorder: "#d0d0d0"               // Светло-серая рамка
    property color inputBorderHover: "#999999"          // Серая рамка (hover)
    property color inputBorderFocus: "#4682b4"          // Steel Blue (фокус)

    property color dividerColor: "#cccccc"              // Разделители
    property color highlightColor: "#0066cc"            // Тёмно-синий для акцентов

    // =====================================================
    // ЦВЕТА ТАБЛИЦ
    // =====================================================

    property color tableHeaderColor: "#4682b4"          // Заголовок таблицы
    property color tableRowEven: "#FFFFFF"              // Чётные строки
    property color tableRowOdd: "#F5F5F5"               // Нечётные строки
    property color tableRowHover: "#e3f2fd"             // Наведение на строку

    // =====================================================
    // РАЗМЕРЫ ШРИФТОВ
    // =====================================================

    property int sizeH1: 32
    property int sizeH2: 24
    property int sizeH3: 16
    property int sizeBody: 14
    property int sizeCaption: 12
    property int sizeSmall: 12

    // =====================================================
    // РАДИУСЫ И ОТСТУПЫ
    // =====================================================

    property int defaultRadius: 8
    property int smallRadius: 4
    property int largeRadius: 12

    property int defaultSpacing: 10
    property int smallSpacing: 5
    property int largeSpacing: 20

    // =====================================================
    // ШРИФТЫ
    // =====================================================

    property font defaultFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeBody
    })

    property font smallFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeSmall
    })

    property font boldFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeBody,
        bold: true
    })

    property font headerFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeH2,
        bold: true
    })

    property font titleFont: Qt.font({
        family: "Roboto",
        pixelSize: sizeH1,
        bold: true
    })

    // =====================================================
    // УСТАРЕВШИЕ ИМЕНА (обратная совместимость)
    // =====================================================

    property color dialogBorderColor: inputBorderFocus
    property color dialogInputBackground: inputBackground
    property color previewTextColor: highlightColor
}

