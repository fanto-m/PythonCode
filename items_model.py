#items_model.py
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal
from database import DatabaseManager
from validators import validate_item

# Определяем класс ItemsModel
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

    errorOccurred = Signal(str)  # Сигнал для передачи ошибок в QML

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
        self.loadData()
        print("DEBUG: Model initialized and data loaded.")

    def loadData(self):
        print("DEBUG: Loading data via DatabaseManager")
        self.items = self.db_manager.load_data()
        print(f"DEBUG: Data loaded into model. Number of items: {len(self.items)}")

    def rowCount(self, parent=QModelIndex()):
        count = len(self.items)
        #print(f"DEBUG: rowCount called, returning: {count}")
        return count

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        if role not in self._ROLE_TO_INDEX:
            return None
        item = self.items[index.row()]
        value = item[self._ROLE_TO_INDEX[role]]

        # Специальная обработка для DocumentCodeRole
        if role == self.DocumentCodeRole:
            return value if value is not None else ""

        return value

    def roleNames(self):
        roles = {
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
        print(f"DEBUG: roleNames called, returning: {roles}")
        return roles

    @Slot(str, str, str, str, str, float, int, result=str)
    def addItem(self, article, name, description, image_path, category, price, stock, document):
        print(f"DEBUG: addItem called with: article={article}, name={name}, description={description}, image_path={image_path}, category={category}, price={price}, stock={stock}, document={document}")
        try:
            is_valid, error_message = validate_item(article, name, description, image_path, category, price, stock)
            if not is_valid:
                print(f"DEBUG: Validation failed in addItem: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message
            self.db_manager.add_item(article, name, description, image_path, category, price, stock, document)
            print("DEBUG: Item added via DatabaseManager. Resetting model...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")
            return ""
        except Exception as e:
            error_message = str(e)
            print(f"DEBUG: Error in addItem: {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str)
    def updateItem(self, row, article, name, description, image_path, category, price, stock, status, unit, manufacturer, document):
        print(f"DEBUG: updateItem called with: row={row}, article={article}, name={name}, description={description}, image_path={image_path}, category={category}, price={price}, stock={stock}, status={status}, unit={unit}, manufacturer={manufacturer}, document={document}")
        try:
            is_valid, error_message = validate_item(article, name, description, image_path, category, price, stock)
            if not is_valid:
                print(f"DEBUG: Validation failed in updateItem: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message
            old_article = self.items[row][0]
            self.db_manager.update_item(old_article, article, name, description, image_path, category, price, stock, status, unit, manufacturer, document),
            print("DEBUG: Item updated via DatabaseManager. Resetting model...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")
            return ""
        except Exception as e:
            error_message = str(e)
            print(f"DEBUG: Error in updateItem: {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int)
    def deleteItem(self, row):
        print(f"DEBUG: Deleting item at row: {row}")
        try:
            article = self.items[row][0]
            print(f"DEBUG: Item to delete: article = {article}")
            self.db_manager.delete_item(article)
            print("DEBUG: Item deleted via DatabaseManager. Resetting model...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")
        except Exception as e:
            error_message = str(e)
            print(f"DEBUG: Error in deleteItem: {error_message}")
            self.errorOccurred.emit(error_message)
            raise