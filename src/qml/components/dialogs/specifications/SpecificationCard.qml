// SpecificationCard.qml - Карточка спецификации в списке
// Расположение: src/qml/components/dialogs/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"

Rectangle {
    id: card

    // Свойства для передачи данных (без required для совместимости с ListModel)
    property int specId: 0
    property string specName: ""
    property string specDescription: ""
    property string specStatus: ""
    property real laborCost: 0
    property real overheadPercentage: 0
    property real finalPrice: 0
    property string createdDate: ""
    property string modifiedDate: ""
    property bool useLandscapeOrientation: false

    // Сигналы
    signal viewDetails()
    signal editClicked()
    signal exportExcel()
    signal exportPDF()
    signal deleteClicked()

    width: parent ? parent.width - 30 : 400
    height: 180
    color: Theme.backgroundColor
    radius: Theme.defaultRadius
    border.color: Theme.inputBorder
    border.width: 1

    // Эффект при наведении
    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.03) : "transparent"
        radius: Theme.defaultRadius
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.viewDetails()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // ЛЕВАЯ ЧАСТЬ - Информация
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            // Название
            Text {
                text: card.specName
                font.pixelSize: Theme.sizeH3
                font.bold: true
                font.family: Theme.defaultFont.family
                color: Theme.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Описание
            Text {
                text: card.specDescription || "Нет описания"
                font.family: Theme.defaultFont.family
                font.pixelSize: Theme.sizeBody
                font.italic: !card.specDescription
                color: card.specDescription ? Theme.textSecondary : Theme.inputBorder
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Статус (Badge)
            Rectangle {
                Layout.preferredWidth: statusText.width + 20
                Layout.preferredHeight: 25
                radius: 12
                color: {
                    switch(card.specStatus) {
                        case "черновик": return Theme.warningColor
                        case "утверждена": return Theme.successColor
                        case "архив": return Theme.textSecondary
                        default: return Theme.textSecondary
                    }
                }

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: card.specStatus
                    color: Theme.textOnPrimary
                    font.pixelSize: Theme.sizeCaption
                    font.bold: true
                    font.family: Theme.defaultFont.family
                }
            }

            // Даты
            RowLayout {
                spacing: 15

                Text {
                    text: "Создана: " + card.createdDate.split(" ")[0]
                    font.pixelSize: Theme.sizeSmall
                    font.family: Theme.defaultFont.family
                    color: Theme.inputBorder
                }
                Text {
                    text: "Изменена: " + card.modifiedDate.split(" ")[0]
                    font.pixelSize: Theme.sizeSmall
                    font.family: Theme.defaultFont.family
                    color: Theme.inputBorder
                }
            }
        }

        // ПРАВАЯ ЧАСТЬ - Цена и кнопки
        ColumnLayout {
            Layout.preferredWidth: 500
            Layout.minimumWidth: 500
            Layout.maximumWidth: 500
            Layout.preferredHeight: 105
            Layout.minimumHeight: 105
            Layout.maximumHeight: 105
            spacing: 10

            // Итоговая цена
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Qt.rgba(Theme.successColor.r, Theme.successColor.g, Theme.successColor.b, 0.1)
                border.color: Theme.successColor
                border.width: 2
                radius: Theme.smallRadius

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Итоговая цена"
                        font.pixelSize: Theme.sizeSmall
                        font.family: Theme.defaultFont.family
                        color: Theme.textSecondary
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (card.finalPrice !== undefined && card.finalPrice !== null)
                            ? Number(card.finalPrice).toFixed(2) + " ₽"
                            : "0 ₽"
                        font.pixelSize: Theme.sizeH3
                        font.bold: true
                        font.family: Theme.defaultFont.family
                        color: Theme.successColor
                    }
                }
            }

            // Кнопки действий
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                // Редактировать
                Button {
                    text: "✏️"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    font.pixelSize: 12
                    ToolTip.visible: hovered
                    ToolTip.text: "Редактировать"
                    onClicked: card.editClicked()

                    background: Rectangle {
                        color: parent.down ? "#1E2D44" : (parent.hovered ? "#3B5278" : "#2D4262")
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textOnPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Экспорт Excel
                Button {
                    text: "📊"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    font.pixelSize: 12
                    ToolTip.visible: hovered
                    ToolTip.text: "Экспорт Excel"
                    onClicked: card.exportExcel()

                    background: Rectangle {
                        color: parent.down ? "#4D6F6E" : (parent.hovered ? "#78A5A3" : "#66908F")
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textOnPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Экспорт PDF
                Button {
                    text: "📄"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    font.pixelSize: 12
                    ToolTip.visible: hovered
                    ToolTip.text: "Экспорт PDF"
                    onClicked: card.exportPDF()

                    background: Rectangle {
                        color: parent.down ? "#CC5A1A" : (parent.hovered ? "#FA812F" : "#E66F20")
                        radius: Theme.smallRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textOnPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Удалить
                Button {
                    text: "🗑️"
                    font.pixelSize: 12
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35
                    ToolTip.visible: hovered
                    ToolTip.text: "Удалить"
                    onClicked: card.deleteClicked()

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Theme.textOnPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#C41C1C" : (parent.hovered ? "#E63535" : Theme.errorColor)
                        radius: Theme.defaultRadius
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}
