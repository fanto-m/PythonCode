# File: `models/specification_models.py`

### Module Docstring
Specifications Models for Manufacturing BOM (Bill of Materials)
models/specification_models.py

### Imports
PySide6.QtCore, PySide6.QtGui, typing

## Class `SpecificationItemsModel`
Модель для позиций спецификации (материалов)

### Method `__init__(self, db_manager, parent = None)`
_No docstring._

### Method `roleNames(self)`
_No docstring._

### Method `rowCount(self, parent = QModelIndex())`
_No docstring._

### Method `data(self, index, role = Qt.ItemDataRole.DisplayRole)`
_No docstring._

### Method `setData(self, index, value, role = Qt.ItemDataRole.EditRole)`
_No docstring._

### Method `addItem(self, article, name, quantity, unit, price, image_path, category, status)`
Добавляет материал в список. Если артикул уже есть — увеличивает количество.

### Method `removeItem(self, index)`
Удаляет материал из списка

### Method `clear(self)`
Очищает все позиции

### Method `loadForSpecification(self, spec_id)`
Загружает позиции для спецификации из БД

### Method `getTotalMaterialsCost(self)`
Возвращает общую стоимость материалов

### Method `getItems(self)`
Возвращает список всех позиций для сохранения

### Method `debugPrintItems(self)`
Выводит все элементы модели для отладки

## Class `SpecificationsModel`
Модель для управления спецификациями

### Method `__init__(self, db_manager, items_model, parent = None)`
_No docstring._

### Method `saveSpecification(self, spec_id, name, description, status, labor_cost, overhead_percentage)`
Сохраняет спецификацию с позициями
Возвращает ID спецификации или -1 при ошибке

### Method `loadSpecification(self, spec_id)`
Загружает спецификацию для редактирования

### Method `deleteSpecification(self, spec_id)`
Удаляет спецификацию

### Method `loadAllSpecifications(self)`
Загружает все спецификации для отображения в списке

### Method `loadSpecificationItems(self, spec_id)`
Загружает позиции спецификации для отображения

### Method `exportToExcel(self, spec_id)`
Экспорт спецификации в Excel

### Method `exportToPDF(self, spec_id)`
Экспорт спецификации в PDF
