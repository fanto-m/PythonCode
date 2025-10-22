# Module `items_model.py`


## Class `ItemsModel`


### `ItemsModel.__init__(self, db_path)`


_No docstring._


### `ItemsModel.loadData(self)`


Load all data from database


### `ItemsModel._applyFilter(self)`


Apply current filter to items


### `ItemsModel.rowCount(self, parent)`


_No docstring._


### `ItemsModel.data(self, index, role)`


_No docstring._


### `ItemsModel.roleNames(self)`


_No docstring._


### `ItemsModel.addItem(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`


_No docstring._


### `ItemsModel.updateItem(self, row, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`


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


### `ItemsModel.deleteItem(self, row)`


Delete item from database

Args:
    row: Row index in filtered list


### `ItemsModel.setFilterString(self, filter_string)`


Set filter string for searching items

Args:
    filter_string: String to filter by


### `ItemsModel.setFilterField(self, field)`


Set field to filter by

Args:
    field: Field name (article, name, description, category, price, stock)


### `ItemsModel.clearFilter(self)`


Clear all filters


### `ItemsModel.get(self, row)`


Get item data at specific row

Args:
    row: Row index

Returns:
    Dictionary with item data or empty dict if invalid index

