// MainMenuScreen.qml - Экран главного меню
// Расположение: src/qml/screens/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Rectangle {
    id: root

    signal editWarehouseClicked()
    signal viewWarehouseClicked()
    signal createSpecificationClicked()
    signal viewSpecificationsClicked()

    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.menuGradientTop }
        GradientStop { position: 1.0; color: Theme.menuGradientBottom }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.largeSpacing * 1.5
        width: 600

        // Заголовок
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Система управления складом"
            font: Theme.titleFont
            color: Theme.menuTitleColor
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Выберите режим работы"
            font.pixelSize: Theme.sizeH3
            font.family: Theme.defaultFont.family
            color: Theme.textMuted
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: Theme.menuDividerColor
            Layout.topMargin: Theme.defaultSpacing
            Layout.bottomMargin: Theme.largeSpacing
        }

        // === Кнопка "Редактировать склад" ===
        MenuButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            menuIcon: "✏️"
            title: "Редактировать склад"
            subtitle: "Добавление, редактирование и удаление товаров"
            baseColor: Theme.editModeColor
            darkColor: Theme.editModeDark
            onClicked: root.editWarehouseClicked()
        }

        // === Кнопка "Просмотр склада" ===
        MenuButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            menuIcon: "👁️"
            title: "Просмотр склада"
            subtitle: "Просмотр товаров и информации о складе"
            baseColor: Theme.viewModeColor
            darkColor: Theme.viewModeDark
            onClicked: root.viewWarehouseClicked()
        }

        // === Кнопка "Создать спецификацию" ===
        MenuButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            menuIcon: "📝"
            title: "Создать спецификацию"
            subtitle: "Формирование новой спецификации товаров"
            baseColor: Theme.specCreateColor
            darkColor: Theme.specCreateDark
            onClicked: root.createSpecificationClicked()
        }

        // === Кнопка "Просмотр спецификаций" ===
        MenuButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            menuIcon: "📋"
            title: "Просмотр спецификаций"
            subtitle: "Просмотр сохраненных спецификаций"
            baseColor: Theme.specViewColor
            darkColor: Theme.specViewDark
            onClicked: root.viewSpecificationsClicked()
        }

        // Нижний разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: Theme.menuDividerColor
            Layout.topMargin: Theme.largeSpacing
        }

        // Версия
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Версия 1.0"
            font.pixelSize: Theme.sizeCaption
            font.family: Theme.defaultFont.family
            color: Theme.menuVersionColor
        }
    }

    // === Компонент кнопки меню ===
    component MenuButton: Button {
        id: menuBtn

        property string menuIcon: ""
        property string title: ""
        property string subtitle: ""
        property color baseColor: Theme.primaryColor
        property color darkColor: Qt.darker(baseColor, 1.2)

        focusPolicy: Qt.NoFocus

        background: Rectangle {
            color: menuBtn.down ? menuBtn.darkColor : menuBtn.baseColor
            radius: Theme.defaultRadius
            border.color: menuBtn.darkColor
            border.width: 2

            // Эффект при наведении
            Rectangle {
                anchors.fill: parent
                radius: Theme.defaultRadius
                color: menuBtn.hovered && !menuBtn.down ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        contentItem: RowLayout {
            spacing: 15

            Text {
                text: menuBtn.menuIcon
                font.pixelSize: 28
                Layout.leftMargin: Theme.largeSpacing
            }

            ColumnLayout {
                spacing: Theme.smallSpacing
                Layout.fillWidth: true

                Text {
                    text: menuBtn.title
                    font.pixelSize: Theme.sizeH2
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textOnPrimary
                }

                Text {
                    text: menuBtn.subtitle
                    font.pixelSize: Theme.sizeCaption
                    font.family: Theme.defaultFont.family
                    color: Theme.textSubtitle
                }
            }

            Text {
                text: "→"
                font.pixelSize: 24
                color: Theme.textOnPrimary
                Layout.rightMargin: Theme.largeSpacing
            }
        }
    }
}
