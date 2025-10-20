# File: `specification_items_table_model.py`

### Imports
PySide6.QtCore

## Class `SpecificationItemsTableModel`
Table model for specification items with columns:
Image | Article | Name | Category | Quantity | Unit | Price | Total | Delete

### Method `__init__(self)`
_No docstring._

### Method `rowCount(self, parent = QModelIndex())`
Return number of rows

### Method `columnCount(self, parent = QModelIndex())`
Return number of columns

### Method `data(self, index, role = Qt.DisplayRole)`
Return data for given index and role

### Method `setData(self, index, value, role = Qt.EditRole)`
Set data for given index

### Method `flags(self, index)`
Return item flags

### Method `headerData(self, section, orientation, role = Qt.DisplayRole)`
Return header data

### Method `roleNames(self)`
Define role names for QML access

### Method `addItem(self, article, name, quantity, unit, price, image_path = '', category = '', status = '')`
Add new item to specification.
If article already exists, increase quantity and update the item.
Returns True if item was added, False if quantity was updated.

### Method `removeItem(self, row)`
Remove item at specified row

### Method `updateQuantity(self, row, new_quantity)`
Update quantity for item at specified row

### Method `getTotalMaterialsCost(self)`
Calculate total cost of all materials

### Method `clear(self)`
Clear all items

### Method `getAllItems(self)`
Get all items as list of dictionaries

### Method `getItems(self)`
Alias for getAllItems - for compatibility

### Method `count(self)`
Get number of items

### Method `itemCount(self)`
Alias for count - for compatibility

### Method `debugPrintItems(self)`
Debug method to print all items

### Method `loadItems(self, items)`
Load items from list of dictionaries

### Method `getItem(self, row)`
Get item data at specified row

### Method `_emitTotalCostChanged(self)`
Emit signal when total cost changes
