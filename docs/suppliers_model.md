# File: `suppliers_model.py`

### Imports
PySide6.QtCore, database

## Class `SuppliersModel`
### Method `__init__(self, parent = None)`
_No docstring._

### Method `roleNames(self)`
_No docstring._

### Method `rowCount(self, parent = None)`
_No docstring._

### Method `data(self, index, role = Qt.DisplayRole)`
_No docstring._

### Method `loadSuppliers(self)`
Загружает всех поставщиков из БД.

### Method `addSupplier(self, name, company, email, phone, website)`
Добавляет нового поставщика.

### Method `updateSupplier(self, supplier_id, name, company, email, phone, website)`
Обновляет данные поставщика.

### Method `deleteSupplier(self, supplier_id)`
Удаляет поставщика.

### Method `get(self, idx)`
Возвращает объект поставщика по индексу.

### Method `getSupplierIdByName(self, name)`
Возвращает ID поставщика по имени (name).

### Method `getSupplierIdByCompany(self, company)`
Возвращает ID поставщика по названию компании.

### Method `bindSuppliersToItem(self, article, supplier_ids)`
Привязать поставщиков к товару.
