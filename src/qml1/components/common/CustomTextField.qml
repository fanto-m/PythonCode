// CustomTextField.qml
// Текстовое поле с поддержкой валидации и Theme_CSM
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" // Theme_CSM

ColumnLayout {
    id: root
    
    // ==================== ПУБЛИЧНЫЕ СВОЙСТВА ====================
    // Делегированные свойства TextField
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias inputMask: textField.inputMask
    property alias validator: textField.validator
    property alias echoMode: textField.echoMode
    property alias readOnly: textField.readOnly
    property alias enabled: textField.enabled
    property alias maximumLength: textField.maximumLength
    property alias selectByMouse: textField.selectByMouse
    
    // Кастомные свойства
    property string label: ""               // Label текст
    property bool required: false           // Обязательное поле
    property string errorMessage: ""        // Сообщение об ошибке
    property bool showError: false          // Показывать ошибку
    property string helpText: ""            // Подсказка под полем
    property string icon: ""                // Иконка слева
    property bool showCharCount: false      // Показывать счетчик символов
    property string size: "medium"          // small, medium, large
    
    // Сигналы
    signal textChanged(string text)
    signal editingFinished()
    signal enterPressed()
    signal focusChanged(bool hasFocus)
    
    // ==================== ПУБЛИЧНЫЕ МЕТОДЫ ====================
    function validate() {
        // Проверка обязательного поля
        if (required && text.trim().length === 0) {
            showError = true
            errorMessage = "Поле обязательно для заполнения"
            return false
        }
        
        // Проверка validator
        if (textField.validator && !textField.acceptableInput) {
            showError = true
            errorMessage = errorMessage || "Неверный формат"
            return false
        }
        
        // Все ок
        showError = false
        errorMessage = ""
        return true
    }
    
    function clear() {
        textField.clear()
        showError = false
        errorMessage = ""
    }
    
    function focus() {
        textField.forceActiveFocus()
    }
    
    function selectAll() {
        textField.selectAll()
    }
    
    // ==================== ПРИВАТНЫЕ СВОЙСТВА ====================
    property int _height: {
        switch(size) {
            case "small": return Theme.inputHeightSmall
            case "large": return Theme.inputHeightLarge
            default: return Theme.inputHeight
        }
    }
    
    property int _fontSize: {
        switch(size) {
            case "small": return Theme.fontSmall
            case "large": return Theme.fontLarge
            default: return Theme.fontMedium
        }
    }
    
    // ==================== НАСТРОЙКИ LAYOUT ====================
    spacing: Theme.spacingXSmall
    Layout.fillWidth: true
    
    // ==================== LABEL ====================
    Label {
        visible: root.label !== ""
        text: root.label + (root.required ? " <font color='" + Theme.danger + "'>*</font>" : "")
        font.pixelSize: Theme.fontSmall
        font.weight: root.required ? Theme.fontWeightMedium : Theme.fontWeightNormal
        font.family: Theme.fontFamily
        color: Theme.textPrimary
        Layout.fillWidth: true
        textFormat: Text.RichText
    }
    
    // ==================== ПОЛЕ ВВОДА ====================
    TextField {
        id: textField
        Layout.fillWidth: true
        height: root._height
        
        leftPadding: root.icon ? 40 : Theme.paddingMedium
        rightPadding: root.showCharCount ? 60 : Theme.paddingMedium
        topPadding: Theme.paddingSmall
        bottomPadding: Theme.paddingSmall
        
        font.pixelSize: root._fontSize
        font.family: Theme.fontFamily
        
        color: enabled ? Theme.textPrimary : Theme.textDisabled
        placeholderTextColor: Theme.textPlaceholder
        
        selectByMouse: true
        
        // Фон
        background: Rectangle {
            color: {
                if (!textField.enabled) return Theme.inputBackgroundDisabled
                if (textField.activeFocus) return Theme.inputBackgroundFocus
                if (textField.hovered) return Theme.inputBackgroundHover
                return Theme.inputBackground
            }
            
            radius: Theme.radiusMedium
            
            border.width: Theme.borderWidthMedium
            border.color: {
                if (root.showError) return Theme.borderError
                if (textField.activeFocus) return Theme.borderFocus
                return Theme.border
            }
            
            // Анимация границы
            Behavior on border.color {
                ColorAnimation {
                    duration: Theme.animationFast
                }
            }
            
            // Анимация фона
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animationFast
                }
            }
        }
        
        // Иконка слева
        Text {
            visible: root.icon !== ""
            text: root.icon
            font.pixelSize: Theme.iconMedium
            color: textField.enabled ? Theme.textSecondary : Theme.textDisabled
            
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Счетчик символов
        Text {
            visible: root.showCharCount && textField.maximumLength > 0
            text: textField.text.length + "/" + textField.maximumLength
            font.pixelSize: Theme.fontXSmall
            color: {
                var ratio = textField.text.length / textField.maximumLength
                if (ratio >= 1.0) return Theme.danger
                if (ratio >= 0.9) return Theme.warning
                return Theme.textSecondary
            }
            
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
        }
        
        // События
        onTextChanged: {
            root.textChanged(text)
            if (root.showError) root.validate()
        }
        
        onEditingFinished: root.editingFinished()
        
        Keys.onReturnPressed: root.enterPressed()
        
        onActiveFocusChanged: root.focusChanged(activeFocus)
    }
    
    // ==================== СООБЩЕНИЕ ОБ ОШИБКЕ ====================
    Label {
        visible: root.showError && root.errorMessage !== ""
        text: "⚠ " + root.errorMessage
        font.pixelSize: Theme.fontSmall
        font.family: Theme.fontFamily
        color: Theme.danger
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }
    
    // ==================== ПОДСКАЗКА ====================
    Label {
        visible: root.helpText !== "" && !root.showError
        text: root.helpText
        font.pixelSize: Theme.fontSmall
        font.family: Theme.fontFamily
        color: Theme.textSecondary
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }
}
