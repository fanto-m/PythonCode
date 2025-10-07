# categories_model.py
from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex, Slot, Signal
from database import DatabaseManager

class CategoriesModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    PrefixRole = Qt.UserRole + 3
    DigitsRole = Qt.UserRole + 4

    errorOccurred = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._db = DatabaseManager()
        self._categories = []
        self.loadCategories()

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.PrefixRole: b"sku_prefix",
            self.DigitsRole: b"sku_digits"
        }

    def rowCount(self, parent=QModelIndex()):
        return len(self._categories)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._categories)):
            return None
        category = self._categories[index.row()]
        if role == self.IdRole:
            return category[0]
        elif role == self.NameRole:
            return category[1]
        elif role == self.PrefixRole:
            return category[2]
        elif role == self.DigitsRole:
            return category[3]
        return None

    def loadCategories(self):
        self.beginResetModel()
        # теперь возвращаем (id, name, prefix, digits)
        self._categories = self._db.load_categories()
        self.endResetModel()
        print("DEBUG: CategoriesModel loaded")

    @Slot(str, str, int)
    def addCategory(self, name, sku_prefix, sku_digits):
        try:
            self._db.add_category(name, sku_prefix, sku_digits)
            self.loadCategories()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(int, str, str, int)
    def updateCategory(self, category_id, new_name, sku_prefix, sku_digits):
        try:
            self._db.update_category(category_id, new_name, sku_prefix, sku_digits)
            self.loadCategories()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(int)
    def deleteCategory(self, category_id):
        try:
            self._db.delete_category(category_id)
            self.loadCategories()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(int, result="QVariant")
    def get(self, idx):
        """Возвращает объект {id, name, sku_prefix, sku_digits} для QML"""
        if 0 <= idx < len(self._categories):
            cid, name, prefix, digits = self._categories[idx]
            return {
                'id': cid,
                'name': name,
                'sku_prefix': prefix,
                'sku_digits': digits
            }
        return {'id': -1, 'name': '', 'sku_prefix': '', 'sku_digits': 4}

    @Slot(str, result=int)
    def indexOfName(self, name):
        """Ищет индекс категории по её названию, возвращает -1 если не найдено."""
        for i, c in enumerate(self._categories):
            if c[1] == name:
                return i
        return -1

    @Slot(str, result=int)
    def getCategoryIdByName(self, name):
        """Возвращает id категории по имени, или -1 если не найдена."""
        for category in self._categories:
            if category[1] == name:
                return category[0]
        return -1

    @Slot(int, result=str)
    def generateSkuForCategory(self, category_id):
        """Генерирует следующий SKU для категории"""
        return self._db.generate_next_sku(category_id) or ""
