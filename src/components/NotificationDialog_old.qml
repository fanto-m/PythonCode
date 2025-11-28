import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./" as Local
import "./"

Dialog {
    id: root

    modal: true
    width: 400
    anchors.centerIn: parent
    property string dialogType: "warning" // "success", "error", "warning", "info"
    property string message: ""
    property bool showCancelButton: false



    background: Rectangle {

        color: Theme.white
        border.color: {
            switch (root.dialogType) {
                case "success": return Theme.success
                case "error": return Theme.danger
                case "warning": return Theme.warning
                default: return Theme.border
            }
        }
        border.width: 2
        radius: 6
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            text: {
                switch (root.dialogType) {
                    case "success": return "✅ "+ root.message
                    case "error": return "❌ "+ root.message
                    case "warning": return "⚠️ "+ root.message
                    default: return "ℹ️ "+ root.message
                }
            }
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.pointSize: 10
            color: Theme.textPrimary
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "OK"
            onClicked: root.accept()
            background: Rectangle {
                color: parent.down ? Theme.successDark : (parent.hovered ? Theme.successHover : Theme.success)
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                color: Theme.textWhite
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Button {
            text: "Отмена"
            visible: root.showCancelButton
            onClicked: root.reject()
            background: Rectangle {
                color: parent.down ? Theme.neutralDark : (parent.hovered ? Theme.neutralHover : Theme.neutral)
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                color: Theme.textWhite
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        NumberAnimation { property: "scale"; from: 1; to: 0.9; duration: 200 }
    }
}