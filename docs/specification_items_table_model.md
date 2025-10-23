# Module: specification_items_table_model.py

> Path: `PythonCod-master/specification_items_table_model.py`

## 📦 Imports
```python
PySide6.QtCore.QAbstractTableModel
PySide6.QtCore.Qt
PySide6.QtCore.QModelIndex
PySide6.QtCore.Slot
PySide6.QtCore.Signal
```

## 🧩 Classes

### class SpecificationItemsTableModel

Table model for specification items with columns:
Image | Article | Name | Category | Quantity | Unit | Price | Total | Delete

```python
def __init__(self)
```
No description.

```python
def rowCount(self, parent)
```
Return number of rows

```python
def columnCount(self, parent)
```
Return number of columns

```python
def data(self, index, role)
```
Return data for given index and role

```python
def setData(self, index, value, role)
```
Set data for given index

```python
def flags(self, index)
```
Return item flags

```python
def headerData(self, section, orientation, role)
```
Return header data

```python
def roleNames(self)
```
Define role names for QML access

```python
def addItem(self, article, name, quantity, unit, price, image_path, category, status)
```
Add new item to specification.
If article already exists, increase quantity and update the item.
Returns True if item was added, False if quantity was updated.

```python
def removeItem(self, row)
```
Remove item at specified row

```python
def updateQuantity(self, row, new_quantity)
```
Update quantity for item at specified row

```python
def getTotalMaterialsCost(self)
```
Calculate total cost of all materials

```python
def clear(self)
```
Clear all items

```python
def getAllItems(self)
```
Get all items as list of dictionaries

```python
def getItems(self)
```
Alias for getAllItems - for compatibility

```python
def count(self)
```
Get number of items

```python
def itemCount(self)
```
Alias for count - for compatibility

```python
def debugPrintItems(self)
```
Debug method to print all items

```python
def loadItems(self, items)
```
Load items from list of dictionaries

```python
def getItem(self, row)
```
Get item data at specified row

```python
def _emitTotalCostChanged(self)
```
Emit signal when total cost changes

## 📝 Notes
This module was auto-documented.
