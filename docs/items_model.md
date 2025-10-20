# File: `items_model.py`

### Imports
PySide6.QtCore, database, validators

## Class `ItemsModel`
### Method `__init__(self, db_path = 'items.db')`
_No docstring._

### Method `loadData(self)`
Load all data from database

### Method `_applyFilter(self)`
Apply current filter to items

### Method `rowCount(self, parent = QModelIndex())`
_No docstring._

### Method `data(self, index, role = Qt.DisplayRole)`
_No docstring._

### Method `roleNames(self)`
_No docstring._

### Method `addItem(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`
_No docstring._

### Method `updateItem(self, row, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`
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

### Method `deleteItem(self, row)`
Delete item from database

Args:
    row: Row index in filtered list

### Method `setFilterString(self, filter_string)`
Set filter string for searching items

Args:
    filter_string: String to filter by

### Method `setFilterField(self, field)`
Set field to filter by

Args:
    field: Field name (article, name, description, category, price, stock)

### Method `clearFilter(self)`
Clear all filters

### Method `get(self, row)`
Get item data at specific row

Args:
    row: Row index

Returns:
    Dictionary with item data or empty dict if invalid index
