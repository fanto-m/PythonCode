//ErrorDialog.qml
import QtQuick
import QtQuick.Controls

Dialog {
    id: errorDialogInternal
    title: "Ошибка"
    modal: true
    width: 400
    height: 200

    property alias errorText: errorTextInternal.text

    background: Rectangle {
        color: "#fff3f3"
        border.width: 2
        border.color: "#f44336"
        radius: 4
    }

    contentItem: Text {
        id: errorTextInternal
        text: ""
        anchors.centerIn: parent
        wrapMode: Text.WordWrap
        width: parent.width - 40
        color: "#d32f2f"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    standardButtons: Dialog.Ok
    function showMessage(message) {
        errorText = message
        open()
    }
}
