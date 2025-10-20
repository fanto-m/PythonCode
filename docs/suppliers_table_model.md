# File: `suppliers_table_model.py`

### Imports
PySide6.QtCore, database

## Class `SuppliersTableModel`
### Method `__init__(self, parent = None)`
_No docstring._

### Method `load(self)`
Load all suppliers for management mode

### Method `loadForArticle(self, article)`
Load suppliers with pre-checked ones for binding mode

### Method `roleNames(self)`
_No docstring._

### Method `columnCount(self, parent = None)`
_No docstring._

### Method `rowCount(self, parent = None)`
_No docstring._

### Method `headerData(self, section, orientation, role = Qt.DisplayRole)`
_No docstring._

### Method `data(self, index, role = Qt.DisplayRole)`
_No docstring._

### Method `setData(self, index, value, role = Qt.EditRole)`
_No docstring._

### Method `flags(self, index)`
_No docstring._

### Method `getSelectedSupplierIds(self)`
_No docstring._

### Method `bindSuppliersToItem(self, article, supplier_ids)`
_No docstring._

### Method `getSupplierRow(self, row)`
_No docstring._

### Method `addSupplier(self, name, company, email, phone, website)`
Add a new supplier

### Method `updateSupplier(self, supplier_id, name, company, email, phone, website)`
Update an existing supplier

### Method `deleteSupplier(self, supplier_id)`
Delete a supplier
