# Module: main.py

> Path: `PythonCod-master/main.py`

## 📦 Imports
```python
sys
os
json
database.DatabaseManager
PySide6.QtCore.QObject
PySide6.QtCore.Slot
PySide6.QtCore.QDir
PySide6.QtGui.QGuiApplication
PySide6.QtQml.QQmlApplicationEngine
PySide6.QtQml.QQmlError
PySide6.QtQml.qmlRegisterType
items_model.ItemsModel
filter_proxy_model.FilterProxyModel
categories_model.CategoriesModel
suppliers_model.SuppliersModel
item_suppliers_model.ItemSuppliersModel
suppliers_table_model.SuppliersTableModel
models.specification_models.SpecificationItemsModel
models.specification_models.SpecificationsModel
specification_items_table_model.SpecificationItemsTableModel
config_manager.ConfigManager
```

## 🧩 Classes

### class Backend

Класс для взаимодействия с бэкендом приложения.

Предоставляет методы для работы с данными через менеджер базы данных.
Используется в QML для получения данных, например, списка поставщиков для товара.

```python
def __init__(self, db_manager, parent)
```
Инициализация объекта бэкенда.

Args:
    db_manager (DatabaseManager): Экземпляр менеджера базы данных.
    parent (QObject, optional): Родительский объект Qt. По умолчанию None.

```python
def getSuppliersForItem(self, article)
```
Получение списка поставщиков для указанного артикула товара.

Args:
    article (str): Артикул товара.

Returns:
    list: Список словарей с данными поставщиков (id, name, company, email, phone, website).

### class QMLConsoleHandler

Класс для обработки сообщений отладки из QML.

Перенаправляет сообщения, переданные через QML console.log, в стандартный вывод Python.

```python
def log(self, message)
```
Выводит отладочное сообщение из QML в консоль Python.

Args:
    message (str): Сообщение для вывода.

## 📝 Notes
This module was auto-documented.
