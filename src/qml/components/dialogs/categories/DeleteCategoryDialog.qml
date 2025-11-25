// qml/components/dialogs/categories/DeleteCategoryDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common"

Dialog {
    id: deleteCategoryDialogInternal
    title: "Удаление категории"
    modal: true
    width: 400
    height: 250
    standardButtons: Dialog.NoButton

    property int categoryId: -1
    property string categoryName: ""

    signal categoryDeleted(int id)

    // 🎨 Header с перемещением
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
                    text: deleteCategoryDialogInternal.title
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
                            deleteCategoryDialogInternal.x += delta.x
                            deleteCategoryDialogInternal.y += delta.y
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

                onClicked: deleteCategoryDialogInternal.reject()
            }
        }
    }

    contentItem: Item {
        implicitWidth: 400
        implicitHeight: 220

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Иконка предупреждения + текст
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 15

                Text {
                    text: "⚠️"
                    font.pixelSize: 48
                    opacity: 0
                    Component.onCompleted: {
                        opacity = 1
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 600 }
                    }
                }

                AppLabel {
                    text: "Удалить категорию:\n\"" + categoryName + "\"?"
                    level: "h3"
                    horizontalAlignment: Text.AlignLeft
                    enterDelay: 100
                }
            }

            Item { Layout.fillHeight: true }

            // Кнопки
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                AppButton {
                    text: "Отмена"
                    btnColor: "#666666"
                    Layout.preferredWidth: 100
                    enterDelay: 200
                    onClicked: deleteCategoryDialogInternal.reject()
                }

                AppButton {
                    text: "Удалить"
                    btnColor: Theme.errorColor
                    Layout.preferredWidth: 100
                    enterDelay: 250
                    onClicked: deleteCategoryDialogInternal.accept()
                }
            }
        }
    }

    function openFor(id, name) {
        categoryId = id
        categoryName = name
        open()
    }

    onAccepted: {
        if (categoryId >= 0) {
            categoryDeleted(categoryId)
        }
    }
}
