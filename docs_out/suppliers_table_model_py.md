# Module `suppliers_table_model.py`


## Class `SuppliersTableModel`


### `SuppliersTableModel.__init__(self, parent)`


_No docstring._


### `SuppliersTableModel.load(self)`


Load all suppliers for management mode


### `SuppliersTableModel.loadForArticle(self, article)`


Load suppliers with pre-checked ones for binding mode


### `SuppliersTableModel.roleNames(self)`


_No docstring._


### `SuppliersTableModel.columnCount(self, parent)`


_No docstring._


### `SuppliersTableModel.rowCount(self, parent)`


_No docstring._


### `SuppliersTableModel.headerData(self, section, orientation, role)`


_No docstring._


### `SuppliersTableModel.data(self, index, role)`


_No docstring._


### `SuppliersTableModel.setData(self, index, value, role)`


_No docstring._


### `SuppliersTableModel.flags(self, index)`


_No docstring._


### `SuppliersTableModel.getSelectedSupplierIds(self)`


_No docstring._


### `SuppliersTableModel.bindSuppliersToItem(self, article, supplier_ids)`


_No docstring._


### `SuppliersTableModel.getSupplierRow(self, row)`


_No docstring._


### `SuppliersTableModel.addSupplier(self, name, company, email, phone, website)`


Add a new supplier


### `SuppliersTableModel.updateSupplier(self, supplier_id, name, company, email, phone, website)`


Update an existing supplier


### `SuppliersTableModel.deleteSupplier(self, supplier_id)`


Delete a supplier

