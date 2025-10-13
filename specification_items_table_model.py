# specification_items_table_model.py
from PySide6.QtCore import QAbstractTableModel, Qt, QModelIndex, Slot, Signal


class SpecificationItemsTableModel(QAbstractTableModel):
    """
    Table model for specification items with columns:
    Image | Article | Name | Category | Quantity | Unit | Price | Total | Delete
    """

    # Define column indices
    COL_IMAGE = 0
    COL_ARTICLE = 1
    COL_NAME = 2
    COL_CATEGORY = 3
    COL_QUANTITY = 4
    COL_UNIT = 5
    COL_PRICE = 6
    COL_TOTAL = 7
    COL_STATUS = 8
    COL_DELETE = 9

    COLUMN_COUNT = 10

    # Custom signals
    totalCostChanged = Signal(float)

    def __init__(self):
        super().__init__()
        self._items = []
        self._headers = [
            "Вид", "Артикул", "Название", "Категория",
            "Кол-во", "Ед.", "Цена", "Сумма", "Статус", "Удалить"
        ]

    def rowCount(self, parent=QModelIndex()):
        """Return number of rows"""
        if parent.isValid():
            return 0
        return len(self._items)

    def columnCount(self, parent=QModelIndex()):
        """Return number of columns"""
        if parent.isValid():
            return 0
        return self.COLUMN_COUNT

    def data(self, index, role=Qt.DisplayRole):
        """Return data for given index and role"""
        if not index.isValid():
            return None

        if index.row() >= len(self._items) or index.row() < 0:
            return None

        item = self._items[index.row()]
        column = index.column()

        # For TableView in QML, we need to handle both column-based and role-based access
        # TableView uses DisplayRole with column indices

        # Handle custom roles for direct property access (model.property_name)
        if role >= Qt.UserRole:
            if role == Qt.UserRole + 1:  # image_path
                value = item.get('image_path', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 2:  # article
                value = item.get('article', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 3:  # name
                value = item.get('name', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 4:  # category
                value = item.get('category', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 5:  # quantity
                value = item.get('quantity', 0.0)
                return float(value) if value is not None else 0.0
            elif role == Qt.UserRole + 6:  # unit
                value = item.get('unit', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 7:  # price
                value = item.get('price', 0.0)
                return float(value) if value is not None else 0.0
            elif role == Qt.UserRole + 8:  # total
                quantity = item.get('quantity', 0.0)
                price = item.get('price', 0.0)
                return float(quantity) * float(price) if (quantity is not None and price is not None) else 0.0
            elif role == Qt.UserRole + 9:  # status
                value = item.get('status', '')
                return value if value is not None else ''
            return None

        # Handle DisplayRole for column-based access (TableView)
        if role == Qt.DisplayRole or role == Qt.EditRole:
            # Return ALL data as a dictionary for the entire row
            # TableView will access it via model.property_name
            return item

        return None

    def setData(self, index, value, role=Qt.EditRole):
        """Set data for given index"""
        if not index.isValid():
            return False

        if index.row() >= len(self._items) or index.row() < 0:
            return False

        if role == Qt.EditRole:
            column = index.column()
            item = self._items[index.row()]

            if column == self.COL_QUANTITY:
                try:
                    new_quantity = float(value)
                    if new_quantity >= 0:
                        item['quantity'] = new_quantity
                        # Emit dataChanged for both quantity and total columns
                        self.dataChanged.emit(index, self.index(index.row(), self.COL_TOTAL))
                        self._emitTotalCostChanged()
                        return True
                except (ValueError, TypeError):
                    return False

        return False

    def flags(self, index):
        """Return item flags"""
        if not index.isValid():
            return Qt.NoItemFlags

        flags = Qt.ItemIsEnabled | Qt.ItemIsSelectable

        # Only quantity column is editable
        if index.column() == self.COL_QUANTITY:
            flags |= Qt.ItemIsEditable

        return flags

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        """Return header data"""
        if role == Qt.DisplayRole:
            if orientation == Qt.Horizontal:
                if 0 <= section < len(self._headers):
                    return self._headers[section]
        return None

    def roleNames(self):
        """Define role names for QML access"""
        roles = {
            Qt.DisplayRole: b"display",
            Qt.UserRole + 1: b"image_path",
            Qt.UserRole + 2: b"article",
            Qt.UserRole + 3: b"name",
            Qt.UserRole + 4: b"category",
            Qt.UserRole + 5: b"quantity",
            Qt.UserRole + 6: b"unit",
            Qt.UserRole + 7: b"price",
            Qt.UserRole + 8: b"total",
            Qt.UserRole + 9: b"status"

        }

        # For TableView to work properly, we also need the column data accessible by name
        # This maps model.property_name in QML delegates
        return roles

    @Slot(str, str, float, str, float, str, str, str)
    def addItem(self, article, name, quantity, unit, price, image_path="", category="", status=""):
        """Add new item to specification"""
        print(f"\n=== DEBUG: addItem called ===")
        print(f"Article: {article} (type: {type(article)})")
        print(f"Name: {name} (type: {type(name)})")
        print(f"Quantity: {quantity} (type: {type(quantity)})")
        print(f"Unit: {unit} (type: {type(unit)})")
        print(f"Price: {price} (type: {type(price)})")
        print(f"Image: {image_path} (type: {type(image_path)})")
        print(f"Category: {category} (type: {type(category)})")
        print(f"Status: {status} (type: {type(status)})")

        row = len(self._items)
        self.beginInsertRows(QModelIndex(), row, row)

        # Ensure all values are properly typed and not None
        item = {
            'article': str(article) if article is not None else '',
            'name': str(name) if name is not None else '',
            'quantity': float(quantity) if quantity is not None else 1.0,
            'unit': str(unit) if unit is not None else 'шт.',
            'price': float(price) if price is not None else 0.0,
            'image_path': str(image_path) if image_path is not None else '',
            'category': str(category) if category is not None else '',
            'status': str(status) if status is not None else '',
        }

        print(f"Created item dict: {item}")

        self._items.append(item)
        print(f"Total items now: {len(self._items)}")

        self.endInsertRows()
        self._emitTotalCostChanged()

        print(f"=== DEBUG: addItem completed ===\n")

    @Slot(int)
    def removeItem(self, row):
        """Remove item at specified row"""
        if 0 <= row < len(self._items):
            self.beginRemoveRows(QModelIndex(), row, row)
            removed_item = self._items.pop(row)
            self.endRemoveRows()
            self._emitTotalCostChanged()

            print(f"DEBUG: Removed item at row {row}: {removed_item.get('name', '')}")
            return True
        return False

    @Slot(int, float)
    def updateQuantity(self, row, new_quantity):
        """Update quantity for item at specified row"""
        if 0 <= row < len(self._items):
            try:
                quantity = float(new_quantity)
                if quantity >= 0:
                    self._items[row]['quantity'] = quantity

                    # Emit dataChanged for quantity and total columns
                    index_start = self.index(row, self.COL_QUANTITY)
                    index_end = self.index(row, self.COL_TOTAL)
                    self.dataChanged.emit(index_start, index_end)

                    self._emitTotalCostChanged()

                    print(f"DEBUG: Updated quantity for row {row}: {quantity}")
                    return True
            except (ValueError, TypeError) as e:
                print(f"ERROR: Invalid quantity value: {e}")
        return False

    @Slot(result=float)
    def getTotalMaterialsCost(self):
        """Calculate total cost of all materials"""
        total = sum(
            item.get('quantity', 0.0) * item.get('price', 0.0)
            for item in self._items
        )
        return float(total)

    @Slot()
    def clear(self):
        """Clear all items"""
        if len(self._items) > 0:
            self.beginResetModel()
            self._items.clear()
            self.endResetModel()
            self._emitTotalCostChanged()
            print("DEBUG: Cleared all specification items")

    @Slot(result=list)
    def getAllItems(self):
        """Get all items as list of dictionaries"""
        print(f"DEBUG: getAllItems called, returning {len(self._items)} items")
        items_copy = self._items.copy()
        for i, item in enumerate(items_copy):
            print(
                f"  Item {i}: {item.get('article')} - {item.get('name')}, qty={item.get('quantity')}, price={item.get('price')}")
        return items_copy

    @Slot(result=list)
    def getItems(self):
        """Alias for getAllItems - for compatibility"""
        return self.getAllItems()

    @Slot(result=int)
    def count(self):
        """Get number of items"""
        return len(self._items)

    @Slot(result=int)
    def itemCount(self):
        """Alias for count - for compatibility"""
        return self.count()

    @Slot()
    def debugPrintItems(self):
        """Debug method to print all items"""
        print(f"\n=== DEBUG: Current items in model ===")
        print(f"Total items: {len(self._items)}")
        for i, item in enumerate(self._items):
            print(f"Item {i}:")
            for key, value in item.items():
                print(f"  {key}: {value} (type: {type(value)})")
        print(f"=== END DEBUG ===\n")

    @Slot(list)
    def loadItems(self, items):
        """Load items from list of dictionaries"""
        self.beginResetModel()
        self._items = []

        for item_data in items:
            # Ensure all values are properly typed and not None
            item = {
                'article': str(item_data.get('article', '')) if item_data.get('article') is not None else '',
                'name': str(item_data.get('name', '')) if item_data.get('name') is not None else '',
                'quantity': float(item_data.get('quantity', 1.0)) if item_data.get('quantity') is not None else 1.0,
                'unit': str(item_data.get('unit', 'шт.')) if item_data.get('unit') is not None else 'шт.',
                'price': float(item_data.get('price', 0.0)) if item_data.get('price') is not None else 0.0,
                'image_path': str(item_data.get('image_path', '')) if item_data.get('image_path') is not None else '',
                'category': str(item_data.get('category', '')) if item_data.get('category') is not None else '',
                'status': str(item_data.get('status', '')) if item_data.get('status') is not None else ''
            }
            self._items.append(item)

        self.endResetModel()
        self._emitTotalCostChanged()
        print(f"DEBUG: Loaded {len(self._items)} items into specification table")

    @Slot(int, result='QVariantMap')
    def getItem(self, row):
        """Get item data at specified row"""
        if 0 <= row < len(self._items):
            return self._items[row].copy()
        return {}

    def _emitTotalCostChanged(self):
        """Emit signal when total cost changes"""
        total = self.getTotalMaterialsCost()
        self.totalCostChanged.emit(total)