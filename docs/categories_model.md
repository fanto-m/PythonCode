# File: `categories_model.py`

### Imports
PySide6.QtCore, database

## Class `CategoriesModel`
### Method `__init__(self, parent = None)`
_No docstring._

### Method `roleNames(self)`
_No docstring._

### Method `rowCount(self, parent = QModelIndex())`
_No docstring._

### Method `data(self, index, role = Qt.DisplayRole)`
_No docstring._

### Method `loadCategories(self)`
_No docstring._

### Method `addCategory(self, name, sku_prefix, sku_digits)`
_No docstring._

### Method `updateCategory(self, category_id, new_name, sku_prefix, sku_digits)`
_No docstring._

### Method `deleteCategory(self, category_id)`
_No docstring._

### Method `get(self, idx)`
Возвращает объект {id, name, sku_prefix, sku_digits} для QML

### Method `indexOfName(self, name)`
Ищет индекс категории по её названию, возвращает -1 если не найдено.

### Method `getCategoryIdByName(self, name)`
Возвращает id категории по имени, или -1 если не найдена.

### Method `generateSkuForCategory(self, category_id)`
Генерирует следующий SKU для категории
