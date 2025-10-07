import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

FileDialog {
    id: fileDialogInternal
    title: "Выберите изображение"
    nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp)"]

    signal imageSelected(string path)

    onAccepted: {
        var fileUrl = fileDialogInternal.selectedFile.toString()
        var localPath = fileUrl.replace(/^file:\/\/\//, "")
        if (Qt.platform.os === "windows" && localPath.startsWith("/"))
            localPath = localPath.substring(1)
        imageSelected(localPath)
    }
}
