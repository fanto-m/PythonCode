// Theme_CSM.qml
// Централизованная тема для PythonCode - Расширенная версия
// Используйте: import "qrc:/qml/styles" затем Theme.цвет или Theme.размер

pragma Singleton
import QtQuick 2.15

QtObject {
    id: root
    
    // ==================== ЦВЕТА ====================
    
    // Основная палитра (брендовые цвета)
    readonly property color primary: "#3498db"          // Синий - основной
    readonly property color primaryDark: "#2980b9"      // Темнее
    readonly property color primaryLight: "#5dade2"     // Светлее
    
    readonly property color secondary: "#2ecc71"        // Зеленый - вторичный
    readonly property color secondaryDark: "#27ae60"
    readonly property color secondaryLight: "#58d68d"
    
    readonly property color accent: "#e74c3c"           // Красный - акцент
    readonly property color accentDark: "#c0392b"
    readonly property color accentLight: "#ec7063"
    
    // Статусные цвета
    readonly property color success: "#27ae60"          // Успех (зеленый)
    readonly property color successLight: "#d4efdf"     // Фон успеха
    
    readonly property color warning: "#f39c12"          // Предупреждение (оранжевый)
    readonly property color warningLight: "#fdebd0"     // Фон предупреждения
    
    readonly property color danger: "#e74c3c"           // Опасность (красный)
    readonly property color dangerLight: "#fadbd8"      // Фон опасности
    
    readonly property color info: "#3498db"             // Информация (синий)
    readonly property color infoLight: "#d6eaf8"        // Фон информации
    
    // Фоновые цвета
    readonly property color windowBackground: "#ecf0f1" // Фон главного окна
    readonly property color cardBackground: "#ffffff"   // Фон карточек
    readonly property color dialogBackground: "#ffffff" // Фон диалогов
    readonly property color headerBackground: "#2c3e50" // Фон заголовков
    readonly property color sidebarBackground: "#34495e"// Фон боковой панели
    readonly property color toolbarBackground: "#f8f9fa"// Фон панели инструментов
    readonly property color tableHeaderBackground: "#e8e8e8" // Фон заголовка таблицы
    readonly property color tableRowAlternate: "#f9f9f9"    // Чередующиеся строки
    
    // Цвета ввода
    readonly property color inputBackground: "#ffffff"         // Фон поля ввода
    readonly property color inputBackgroundDisabled: "#e9ecef" // Фон отключенного поля
    readonly property color inputBackgroundHover: "#f8f9fa"    // Фон при наведении
    readonly property color inputBackgroundFocus: "#ffffff"    // Фон при фокусе
    
    // Текстовые цвета
    readonly property color textPrimary: "#2c3e50"      // Основной текст
    readonly property color textSecondary: "#7f8c8d"    // Вторичный текст
    readonly property color textTertiary: "#95a5a6"     // Третичный текст
    readonly property color textLight: "#ecf0f1"        // Светлый текст (на темном фоне)
    readonly property color textDisabled: "#bdc3c7"     // Отключенный текст
    readonly property color textOnPrimary: "#ffffff"    // Текст на primary фоне
    readonly property color textOnDanger: "#ffffff"     // Текст на danger фоне
    readonly property color textPlaceholder: "#95a5a6"  // Placeholder текст
    
    // Цвета границ
    readonly property color border: "#bdc3c7"           // Обычная граница
    readonly property color borderDark: "#95a5a6"       // Темная граница
    readonly property color borderLight: "#e0e0e0"      // Светлая граница
    readonly property color borderFocus: "#3498db"      // Граница при фокусе
    readonly property color borderError: "#e74c3c"      // Граница при ошибке
    readonly property color borderSuccess: "#27ae60"    // Граница при успехе
    
    // Разделители
    readonly property color divider: "#dee2e6"          // Разделительная линия
    readonly property color dividerLight: "#f1f3f5"     // Светлый разделитель
    
    // Hover (наведение) состояния
    readonly property color hoverLight: "#f8f9fa"       // Светлый hover
    readonly property color hoverMedium: "#e9ecef"      // Средний hover
    readonly property color hoverDark: "#34495e"        // Темный hover
    readonly property color hoverPrimary: "#2980b9"     // Hover на primary
    readonly property color hoverDanger: "#c0392b"      // Hover на danger
    
    // Тени
    readonly property color shadow: "#40000000"         // Черная с alpha 25%
    readonly property color shadowLight: "#20000000"    // Черная с alpha 12%
    readonly property color shadowMedium: "#30000000"   // Черная с alpha 18%
    
    // Прозрачность (overlay)
    readonly property color overlayLight: "#10000000"   // 6% черного
    readonly property color overlayMedium: "#40000000"  // 25% черного
    readonly property color overlayDark: "#80000000"    // 50% черного
    
    // ==================== РАЗМЕРЫ ====================
    
    // Радиусы скругления
    readonly property int radiusNone: 0
    readonly property int radiusXSmall: 2
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 12
    readonly property int radiusXLarge: 16
    readonly property int radiusRound: 999             // Полностью круглый
    
    // Отступы (spacing) между элементами
    readonly property int spacingXSmall: 2
    readonly property int spacingSmall: 5
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 15
    readonly property int spacingXLarge: 20
    readonly property int spacingXXLarge: 30
    
    // Внутренние отступы (padding)
    readonly property int paddingXSmall: 4
    readonly property int paddingSmall: 8
    readonly property int paddingMedium: 12
    readonly property int paddingLarge: 16
    readonly property int paddingXLarge: 24
    readonly property int paddingXXLarge: 32
    
    // Высота элементов
    readonly property int buttonHeight: 36              // Стандартная кнопка
    readonly property int buttonHeightSmall: 28         // Маленькая кнопка
    readonly property int buttonHeightLarge: 44         // Большая кнопка
    readonly property int inputHeight: 36               // Поле ввода
    readonly property int inputHeightSmall: 28
    readonly property int inputHeightLarge: 44
    readonly property int toolbarHeight: 50             // Панель инструментов
    readonly property int headerHeight: 60              // Заголовок
    readonly property int tableRowHeight: 40            // Строка таблицы
    readonly property int cardMinHeight: 120            // Минимальная высота карточки
    
    // Ширина элементов
    readonly property int sidebarWidth: 250             // Боковая панель
    readonly property int sidebarWidthCollapsed: 60     // Свернутая панель
    readonly property int scrollbarWidth: 12            // Полоса прокрутки
    readonly property int iconButtonWidth: 36           // Кнопка с иконкой
    
    // Размеры диалогов
    readonly property int dialogWidthXSmall: 300
    readonly property int dialogWidthSmall: 400
    readonly property int dialogWidthMedium: 600
    readonly property int dialogWidthLarge: 800
    readonly property int dialogWidthXLarge: 1000
    readonly property int dialogMinHeight: 200
    readonly property int dialogMaxHeight: 700
    
    // Размеры иконок
    readonly property int iconXSmall: 12
    readonly property int iconSmall: 16
    readonly property int iconMedium: 24
    readonly property int iconLarge: 32
    readonly property int iconXLarge: 48
    readonly property int iconXXLarge: 64
    
    // Размеры изображений
    readonly property int thumbnailSize: 80             // Миниатюра
    readonly property int imagePreviewSize: 200         // Превью
    readonly property int avatarSize: 40                // Аватар
    readonly property int avatarSizeLarge: 60
    
    // Толщина границ
    readonly property int borderWidthThin: 1
    readonly property int borderWidthMedium: 2
    readonly property int borderWidthThick: 3
    
    // Тени (shadow)
    readonly property int shadowRadiusSmall: 4
    readonly property int shadowRadiusMedium: 8
    readonly property int shadowRadiusLarge: 16
    readonly property int shadowOffsetY: 2
    readonly property int shadowOffsetX: 0
    
    // ==================== ШРИФТЫ ====================
    
    // Размеры шрифтов
    readonly property int fontXSmall: 10
    readonly property int fontSmall: 12
    readonly property int fontMedium: 14                // Основной размер
    readonly property int fontLarge: 16
    readonly property int fontXLarge: 20
    readonly property int fontXXLarge: 24
    readonly property int fontXXXLarge: 32
    
    // Семейство шрифтов
    readonly property string fontFamily: "Segoe UI"
    readonly property string fontFamilyMono: "Consolas" // Для кода
    readonly property string fontFamilyNumbers: "Arial" // Для цифр
    
    // Веса шрифтов
    readonly property int fontWeightLight: Font.Light       // 300
    readonly property int fontWeightNormal: Font.Normal     // 400
    readonly property int fontWeightMedium: Font.Medium     // 500
    readonly property int fontWeightDemiBold: Font.DemiBold // 600
    readonly property int fontWeightBold: Font.Bold         // 700
    
    // Межстрочный интервал
    readonly property real lineHeightTight: 1.2
    readonly property real lineHeightNormal: 1.5
    readonly property real lineHeightRelaxed: 1.8
    
    // ==================== АНИМАЦИИ ====================
    
    // Длительность анимаций (в миллисекундах)
    readonly property int animationInstant: 0
    readonly property int animationFast: 150
    readonly property int animationNormal: 250
    readonly property int animationSlow: 350
    readonly property int animationVerySlow: 500
    
    // Типы easing
    readonly property int easingLinear: Easing.Linear
    readonly property int easingInOutQuad: Easing.InOutQuad
    readonly property int easingOutCubic: Easing.OutCubic
    readonly property int easingInOutCubic: Easing.InOutCubic
    
    // ==================== Z-INDEX (СЛОИ) ====================
    
    readonly property int zIndexBackground: 0
    readonly property int zIndexContent: 1
    readonly property int zIndexHeader: 10
    readonly property int zIndexSidebar: 20
    readonly property int zIndexDropdown: 100
    readonly property int zIndexDialog: 200
    readonly property int zIndexTooltip: 300
    readonly property int zIndexNotification: 400
    readonly property int zIndexOverlay: 500
    
    // ==================== BREAKPOINTS (Адаптивность) ====================
    
    readonly property int breakpointMobile: 768
    readonly property int breakpointTablet: 1024
    readonly property int breakpointDesktop: 1280
    readonly property int breakpointLarge: 1920
    
    // ==================== СПЕЦИФИЧНЫЕ ДЛЯ ПРОЕКТА ====================
    
    // Статусы товаров (цвета)
    readonly property color statusInStock: "#27ae60"        // В наличии
    readonly property color statusLowStock: "#f39c12"       // Мало
    readonly property color statusOutOfStock: "#e74c3c"     // Нет в наличии
    readonly property color statusOrdered: "#3498db"        // Заказано
    
    // Категории (можно добавить специфичные цвета)
    readonly property color categoryElectronics: "#3498db"
    readonly property color categoryFurniture: "#e67e22"
    readonly property color categoryTools: "#95a5a6"
    readonly property color categoryDefault: "#7f8c8d"
    
    // ==================== ФУНКЦИИ-ПОМОЩНИКИ ====================
    
    /**
     * Создает тень для компонента
     * @param size - 'small', 'medium', 'large'
     */
    function createShadow(size) {
        var radius = shadowRadiusMedium
        var color = shadow
        
        if (size === "small") {
            radius = shadowRadiusSmall
            color = shadowLight
        } else if (size === "large") {
            radius = shadowRadiusLarge
        }
        
        return {
            color: color,
            horizontalOffset: shadowOffsetX,
            verticalOffset: shadowOffsetY,
            radius: radius,
            samples: radius * 2 + 1
        }
    }
    
    /**
     * Возвращает цвет для статуса
     * @param status - строка статуса
     */
    function getStatusColor(status) {
        switch(status) {
            case "В наличии":
            case "in_stock":
                return statusInStock
            case "Мало":
            case "low_stock":
                return statusLowStock
            case "Нет в наличии":
            case "out_of_stock":
                return statusOutOfStock
            case "Заказано":
            case "ordered":
                return statusOrdered
            default:
                return textSecondary
        }
    }
    
    /**
     * Возвращает hover цвет для заданного цвета
     * @param baseColor - базовый цвет
     */
    function getHoverColor(baseColor) {
        return Qt.darker(baseColor, 1.1)
    }
    
    /**
     * Возвращает pressed цвет для заданного цвета
     * @param baseColor - базовый цвет
     */
    function getPressedColor(baseColor) {
        return Qt.darker(baseColor, 1.2)
    }
    
    /**
     * Делает цвет полупрозрачным
     * @param color - цвет
     * @param alpha - прозрачность (0.0 - 1.0)
     */
    function withOpacity(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }
}
