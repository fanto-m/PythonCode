// SpecificationDetailsDialog.qml - Диалог просмотра деталей спецификации
// Расположение: src/qml/components/dialogs/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../styles"
import "../../common" as Common
import "../../../../components" as Legacy  // Доступ к SpecificationItemsTable

Dialog {
    id: detailsDialog
    title: "Детали спецификации"
    modal: true
    width: 1400
    height: 900
    anchors.centerIn: parent

    property int specId: -1
    property string specName: ""
    property string specDescription: ""
    property string specStatus: ""
    property real laborCost: 0
    property real overheadPercentage: 0
    property real finalPrice: 0
    property string createdDate: ""
    property string modifiedDate: ""

    function openFor(id, name, desc, status, labor, overhead, price, created, modified) {
        specId = id
        specName = name
        specDescription = desc
        specStatus = status
        laborCost = labor
        overheadPercentage = overhead
        finalPrice = (price !== undefined && price !== null) ? price : 0
        createdDate = created
        modifiedDate = modified

        specificationItemsModel.clear()
        var items = specificationsModel.loadSpecificationItems(id)
        specificationItemsModel.loadItems(items)
        open()
    }

    onClosed: {
        specificationItemsModel.clear()
    }

    // === ФОН ДИАЛОГА ===
    background: Rectangle {
        color: "white"
        border.color: Theme.accentColor
        border.width: 2
        radius: Theme.defaultRadius
    }

    // === ЗАГОЛОВОК С ПЕРЕТАСКИВАНИЕМ ===
    header: Rectangle {
        width: parent.width
        height: 50
        color: Theme.accentColor
        radius: Theme.defaultRadius

        // Скругление только сверху
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.defaultRadius
            color: Theme.accentColor
        }

        Text {
            anchors.centerIn: parent
            text: "📋 Детали спецификации: " + detailsDialog.specName
            font.pixelSize: Theme.sizeH3
            font.bold: true
            font.family: Theme.defaultFont.family
            color: Theme.textOnPrimary
        }

        // Область для перетаскивания
        MouseArea {
            anchors.fill: parent
            property point clickPos: Qt.point(0, 0)
            onPressed: function(mouse) {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: function(mouse) {
                if (pressed) {
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    detailsDialog.x += delta.x
                    detailsDialog.y += delta.y
                }
            }
        }
    }

    contentItem: ScrollView {
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 15

            // === ИНФОРМАЦИЯ ===
            GroupBox {
                Layout.fillWidth: true
                title: "Информация"

                label: Text {
                    text: parent.title
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textColor
                    padding: 5
                }

                background: Rectangle {
                    color: "white"
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding - parent.bottomPadding
                }

                GridLayout {
                    anchors.fill: parent
                    columns: 4
                    columnSpacing: 15
                    rowSpacing: 8

                    Text {
                        text: "Название:"
                        font: Theme.boldFont
                        color: Theme.textColor
                    }
                    Text {
                        text: detailsDialog.specName
                        Layout.columnSpan: 3
                        font: Theme.defaultFont
                        color: Theme.textColor
                    }

                    Text {
                        text: "Статус:"
                        font: Theme.boldFont
                        color: Theme.textColor
                    }
                    Rectangle {
                        Layout.preferredWidth: statusLabel.width + 16
                        Layout.preferredHeight: 22
                        radius: 11
                        color: {
                            switch(detailsDialog.specStatus) {
                                case "черновик": return Theme.warningColor
                                case "утверждена": return Theme.successColor
                                case "архив": return Theme.textSecondary
                                default: return Theme.textSecondary
                            }
                        }
                        Text {
                            id: statusLabel
                            anchors.centerIn: parent
                            text: detailsDialog.specStatus
                            font.pixelSize: Theme.sizeCaption
                            font.bold: true
                            font.family: Theme.defaultFont.family
                            color: Theme.textOnPrimary
                        }
                    }

                    Text {
                        text: "Создана:"
                        font: Theme.boldFont
                        color: Theme.textColor
                    }
                    Text {
                        text: detailsDialog.createdDate
                        font: Theme.defaultFont
                        color: Theme.textSecondary
                    }

                    Text {
                        text: "Описание:"
                        font: Theme.boldFont
                        color: Theme.textColor
                        visible: detailsDialog.specDescription
                    }
                    Text {
                        text: detailsDialog.specDescription || ""
                        Layout.columnSpan: 3
                        font: Theme.defaultFont
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        visible: detailsDialog.specDescription
                    }
                }
            }

            // === МАТЕРИАЛЫ ===
            GroupBox {
                Layout.fillWidth: true
                title: "Материалы и комплектующие (" + (specificationItemsModel ? specificationItemsModel.rowCount() : 0) + " поз.)"

                label: Text {
                    text: parent.title
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textColor
                    padding: 5
                }

                background: Rectangle {
                    color: "white"
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // Итоговая строка
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: Qt.rgba(Theme.infoColor.r, Theme.infoColor.g, Theme.infoColor.b, 0.1)
                        radius: Theme.smallRadius
                        visible: itemsTable.rowCount > 0

                        Text {
                            anchors.centerIn: parent
                            text: "📦 Позиций: " + itemsTable.rowCount + " | Стоимость материалов: " + (specificationItemsModel ? specificationItemsModel.getTotalMaterialsCost().toFixed(2) : "0.00") + " ₽"
                            font: Theme.boldFont
                            color: Theme.infoColor
                        }
                    }

                    // Таблица материалов
                    Legacy.SpecificationItemsTable {
                        id: itemsTable
                        Layout.fillWidth: true
                        Layout.preferredHeight: 500
                        model: specificationItemsModel
                        enabled: false
                        readOnly: true
                    }
                }
            }

            // === КАЛЬКУЛЯЦИЯ ===
            GroupBox {
                Layout.fillWidth: true
                title: "Калькуляция"

                label: Text {
                    text: parent.title
                    font.pixelSize: Theme.sizeBody
                    font.bold: true
                    font.family: Theme.defaultFont.family
                    color: Theme.textColor
                    padding: 5
                }

                background: Rectangle {
                    color: "white"
                    border.color: Theme.inputBorder
                    radius: Theme.smallRadius
                    y: parent.topPadding - parent.bottomPadding
                }

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 8

                    property real materialsCost: specificationItemsModel ? specificationItemsModel.getTotalMaterialsCost() : 0
                    property real overheadCost: materialsCost * (detailsDialog.overheadPercentage / 100)

                    Text {
                        text: "Материалы:"
                        font: Theme.defaultFont
                        color: Theme.textColor
                    }
                    Text {
                        text: parent.materialsCost.toFixed(2) + " ₽"
                        font: Theme.boldFont
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.primaryColor
                    }

                    Text {
                        text: "Работа:"
                        font: Theme.defaultFont
                        color: Theme.textColor
                    }
                    Text {
                        text: detailsDialog.laborCost.toFixed(2) + " ₽"
                        font: Theme.boldFont
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.primaryColor
                    }

                    Text {
                        text: "Накладные (" + detailsDialog.overheadPercentage + "%):"
                        font: Theme.defaultFont
                        color: Theme.textColor
                    }
                    Text {
                        text: parent.overheadCost.toFixed(2) + " ₽"
                        font: Theme.boldFont
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.primaryColor
                    }

                    // Разделитель
                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        height: 2
                        color: Theme.successColor
                    }

                    Text {
                        text: "ИТОГО:"
                        font.pixelSize: Theme.sizeH3
                        font.bold: true
                        font.family: Theme.defaultFont.family
                        color: Theme.successColor
                    }
                    Text {
                        text: detailsDialog.finalPrice.toFixed(2) + " ₽"
                        font.pixelSize: Theme.sizeH2
                        font.bold: true
                        font.family: Theme.defaultFont.family
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: Theme.successColor
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignRight
        padding: 12

        background: Rectangle {
            color: Theme.backgroundColor
            radius: Theme.smallRadius
        }

        Common.AppButton {
            text: "Закрыть"
            btnColor: Theme.textSecondary
            animateEntry: false
            onClicked: detailsDialog.close()
        }
    }

    // === АНИМАЦИИ ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 250; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1; to: 0.95; duration: 150; easing.type: Easing.InCubic }
        }
    }
}
