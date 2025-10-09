import QtQuick

QtObject {
    id: theme

    // Основные цвета
    property color primary: "#f39c12"       // Основной акцентный цвет (оранжевый)
    property color primaryDark: "#d68910"   // Темный оттенок основного цвета (для pressed)
    property color primaryHover: "#2c3e50"  // Цвет при наведении на кнопки

    // Цвета для кнопок действий
    property color success: "#28a745"       // Цвет для успешных действий (зеленый, для "Сохранить")
    property color successDark: "#1e7e34"   // Темный оттенок для pressed
    property color successHover: "#218838"  // Цвет при наведении

    property color info: "#17a2b8"          // Цвет для информационных действий (голубой, для "Экспорт в Excel")
    property color infoDark: "#117a8b"      // Темный оттенок для pressed
    property color infoHover: "#138496"     // Цвет при наведении

    property color danger: "#dc3545"        // Цвет для опасных действий (красный, для "Экспорт в PDF")
    property color dangerDark: "#c82333"    // Темный оттенок для pressed
    property color dangerHover: "#e02535"   // Цвет при наведении

    property color neutral: "#6c757d"       // Нейтральный цвет (серый, для "Очистить")
    property color neutralDark: "#5a6268"   // Темный оттенок для pressed
    property color neutralHover: "#6c757d"  // Цвет при наведении

    // Цвета фона и границ
    property color background: "#f5f5f5"    // Основной цвет фона
    property color white: "#ffffff"         // Белый для элементов
    property color border: "#d0d0d0"        // Цвет границ
    property color tableHeader: "#e0e0e0"   // Цвет заголовка таблицы
    property color tableAlternate: "#f9f9f9" // Цвет чередующихся строк таблицы
    property color disabled: "#e0e0e0"      // Цвет для неактивных элементов

    // Цвета текста
    property color textPrimary: "#007bff"   // Основной цвет текста (синий, для цен)
    property color textSuccess: "#28a745"   // Цвет текста для успешных операций
    property color textSecondary: "#555"    // Вторичный цвет текста (темно-серый)
    property color textPlaceholder: "#999"  // Цвет для placeholder-текста
    property color textWhite: "#ffffff"     // Белый текст для заголовков и кнопок
}