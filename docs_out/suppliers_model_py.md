# Module `suppliers_model.py`


## Class `SuppliersModel`


### `SuppliersModel.__init__(self, parent)`


_No docstring._


### `SuppliersModel.roleNames(self)`


_No docstring._


### `SuppliersModel.rowCount(self, parent)`


_No docstring._


### `SuppliersModel.data(self, index, role)`


_No docstring._


### `SuppliersModel.loadSuppliers(self)`


Загружает всех поставщиков из БД.


### `SuppliersModel.addSupplier(self, name, company, email, phone, website)`


Добавляет нового поставщика.


### `SuppliersModel.updateSupplier(self, supplier_id, name, company, email, phone, website)`


Обновляет данные поставщика.


### `SuppliersModel.deleteSupplier(self, supplier_id)`


Удаляет поставщика.


### `SuppliersModel.get(self, idx)`


Возвращает объект поставщика по индексу.


### `SuppliersModel.getSupplierIdByName(self, name)`


Возвращает ID поставщика по имени (name).


### `SuppliersModel.getSupplierIdByCompany(self, company)`


Возвращает ID поставщика по названию компании.


### `SuppliersModel.bindSuppliersToItem(self, article, supplier_ids)`


Привязать поставщиков к товару.

