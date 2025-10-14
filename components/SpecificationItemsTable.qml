// SpecificationItemsTable.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./"  // ✅ Импорт для доступа к Theme singleton

Rectangle {
    id: root
    border.color: Theme.border
    border.width: 1
    radius: 4
    color: Theme.background

    // Signals
    signal itemQuantityChanged(int row, real newQuantity)
    signal itemRemoved(int row)
    signal calculateCostsRequested()

    // Properties
    property alias model: tableView.model
    property int rowCount: tableView.rows

    // Use provided theme or internal fallback - this ensures theme is ALWAYS defined
    //property var Theme: (theme && theme.background !== undefined) ? theme : internalTheme

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Theme.tableHeader
            border.color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
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
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Статус"
                        font.bold: true
                        font.pointSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: Theme.border
                    }
                }

                // Delete column
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    color: "transparent"

                    // Empty header for delete button column
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

            // Explicitly define column widths to match header exactly
            columnWidthProvider: function(column) {
                var totalFixedWidth = 80 + 80 + 80 + 50 + 90 + 90 + 90 + 50  // ✅ Добавлено +90 для Status
                var flexibleSpace = tableView.width - totalFixedWidth
                var halfFlexible = flexibleSpace / 2

                switch(column) {
                    case 0: return 80   // Image
                    case 1: return 80  // Article
                    case 2: return halfFlexible  // Name (flexible)
                    case 3: return halfFlexible  // Category (flexible)
                    case 4: return 80   // Quantity
                    case 5: return 50   // Unit
                    case 6: return 90   // Price
                    case 7: return 90   // Total
                    case 8: return 90   // Status ✅ Изменено с 50 на 90
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
                color: row % 2 ? Theme.white : Theme.tableAlternate
                border.color: Theme.border
                border.width: 0

                // Right border for vertical line
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Theme.border
                }

                // Bottom border for horizontal line
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Theme.border
                }

                required property int row
                required property int column
                required property var model

                // Access the data through display role which returns the full item dictionary
                readonly property var itemData: (model && model.display) ? model.display : {}

                // Load data based on column
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
            // Контейнер для Label
           // Контейнер для Label
            Rectangle {
                anchors.fill: tableView.contentItem
                color: "transparent" // Прозрачный фон
                z: 10 // Высокий z-индекс, чтобы быть поверх содержимого
                visible: tableView.rows === 0 // Показываем только при пустой таблице

                Label {
                    anchors.centerIn: parent
                    text: "Нет материалов\nДобавьте позиции из склада"
                    font.pointSize: 11
                    color: Theme.textPlaceholder
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

    // Column Components
    Component {
        id: imageComponent

        Rectangle {
            color: Theme.background
            border.color: Theme.border
            border.width: 1
            radius: 4

            readonly property string imagePath: parent.itemData ? (parent.itemData.image_path || "") : ""
            readonly property bool hasImage: imagePath !== "" && imagePath !== null && imagePath !== undefined

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: parent.hasImage ? "../images/" + parent.imagePath : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: parent.hasImage
            }

            Text {
                anchors.centerIn: parent
                text: "📦"
                font.pointSize: 20
                visible: !parent.hasImage
                color: Theme.textPlaceholder
            }
        }
    }

    Component {
        id: articleComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.article || ""
            font.pointSize: 11
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
            font.pointSize: 11
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
            font.pointSize: 11
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
            font.pointSize: 11
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            validator: DoubleValidator { bottom: 0; decimals: 3 }

            property int rowIndex: parent.rowIndex

            onEditingFinished: {
                if (text !== "") {
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
                color: Theme.white
                border.color: parent.activeFocus ? Theme.primary : Theme.border
                border.width: 1
                radius: 3
            }
        }
    }

    Component {
        id: unitComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.unit || ""
            font.pointSize: 11
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
            font.pointSize: 11
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            color: Theme.textPrimary
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
            font.pointSize: 11
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            color: Theme.textSuccess
            width: parent.width
        }
    }

    Component {
        id: statusComponent

        Text {
            readonly property var data: parent.itemData || {}
            text: data.status || ""
            font.pointSize: 11
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

            property int rowIndex: parent.rowIndex

            onClicked: {
                root.itemRemoved(rowIndex)
            }

            background: Rectangle {
                color: parent.hovered ? Theme.danger : "transparent"
                radius: 3
            }

            contentItem: Text {
                text: "🗑️"
                font.pointSize: 14
                font.family: "Segoe UI Emoji"  // ✅ Шрифт с поддержкой эмодзи
                color: parent.parent.hovered ? Theme.textWhite : Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ToolTip.visible: hovered
            ToolTip.text: "Удалить позицию"
            ToolTip.delay: 500
        }
    }

}