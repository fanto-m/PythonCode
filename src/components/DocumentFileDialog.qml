import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

FileDialog {
    id: documentDialog
    title: "Выберите документ"
    nameFilters: ["PDF files (*.pdf)", "All files (*.*)"]

    signal documentSelected(string path)

    function openDocument(documentPath) {
        if (documentPath) {
            console.debug("Нажата кнопка 'Документ'")
            console.debug("Документ существует:", documentPath)

            // Формируем путь относительно папки приложения
            var fullPath = applicationDirPath + "/documents/" + documentPath

            // Нормализуем слеши в пути
            fullPath = fullPath.replace(/\\/g, "/")

            console.debug("Сформирован путь:", fullPath)
            return Qt.openUrlExternally("file:///" + fullPath)
        }
        return false
    }

    onAccepted: {
        var fileUrl = selectedFile.toString()
        var localPath = fileUrl.replace(/^file:\/\/\//, "")
        if (Qt.platform.os === "windows" && localPath.startsWith("/")) {
            localPath = localPath.substring(1)
        }
        documentSelected(localPath)
    }
}
