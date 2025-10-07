//DeleteCategoryDialog.qml
import QtQuick
import QtQuick.Controls

Dialog {
    id: deleteCategoryDialogInternal
    title: "Удаление категории"
    modal: true
    width: 400
    height: 200
    standardButtons: Dialog.Ok | Dialog.Cancel

    property int categoryId: -1
    property string categoryName: ""

    signal categoryDeleted(int id)

    contentItem: Text {
        text: "Удалить категорию: \"" + categoryName + "\"?"
        anchors.centerIn: parent
        font.pixelSize: 18  // Устанавливаем размер шрифта, например, 18 пикселей
    }

    function openFor(id, name) {
        categoryId = id
        categoryName = name
        open()
    }

    onAccepted: if (categoryId >= 0)
                    categoryDeleted(categoryId)
}
