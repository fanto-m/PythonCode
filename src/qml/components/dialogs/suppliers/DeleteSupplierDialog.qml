// qml/components/dialogs/suppliers/DeleteSupplierDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: root
    title: "Удаление поставщика"
    modal: true
    width: 500
    height: 220
    standardButtons: Dialog.NoButton

    property int supplierId: -1
    property string companyName: ""

    signal supplierDeleted(int id)

    // 🎨 Header с перемещением (красный)
    header: Rectangle {
        width: parent.width
        height: 50
        color: Theme.errorColor
        radius: Theme.defaultRadius

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.defaultRadius
            color: parent.color
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 10
            spacing: 10

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "☰"
                    color: Theme.textOnPrimary
                    font.pixelSize: 20
                    opacity: 0.7
                }

                Text {
                    anchors.centerIn: parent
                    text: root.title
                    font: Theme.boldFont
                    color: Theme.textOnPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    property point clickPos: Qt.point(0, 0)

                    onPressed: function(mouse) {
                        clickPos = Qt.point(mouse.x, mouse.y)
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                            root.x += delta.x
                            root.y += delta.y
                        }
                    }
                }
            }

            ToolButton {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: "✕"
                font.pixelSize: 16
                font.bold: true

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: Theme.textOnPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? Qt.lighter(Theme.errorColor, 1.2) : "transparent"
                    radius: Theme.smallRadius
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                onClicked: reject()
            }
        }
    }

    contentItem: Item {
        implicitWidth: 400
        implicitHeight: 250

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 0  // Убираем автоматический spacing

            // Иконка + текст (ФИКСИРОВАННАЯ ВЫСОТА)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 100  // 🔒 ФИКСИРОВАННАЯ ВЫСОТА
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignTop
                    text: "⚠️"
                    font.pixelSize: 48
                    opacity: 0
                    Component.onCompleted: opacity = 1
                    Behavior on opacity { NumberAnimation { duration: 600 } }
                }

                // ScrollView для длинного текста
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    AppLabel {
                        width: parent.width
                        text: "Удалить поставщика:\n" + companyName + "?"
                        level: "h3"
                        wrapMode: Text.WordWrap
                        enterDelay: 100
                    }
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
                Layout.preferredHeight: 10
            }

            // Кнопки (ФИКСИРОВАННОЕ ПОЛОЖЕНИЕ)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40  // 🔒 ФИКСИРОВАННАЯ ВЫСОТА
                spacing: 10

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "Отмена"
                    btnColor: "#666666"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    enterDelay: 200
                    onClicked: reject()
                }

                AppButton {
                    text: "Удалить"
                    btnColor: Theme.errorColor
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    enterDelay: 250
                    onClicked: {
                        supplierDeleted(supplierId)
                        accept()
                    }
                }
            }

            // Нижний отступ
            Item {
                Layout.preferredHeight: 10
            }
        }
    }

    function openFor(id, name) {
        supplierId = id
        companyName = name
        open()
    }
}
