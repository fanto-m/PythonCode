// Theme_CSM.qml - Theme for Create Specification Mode
import QtQuick

QtObject {
    // Main colors
    readonly property color primary: "#2196F3"
    readonly property color primaryDark: "#1976D2"
    readonly property color primaryHover: "#42A5F5"

    readonly property color success: "#4CAF50"
    readonly property color successDark: "#388E3C"
    readonly property color successHover: "#66BB6A"

    readonly property color danger: "#F44336"
    readonly property color dangerDark: "#D32F2F"
    readonly property color dangerHover: "#EF5350"

    readonly property color warning: "#FF9800"
    readonly property color warningDark: "#F57C00"
    readonly property color warningHover: "#FFB74D"

    readonly property color info: "#2196F3"
    readonly property color infoDark: "#1976D2"
    readonly property color infoHover: "#42A5F5"

    readonly property color neutral: "#9E9E9E"
    readonly property color neutralDark: "#757575"
    readonly property color neutralHover: "#BDBDBD"

    readonly property color disabled: "#E0E0E0"

    // Background colors
    readonly property color background: "#F5F5F5"
    readonly property color white: "#FFFFFF"
    readonly property color tableHeader: "#E3F2FD"
    readonly property color tableAlternate: "#FAFAFA"

    // Border colors
    readonly property color border: "#D0D0D0"
    readonly property color borderFocus: "#2196F3"

    // Text colors
    readonly property color textPrimary: "#212121"
    readonly property color textSecondary: "#757575"
    readonly property color textPlaceholder: "#9E9E9E"
    readonly property color textWhite: "#FFFFFF"
    readonly property color textSuccess: "#2E7D32"
    readonly property color textDanger: "#C62828"
    readonly property color textWarning: "#F57C00"

    // Spacing
    readonly property int spacing: 10
    readonly property int spacingSmall: 5
    readonly property int spacingLarge: 15

    // Font sizes
    readonly property int fontSizeSmall: 9
    readonly property int fontSizeNormal: 10
    readonly property int fontSizeMedium: 11
    readonly property int fontSizeLarge: 12
    readonly property int fontSizeXLarge: 14
    readonly property int fontSizeTitle: 18

    // Border radius
    readonly property int radiusSmall: 3
    readonly property int radiusNormal: 4
    readonly property int radiusLarge: 6
}