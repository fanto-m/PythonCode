# Module: specification_models.py

> Path: `PythonCod-master/models/specification_models.py`

## 📦 Imports
```python
PySide6.QtCore.QObject
PySide6.QtCore.Signal
PySide6.QtCore.Slot
PySide6.QtCore.QAbstractListModel
PySide6.QtCore.Qt
PySide6.QtCore.QModelIndex
typing.Optional
typing.List
PySide6.QtGui.QColor
```

## 🧩 Classes

### class SpecificationItemsModel

Модель для позиций спецификации (материалов)

```python
def __init__(self, db_manager, parent)
```
No description.

```python
def roleNames(self)
```
No description.

```python
def rowCount(self, parent)
```
No description.

```python
def data(self, index, role)
```
No description.

```python
def setData(self, index, value, role)
```
No description.

```python
def addItem(self, article, name, quantity, unit, price, image_path, category, status)
```
Добавляет материал в список. Если артикул уже есть — увеличивает количество.

```python
def removeItem(self, index)
```
Удаляет материал из списка

```python
def clear(self)
```
Очищает все позиции

```python
def loadForSpecification(self, spec_id)
```
Загружает позиции для спецификации из БД

```python
def getTotalMaterialsCost(self)
```
Возвращает общую стоимость материалов

```python
def getItems(self)
```
Возвращает список всех позиций для сохранения

```python
def debugPrintItems(self)
```
Выводит все элементы модели для отладки

### class SpecificationsModel

Модель для управления спецификациями

```python
def __init__(self, db_manager, items_model, parent)
```
No description.

```python
def saveSpecification(self, spec_id, name, description, status, labor_cost, overhead_percentage)
```
Сохраняет спецификацию с позициями
Возвращает ID спецификации или -1 при ошибке

```python
def loadSpecification(self, spec_id)
```
Загружает спецификацию для редактирования

```python
def deleteSpecification(self, spec_id)
```
Удаляет спецификацию

```python
def loadAllSpecifications(self)
```
Загружает все спецификации для отображения в списке

```python
def loadSpecificationItems(self, spec_id)
```
Загружает позиции спецификации для отображения

```python
def exportToExcel(self, spec_id)
```
Экспорт спецификации в Excel

```python
def exportToPDF(self, spec_id)
```
Экспорт спецификации в PDF

## 📝 Notes
This module was auto-documented.
