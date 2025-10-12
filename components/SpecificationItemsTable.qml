// SpecificationItemsTable.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    border.color: activeTheme.border
    border.width: 1
    radius: 4
    color: activeTheme.background

    // Signals
    signal itemQuantityChanged(int row, real newQuantity)
    signal itemRemoved(int row)
    signal calculateCostsRequested()

    // Properties
    property var theme: null  // Theme object can be passed from parent (optional)
    property alias model: tableView.model
    property int rowCount: tableView.rows

    // Internal theme object - always available as fallback
    QtObject {
        id: internalTheme
        property color background: "#f5f5f5"
        property color white: "#ffffff"
        property color border: "#d0d0d0"
        property color tableHeader: "#e0e0e0"
        property color tableAlternate: "#fafafa"
        property color primary: "#2196F3"
        property color danger: "#f44336"
        property color success: "#4caf50"
        property color textPrimary: "#212121"
        property color textSecondary: "#757575"
        property color textPlaceholder: "#9e9e9e"
        property color textWhite: "#ffffff"
        property color textSuccess: "#2e7d32"
    }

    // Use provided theme or internal fallback - this ensures theme is ALWAYS defined
    property var activeTheme: (theme && theme.background !== undefined) ? theme : internalTheme

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: activeTheme.tableHeader
            border.color: activeTheme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0

                // Image column
                Rectangle {
                    Layout.preferredWidth: 60
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
                        color: activeTheme.border
                    }
                }

                // Article column
                Rectangle {
                    Layout.preferredWidth: 100
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
                        color: activeTheme.border
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
                        color: activeTheme.border
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
                        color: activeTheme.border
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
                        color: activeTheme.border
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
                        color: activeTheme.border
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
                        color: activeTheme.border
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
                        color: activeTheme.border
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
                var totalFixedWidth = 60 + 100 + 80 + 50 + 90 + 90 + 50  // Sum of fixed widths
                var flexibleSpace = tableView.width - totalFixedWidth
                var halfFlexible = flexibleSpace / 2

                switch(column) {
                    case 0: return 60   // Image
                    case 1: return 100  // Article
                    case 2: return halfFlexible  // Name (flexible)
                    case 3: return halfFlexible  // Category (flexible)
                    case 4: return 80   // Quantity
                    case 5: return 50   // Unit
                    case 6: return 90   // Price
                    case 7: return 90   // Total
                    case 8: return 50   // Delete button
                    default: return 100
                }
            }

            rowHeightProvider: function(row) {
                return 60
            }

            delegate: Rectangle {
                implicitWidth: 100
                implicitHeight: 60
                color: row % 2 ? activeTheme.white : activeTheme.tableAlternate
                border.color: activeTheme.border
                border.width: 0

                // Right border for vertical line
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: activeTheme.border
                }

                // Bottom border for horizontal line
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: activeTheme.border
                }

                required property int row
                required property int column
                required property var model

                // Access the data through display role which returns the full item dictionary
                readonly property var itemData: model.display || {}

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
                            case 8: return deleteComponent
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
                    color: activeTheme.textPlaceholder
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
            color: activeTheme.background
            border.color: activeTheme.border
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
                color: activeTheme.textPlaceholder
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
                color: activeTheme.white
                border.color: parent.activeFocus ? activeTheme.primary : activeTheme.border
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
            color: activeTheme.textPrimary
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
            color: activeTheme.textSuccess
            width: parent.width
        }
    }

    Component {
        id: deleteComponent

        Button {
            text: "🗑️"
            width: 40
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 10

            property int rowIndex: parent.rowIndex

            onClicked: {
                root.itemRemoved(rowIndex)
            }

            background: Rectangle {
                color: parent.hovered ? activeTheme.danger : "transparent"
                radius: 3
            }

            ToolTip.visible: hovered
            ToolTip.text: "Удалить позицию"
            ToolTip.delay: 500
        }
    }
}