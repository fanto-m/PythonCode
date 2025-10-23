# Module `specification_items_table_model.py`


## Class `SpecificationItemsTableModel`


Table model for specification items with columns:
Image | Article | Name | Category | Quantity | Unit | Price | Total | Delete


### `SpecificationItemsTableModel.__init__(self)`


_No docstring._


### `SpecificationItemsTableModel.rowCount(self, parent)`


Return number of rows


### `SpecificationItemsTableModel.columnCount(self, parent)`


Return number of columns


### `SpecificationItemsTableModel.data(self, index, role)`


Return data for given index and role


### `SpecificationItemsTableModel.setData(self, index, value, role)`


Set data for given index


### `SpecificationItemsTableModel.flags(self, index)`


Return item flags


### `SpecificationItemsTableModel.headerData(self, section, orientation, role)`


Return header data


### `SpecificationItemsTableModel.roleNames(self)`


Define role names for QML access


### `SpecificationItemsTableModel.addItem(self, article, name, quantity, unit, price, image_path, category, status)`


Add new item to specification.
If article already exists, increase quantity and update the item.
Returns True if item was added, False if quantity was updated.


### `SpecificationItemsTableModel.removeItem(self, row)`


Remove item at specified row


### `SpecificationItemsTableModel.updateQuantity(self, row, new_quantity)`


Update quantity for item at specified row


### `SpecificationItemsTableModel.getTotalMaterialsCost(self)`


Calculate total cost of all materials


### `SpecificationItemsTableModel.clear(self)`


Clear all items


### `SpecificationItemsTableModel.getAllItems(self)`


Get all items as list of dictionaries


### `SpecificationItemsTableModel.getItems(self)`


Alias for getAllItems - for compatibility


### `SpecificationItemsTableModel.count(self)`


Get number of items


### `SpecificationItemsTableModel.itemCount(self)`


Alias for count - for compatibility


### `SpecificationItemsTableModel.debugPrintItems(self)`


Debug method to print all items


### `SpecificationItemsTableModel.loadItems(self, items)`


Load items from list of dictionaries


### `SpecificationItemsTableModel.getItem(self, row)`


Get item data at specified row


### `SpecificationItemsTableModel._emitTotalCostChanged(self)`


Emit signal when total cost changes

