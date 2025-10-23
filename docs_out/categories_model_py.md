# Module `categories_model.py`


## Class `CategoriesModel`


### `CategoriesModel.__init__(self, parent)`


_No docstring._


### `CategoriesModel.roleNames(self)`


_No docstring._


### `CategoriesModel.rowCount(self, parent)`


_No docstring._


### `CategoriesModel.data(self, index, role)`


_No docstring._


### `CategoriesModel.loadCategories(self)`


_No docstring._


### `CategoriesModel.addCategory(self, name, sku_prefix, sku_digits)`


_No docstring._


### `CategoriesModel.updateCategory(self, category_id, new_name, sku_prefix, sku_digits)`


_No docstring._


### `CategoriesModel.deleteCategory(self, category_id)`


_No docstring._


### `CategoriesModel.get(self, idx)`


Возвращает объект {id, name, sku_prefix, sku_digits} для QML


### `CategoriesModel.indexOfName(self, name)`


Ищет индекс категории по её названию, возвращает -1 если не найдено.


### `CategoriesModel.getCategoryIdByName(self, name)`


Возвращает id категории по имени, или -1 если не найдена.


### `CategoriesModel.generateSkuForCategory(self, category_id)`


Генерирует следующий SKU для категории

