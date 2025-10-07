// components/DeleteSupplierDialog.qml - Improved Version
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: deleteSupplierDialog
    title: "Удаление поставщика"
    modal: true
    width: Math.min(Screen.width * 0.4, 500)
    height: Math.min(Screen.height * 0.4, 300)

    // Theme constants
    readonly property color dangerColor: "#f44336"
    readonly property color warningColor: "#ff9800"
    readonly property color borderColor: "#d0d0d0"
    readonly property int baseSpacing: 12
    readonly property int baseFontSize: 10

    property int supplierId: -1
    property string companyName: ""

    signal supplierDeleted(int id)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: baseSpacing + 8

        // Warning icon and header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#ffebee"
            border.color: dangerColor
            border.width: 2
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: baseSpacing
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⚠️"
                    font.pointSize: 32
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: "Подтверждение удаления"
                    font.pointSize: baseFontSize + 4
                    font.bold: true
                    color: "#c62828"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Warning message
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#fff3e0"
            border.color: warningColor
            border.width: 1
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: baseSpacing + 4
                spacing: baseSpacing

                Text {
                    Layout.fillWidth: true
                    text: "Вы действительно хотите удалить поставщика?"
                    font.pointSize: baseFontSize + 1
                    font.bold: true
                    color: "#212121"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // Company name display
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "white"
                    border.color: borderColor
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "\"" + companyName + "\""
                        font.pointSize: baseFontSize + 2
                        font.bold: true
                        color: dangerColor
                        elide: Text.ElideMiddle
                        width: parent.width - 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Это действие нельзя отменить!"
                    font.pointSize: baseFontSize
                    font.italic: true
                    color: "#e65100"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // Additional warning info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Последствия удаления:"
                        font.pointSize: baseFontSize - 1
                        font.bold: true
                        color: "#616161"
                    }

                    Text {
                        text: "• Все привязки к товарам будут удалены"
                        font.pointSize: baseFontSize - 1
                        color: "#757575"
                    }

                    Text {
                        text: "• История заказов останется без изменений"
                        font.pointSize: baseFontSize - 1
                        color: "#757575"
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    footer: DialogButtonBox {
        background: Rectangle {
            color: "#fafafa"
            border.color: borderColor
            border.width: 1
        }

        Button {
            text: "🗑️ Удалить"
            font.pointSize: baseFontSize

            background: Rectangle {
                color: {
                    if (parent.down) return Qt.darker(dangerColor, 1.3)
                    if (parent.hovered) return Qt.darker(dangerColor, 1.1)
                    return dangerColor
                }
                radius: 4
                border.width: 0
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                supplierDeleted(supplierId)
                close()
            }
        }

        Button {
            text: "Отмена"
            font.pointSize: baseFontSize
            highlighted: true

            background: Rectangle {
                color: {
                    if (parent.down) return Qt.darker("#4caf50", 1.2)
                    if (parent.hovered) return Qt.lighter("#4caf50", 1.1)
                    return "#4caf50"
                }
                radius: 4
                border.width: 0
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: close()
        }
    }

    function openFor(id, name) {
        supplierId = id
        companyName = name
        open()
    }

    // Animation on open
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 200
        }
        NumberAnimation {
            property: "scale"
            from: 0.9
            to: 1.0
            duration: 200
            easing.type: Easing.OutBack
        }
    }

    // Animation on close
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 150
        }
        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.95
            duration: 150
        }
    }
}