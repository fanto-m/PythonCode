// SpecificationCard.qml - Карточка спецификации в списке
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: card

    // Свойства для передачи данных
    required property int specId
    required property string specName
    required property string specDescription
    required property string specStatus
    required property real laborCost
    required property real overheadPercentage
    required property real finalPrice
    required property string createdDate
    required property string modifiedDate
    required property bool useLandscapeOrientation

    // Сигналы
    signal viewDetails()
    signal editClicked()
    signal exportExcel()
    signal exportPDF()
    signal deleteClicked()

    width: parent.width - 30
    height: 180
    color: "white"
    radius: 8
    border.color: "#d0d0d0"
    border.width: 1

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? "#f8f9fa" : "transparent"
        radius: 8
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

            Text {
                text: card.specName
                font.pointSize: 14
                font.bold: true
                color: "#2c3e50"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: card.specDescription || "Нет описания"
                font.pointSize: 9
                color: card.specDescription ? "#555" : "#999"
                font.italic: !card.specDescription
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: statusText.width + 20
                Layout.preferredHeight: 25
                radius: 12
                color: {
                    switch(card.specStatus) {
                        case "черновик": return "#ffc107"
                        case "утверждена": return "#28a745"
                        case "архив": return "#6c757d"
                        default: return "#6c757d"
                    }
                }

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: card.specStatus
                    color: "white"
                    font.pointSize: 9
                    font.bold: true
                }
            }

            RowLayout {
                spacing: 15

                Text {
                    text: "Создана: " + card.createdDate.split(" ")[0]
                    font.pointSize: 8
                    color: "#999"
                }
                Text {
                    text: "Изменена: " + card.modifiedDate.split(" ")[0]
                    font.pointSize: 8
                    color: "#999"
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
                color: "#e8f5e9"
                border.color: "#28a745"
                border.width: 2
                radius: 6

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Итоговая цена"
                        font.pointSize: 8
                        color: "#666"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (card.finalPrice !== undefined && card.finalPrice !== null)
                            ? Number(card.finalPrice).toFixed(2) + " ₽"
                            : "0 ₽"
                        font.pointSize: 14
                        font.bold: true
                        color: "#28a745"
                    }
                }
            }

            // Кнопки действий
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Button {
                    text: "✏️"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    font.pointSize: 12
                    ToolTip.visible: hovered
                    ToolTip.text: "Редактировать"
                    onClicked: card.editClicked()

                    background: Rectangle {
                        color: parent.down ? "#1E2D44" : (parent.hovered ? "#3B5278" : "#2D4262")
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "📄"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    font.pointSize: 12
                    ToolTip.visible: hovered
                    ToolTip.text: "Экспорт Excel"
                    onClicked: card.exportExcel()

                    background: Rectangle {
                        color: parent.down ? "#4D6F6E" : (parent.hovered ? "#78A5A3" : "#66908F")
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "📄"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    font.pointSize: 12
                    ToolTip.visible: hovered
                    ToolTip.text: "Экспорт PDF"
                    onClicked: card.exportPDF()

                    background: Rectangle {
                        color: parent.down ? "#CC5A1A" : (parent.hovered ? "#FA812F" : "#E66F20")
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "🗑️"
                    font.pointSize: 12
                    font.family: "Segoe UI Emoji, Apple Color Emoji, Noto Color Emoji"
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35
                    ToolTip.visible: hovered
                    ToolTip.text: "Удалить"
                    onClicked: card.deleteClicked()

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#C41C1C" : (parent.hovered ? "#E63535" : "#F34A4A")
                        radius: 8
                    }
                }
            }
        }
    }
}
