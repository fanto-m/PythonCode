# items_model.py - Fixed version with all issues resolved
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal, Property
from database import DatabaseManager
from validators import validate_item


class ItemsModel(QAbstractListModel):
    ArticleRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    DescriptionRole = Qt.UserRole + 3
    ImagePathRole = Qt.UserRole + 4
    CategoryRole = Qt.UserRole + 5
    PriceRole = Qt.UserRole + 6
    StockRole = Qt.UserRole + 7
    CreatedDateRole = Qt.UserRole + 8
    StatusRole = Qt.UserRole + 9
    UnitRole = Qt.UserRole + 10
    ManufacturerRole = Qt.UserRole + 11
    DocumentCodeRole = Qt.UserRole + 12

    errorOccurred = Signal(str)

    _ROLE_TO_INDEX = {
        ArticleRole: 0,
        NameRole: 1,
        DescriptionRole: 2,
        ImagePathRole: 3,
        CategoryRole: 4,
        PriceRole: 5,
        StockRole: 6,
        CreatedDateRole: 7,
        StatusRole: 8,
        UnitRole: 9,
        ManufacturerRole: 10,
        DocumentCodeRole: 11,
    }

    def __init__(self, db_path="items.db"):
        super().__init__()
        self.db_manager = DatabaseManager(db_path)
        self.items = []
        self._all_items = []  # Store all items for filtering
        self._filter_string = ""
        self._filter_field = "name"
        self.loadData()
        print("DEBUG: Model initialized and data loaded.")

    def loadData(self):
        """Load all data from database"""
        print("DEBUG: Loading data via DatabaseManager")
        self._all_items = self.db_manager.load_data()
        self._applyFilter()
        print(f"DEBUG: Data loaded. Total items: {len(self._all_items)}, Filtered: {len(self.items)}")

    def _applyFilter(self):
        """Apply current filter to items"""
        if not self._filter_string:
            self.items = self._all_items.copy()
            return

        filter_lower = self._filter_string.lower()

        # Map filter field to column index
        field_map = {
            "article": 0,
            "name": 1,
            "description": 2,
            "category": 4,
            "price": 5,
            "stock": 6
        }

        field_index = field_map.get(self._filter_field, 1)  # Default to name

        self.items = [
            item for item in self._all_items
            if filter_lower in str(item[field_index]).lower()
        ]

    def rowCount(self, parent=QModelIndex()):
        return len(self.items)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self.items):
            return None

        if role not in self._ROLE_TO_INDEX:
            return None

        item = self.items[index.row()]
        value = item[self._ROLE_TO_INDEX[role]]

        # Special handling for DocumentCodeRole - return empty string for None
        if role == self.DocumentCodeRole:
            return value if value is not None else ""

        return value

    def roleNames(self):
        return {
            self.ArticleRole: b"article",
            self.NameRole: b"name",
            self.DescriptionRole: b"description",
            self.ImagePathRole: b"image_path",
            self.CategoryRole: b"category",
            self.PriceRole: b"price",
            self.StockRole: b"stock",
            self.CreatedDateRole: b"created_date",
            self.StatusRole: b"status",
            self.UnitRole: b"unit",
            self.ManufacturerRole: b"manufacturer",
            self.DocumentCodeRole: b"document"
        }

    @Slot(str, str, str, str, int, float, int, str, str, str, str, result=str)
    def addItem(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer,
                document):
        try:
            print(f"DEBUG: addItem called with: article={article}, name={name}, description={description}, "
                  f"image_path={image_path}, category_id={category_id}, price={price}, stock={stock}, "
                  f"status={status}, unit={unit}, manufacturer={manufacturer}, document={document}")

            # Validate input
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )
            print(f"DEBUG: Validation result: is_valid={is_valid}, error_message={error_message}")
            if not is_valid:
                self.errorOccurred.emit(error_message)
                return error_message

            # Add to database - БЕЗ добавления папок!
            self.db_manager.add_item(
                article, name, description, image_path,
                category_id, price, stock, status, unit, manufacturer, document
            )

            print("DEBUG: Item added successfully. Reloading data...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print(f"DEBUG: Model reset complete. Total items after load: {len(self.items)}")

            return ""

        except Exception as e:
            error_message = f"Ошибка добавления товара: {str(e)}"
            print(f"DEBUG: Error in addItem: {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str, result=str)
    def updateItem(self, row, article, name, description, image_path,
                   category_id, price, stock, status, unit, manufacturer, document):
        """
        Update existing item in database

        Args:
            row: Row index in filtered list
            article: New article/SKU code
            name: New item name
            description: New description
            image_path: New image path
            category_id: New category ID (integer)
            price: New price
            stock: New stock quantity
            status: Item status
            unit: Unit of measurement
            manufacturer: Manufacturer name
            document: Document path

        Returns:
            Empty string on success, error message on failure
        """
        try:
            # Validate row index
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                print(f"DEBUG: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Validate input
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )
            if not is_valid:
                print(f"DEBUG: Validation failed in updateItem: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Get old article for updating
            old_article = self.items[row][0]

            # Update in database
            self.db_manager.update_item(
                old_article, article, name, description, image_path,
                category_id, price, stock, status, unit, manufacturer, document
            )

            print("DEBUG: Item updated successfully. Reloading data...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")

            return ""

        except Exception as e:
            error_message = f"Ошибка обновления товара: {str(e)}"
            print(f"DEBUG: Error in updateItem: {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int)
    def deleteItem(self, row):
        """
        Delete item from database

        Args:
            row: Row index in filtered list
        """
        try:
            # Validate row index
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                print(f"DEBUG: {error_message}")
                self.errorOccurred.emit(error_message)
                return

            article = self.items[row][0]
            print(f"DEBUG: Deleting item: article = {article}")

            self.db_manager.delete_item(article)

            print("DEBUG: Item deleted successfully. Reloading data...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")

        except Exception as e:
            error_message = f"Ошибка удаления товара: {str(e)}"
            print(f"DEBUG: Error in deleteItem: {error_message}")
            self.errorOccurred.emit(error_message)

    @Slot(str)
    def setFilterString(self, filter_string):
        """
        Set filter string for searching items

        Args:
            filter_string: String to filter by
        """
        if self._filter_string != filter_string:
            self._filter_string = filter_string
            print(f"DEBUG: Filter string set to: '{filter_string}'")
            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot(str)
    def setFilterField(self, field):
        """
        Set field to filter by

        Args:
            field: Field name (article, name, description, category, price, stock)
        """
        if self._filter_field != field:
            self._filter_field = field
            print(f"DEBUG: Filter field set to: '{field}'")
            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot()
    def clearFilter(self):
        """Clear all filters"""
        self._filter_string = ""
        self._filter_field = "name"
        print("DEBUG: Filters cleared")
        self.beginResetModel()
        self._applyFilter()
        self.endResetModel()

    @Slot(int, result='QVariantMap')
    def get(self, row):
        """
        Get item data at specific row

        Args:
            row: Row index

        Returns:
            Dictionary with item data or empty dict if invalid index
        """
        if row < 0 or row >= len(self.items):
            return {}

        item = self.items[row]
        return {
            "index": row,
            "article": item[0],
            "name": item[1],
            "description": item[2],
            "image_path": item[3],
            "category": item[4],
            "price": item[5],
            "stock": item[6],
            "created_date": item[7],
            "status": item[8] if len(item) > 8 else "в наличии",
            "unit": item[9] if len(item) > 9 else "шт.",
            "manufacturer": item[10] if len(item) > 10 else "",
            "document": item[11] if len(item) > 11 else ""
        }