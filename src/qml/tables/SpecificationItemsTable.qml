// SpecificationItemsTable.qml - Таблица позиций спецификации
// Расположение: src/qml/tables/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Rectangle {
    id: root
    border.color: Theme.inputBorder
    border.width: 1
    radius: Theme.smallRadius
    color: Theme.backgroundColor

    // Signals
    signal itemQuantityChanged(int row, real newQuantity)
    signal itemRemoved(int row)
    signal calculateCostsRequested()

    // Properties
    property alias model: tableView.model
    property int rowCount: tableView.rows
    property bool readOnly: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Theme.accentColor
            border.color: Theme.inputBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0

                // Image column
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Вид"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Article column
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Артикул"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Name column
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Название"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Category column
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Категория"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Quantity column
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Кол-во"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Unit column
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Ед."
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Price column
                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Цена"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Total column
                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Сумма"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Status column
                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Статус"
                        font.bold: true
                        font.pixelSize: Theme.sizeBody
                        font.family: Theme.defaultFont.family
                        color: Theme.textOnPrimary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Qt.rgba(255, 255, 255, 0.3)
                    }
                }

                // Delete column
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    color: "transparent"
                    visible: !root.readOnly
                }
            }
        }

        // Table View
        TableView {
            id: tableView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            columnSpacing: 0
            rowSpacing: 0

            columnWidthProvider: function(column) {
                var totalFixedWidth = 80 + 80 + 80 + 50 + 90 + 90 + 90 + 50
                var flexibleSpace = tableView.width - totalFixedWidth
                var halfFlexible = flexibleSpace / 2

                switch(column) {
                    case 0: return 80   // Image
                    case 1: return 80   // Article
                    case 2: return halfFlexible  // Name (flexible)
                    case 3: return halfFlexible  // Category (flexible)
                    case 4: return 80   // Quantity
                    case 5: return 50   // Unit
                    case 6: return 90   // Price
                    case 7: return 90   // Total
                    case 8: return 90   // Status
                    case 9: return 50   // Delete button
                    default: return 100
                }
            }

            rowHeightProvider: function(row) {
                return 70
            }

            delegate: Rectangle {
                implicitWidth: 100
                implicitHeight: 70
                color: row % 2 ? "white" : Theme.backgroundColor
                border.color: Theme.inputBorder
                border.width: 0

                // Right border
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Theme.inputBorder
                }

                // Bottom border
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Theme.inputBorder
                }

                required property int row
                required property int column
                required property var model

                readonly property var itemData: (model && model.display) ? model.display : {}

                Loader {
                    anchors.fill: parent
                    anchors.leftMargin: column === 0 ? 10 : 10
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5

                    sourceComponent: {
                        switch(column) {
                            case 0: return imageComponent
                            case 1: return articleComponent
                            case 2: return nameComponent
                            case 3: return categoryComponent
                            case 4: return quantityComponent
                            case 5: return unitComponent
                            case 6: return priceComponent
                            case 7: return totalComponent
                            case 8: return statusComponent
                            case 9: return deleteComponent
                            default: return null
                        }
                    }

                    property int rowIndex: row
                    property var itemData: parent.itemData
                }
            }

            // Empty state
            Rectangle {
                anchors.fill: tableView.contentItem
                color: "transparent"
                z: 10
                visible: tableView.rows === 0

                Label {
                    anchors.centerIn: parent
                    text: "Нет материалов\nДобавьте позиции из склада"
                    font: Theme.defaultFont
                    color: Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }

    // === COLUMN COMPONENTS ===

    Component {
        id: imageComponent

        Rectangle {
            color: Theme.backgroundColor
            border.color: Theme.inputBorder
            border.width: 1
            radius: Theme.smallRadius

            readonly property string imagePath: parent.itemData ? (parent.itemData.image_path || "") : ""
            readonly property bool hasImage: imagePath !== "" && imagePath !== null && imagePath !== undefined

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: parent.hasImage ? "../../" + parent.imagePath : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: parent.hasImage

                onStatusChanged: {
                    if (status === Image.Error) {
                        console.error("❌ Failed to load:", parent.imagePath)
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "📦"
                font.pixelSize: 20
                visible: !parent.hasImage
                color: Theme.textSecondary
            }
        }
    }

    Component {
        id: articleComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.article || ""
            font: Theme.defaultFont
            color: Theme.textColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            width: parent.width
        }
    }

    Component {
        id: nameComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.name || ""
            font: Theme.boldFont
            color: Theme.textColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            width: parent.width
        }
    }

    Component {
        id: categoryComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.category || ""
            font: Theme.defaultFont
            color: Theme.textSecondary
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            width: parent.width
        }
    }

    Component {
        id: quantityComponent

        TextField {
            readonly property var data: parent.itemData || {}
            readonly property real quantityValue: data.quantity !== undefined ? parseFloat(data.quantity) : 0.0
            text: quantityValue.toString()
            font: Theme.defaultFont
            color: Theme.textColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            validator: DoubleValidator { bottom: 0; decimals: 3 }
            readOnly: root.readOnly

            property int rowIndex: parent.rowIndex

            onEditingFinished: {
                if (text !== "" && !root.readOnly) {
                    let oldValue = quantityValue.toString()
                    if (text !== oldValue) {
                        let newValue = parseFloat(text)
                        if (!isNaN(newValue) && newValue >= 0) {
                            root.itemQuantityChanged(rowIndex, newValue)
                        }
                    }
                }
            }

            background: Rectangle {
                color: root.readOnly ? Theme.backgroundColor : "white"
                border.color: parent.activeFocus ? Theme.accentColor : Theme.inputBorder
                border.width: 1
                radius: Theme.smallRadius
            }
        }
    }

    Component {
        id: unitComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.unit || ""
            font: Theme.defaultFont
            color: Theme.textSecondary
            verticalAlignment: Text.AlignVCenter
            width: parent.width
        }
    }

    Component {
        id: priceComponent

        Text {
            readonly property var data: parent.itemData || {}
            readonly property real priceValue: data.price !== undefined ? parseFloat(data.price) : 0.0
            text: priceValue.toFixed(2) + " ₽"
            font: Theme.defaultFont
            color: Theme.textColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            width: parent.width
        }
    }

    Component {
        id: totalComponent

        Text {
            readonly property var data: parent.itemData || {}
            readonly property real quantityValue: data.quantity !== undefined ? parseFloat(data.quantity) : 0.0
            readonly property real priceValue: data.price !== undefined ? parseFloat(data.price) : 0.0
            text: (quantityValue * priceValue).toFixed(2) + " ₽"
            font: Theme.boldFont
            color: Theme.successColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            width: parent.width
        }
    }

    Component {
        id: statusComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.status || ""
            font: Theme.defaultFont
            color: Theme.textSecondary
            verticalAlignment: Text.AlignVCenter
            width: parent.width
        }
    }

    Component {
        id: deleteComponent

        Button {
            width: 40
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.readOnly

            property int rowIndex: parent.rowIndex

            onClicked: {
                root.itemRemoved(rowIndex)
            }

            background: Rectangle {
                color: parent.hovered ? Theme.errorColor : "transparent"
                radius: Theme.smallRadius
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: "🗑️"
                font.pixelSize: 14
                color: parent.parent.hovered ? Theme.textOnPrimary : Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ToolTip.visible: hovered
            ToolTip.text: "Удалить позицию"
            ToolTip.delay: 500
        }
    }
}
