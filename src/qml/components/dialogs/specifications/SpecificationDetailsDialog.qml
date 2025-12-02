// SpecificationDetailsDialog.qml - Диалог просмотра деталей спецификации
// Расположение: src/qml/components/specifications/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Local  // Доступ к старым компонентам (временно)

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

    contentItem: ScrollView {
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 15

            // ИНФОРМАЦИЯ
            GroupBox {
                Layout.fillWidth: true
                title: "Информация"

                background: Rectangle {
                    color: "white"
                    border.color: "#d0d0d0"
                    radius: 6
                    y: parent.topPadding - parent.bottomPadding
                }

                GridLayout {
                    anchors.fill: parent
                    columns: 4
                    columnSpacing: 15
                    rowSpacing: 6

                    Text { text: "Название:"; font.bold: true; font.pointSize: 9 }
                    Text { text: detailsDialog.specName; Layout.columnSpan: 3; font.pointSize: 9 }

                    Text { text: "Статус:"; font.bold: true; font.pointSize: 9 }
                    Text { text: detailsDialog.specStatus; font.pointSize: 9 }

                    Text { text: "Создана:"; font.bold: true; font.pointSize: 9 }
                    Text { text: detailsDialog.createdDate; font.pointSize: 9 }
                }
            }

            // МАТЕРИАЛЫ
            GroupBox {
                Layout.fillWidth: true
                title: "Материалы и комплектующие (" + (specificationItemsModel ? specificationItemsModel.rowCount() : 0) + " поз.)"

                background: Rectangle {
                    color: "white"
                    border.color: "#d0d0d0"
                    radius: 6
                    y: parent.topPadding - parent.bottomPadding
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "#e3f2fd"
                        radius: 4
                        visible: itemsTable.rowCount > 0

                        Text {
                            anchors.centerIn: parent
                            text: "📦 Позиций: " + itemsTable.rowCount + " | Стоимость материалов: " + (specificationItemsModel ? specificationItemsModel.getTotalMaterialsCost().toFixed(2) : "0.00") + " ₽"
                            font.pointSize: 10
                            font.bold: true
                            color: "#2196F3"
                        }
                    }

                    Local.SpecificationItemsTable {
                        id: itemsTable
                        Layout.fillWidth: true
                        Layout.preferredHeight: 500
                        model: specificationItemsModel
                        enabled: false
                        readOnly: true
                    }
                }
            }

            // КАЛЬКУЛЯЦИЯ
            GroupBox {
                Layout.fillWidth: true
                title: "Калькуляция"

                background: Rectangle {
                    color: "white"
                    border.color: "#d0d0d0"
                    radius: 6
                    y: parent.topPadding - parent.bottomPadding
                }

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 6

                    property real materialsCost: specificationItemsModel ? specificationItemsModel.getTotalMaterialsCost() : 0
                    property real overheadCost: materialsCost * (detailsDialog.overheadPercentage / 100)

                    Text { text: "Материалы:"; font.pointSize: 9 }
                    Text {
                        text: parent.materialsCost.toFixed(2) + " ₽"
                        font.pointSize: 9
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#007bff"
                    }

                    Text { text: "Работа:"; font.pointSize: 9 }
                    Text {
                        text: detailsDialog.laborCost.toFixed(2) + " ₽"
                        font.pointSize: 9
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#007bff"
                    }

                    Text { text: "Накладные (" + detailsDialog.overheadPercentage + "%):"; font.pointSize: 9 }
                    Text {
                        text: parent.overheadCost.toFixed(2) + " ₽"
                        font.pointSize: 9
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#007bff"
                    }

                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        height: 1
                        color: "#28a745"
                    }

                    Text { text: "ИТОГО:"; font.pointSize: 11; font.bold: true; color: "#28a745" }
                    Text {
                        text: detailsDialog.finalPrice.toFixed(2) + " ₽"
                        font.pointSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        color: "#28a745"
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "Закрыть"
            onClicked: detailsDialog.close()

            background: Rectangle {
                color: parent.down ? "#5a6268" : (parent.hovered ? "#6c757d" : "#6c757d")
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font: parent.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
