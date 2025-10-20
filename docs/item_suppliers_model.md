# File: `item_suppliers_model.py`

### Imports
PySide6.QtCore, database

## Class `ItemSuppliersModel`
### Method `__init__(self, article = '')`
_No docstring._

### Method `load(self)`
Load full supplier data for items bound to current article

### Method `roleNames(self)`
_No docstring._

### Method `rowCount(self, parent = None)`
_No docstring._

### Method `data(self, index, role = Qt.DisplayRole)`
_No docstring._

### Method `setArticle(self, article)`
Set article and reload suppliers for that article

### Method `get(self, index)`
Get supplier data at index as a dictionary
