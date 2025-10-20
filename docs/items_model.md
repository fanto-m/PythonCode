# File: `items_model.py`

### Imports
PySide6.QtCore (QAbstractListModel, Qt, QModelIndex, Slot, Signal, Property), database (DatabaseManager), validators (validate_item)

## Class `ItemsModel`
Модель для работы с данными товаров в интерфейсе Qt, основанная на QAbstractListModel. Поддерживает загрузку, фильтрацию, добавление, обновление и удаление товаров из базы данных.

### Method `__init__(self, db_path='items.db')`
Инициализирует экземпляр ItemsModel.

**Args:**
- `db_path` (str): Путь к файлу базы данных SQLite. По умолчанию 'items.db'.

### Method `loadData(self)`
Загружает все данные товаров из базы данных через DatabaseManager и применяет текущий фильтр.

### Method `_applyFilter(self)`
Применяет текущий фильтр к списку товаров на основе строки фильтра и выбранного поля.

### Method `rowCount(self, parent=QModelIndex())`
Возвращает количество строк в модели (количество отфильтрованных товаров).

**Args:**
- `parent` (QModelIndex): Родительский индекс модели. По умолчанию пустой QModelIndex.

**Returns:**
- `int`: Количество товаров в отфильтрованном списке.

### Method `data(self, index, role=Qt.DisplayRole)`
Получает данные для указанного индекса и роли.

**Args:**
- `index` (QModelIndex): Индекс элемента в модели.
- `role` (int): Роль данных (например, ArticleRole, NameRole и т.д.). По умолчанию Qt.DisplayRole.

**Returns:**
- Значение для указанной роли или None, если индекс или роль недопустимы.

### Method `roleNames(self)`
Возвращает словарь, сопоставляющий роли данных с их именами для использования в QML.

**Returns:**
- `dict`: Словарь с парами {роль: имя} для всех определённых ролей.

### Method `addItem(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`
Добавляет новый товар в базу данных.

**Args:**
- `article` (str): Артикул товара.
- `name` (str): Название товара.
- `description` (str): Описание товара.
- `image_path` (str): Путь к изображению товара.
- `category_id` (int): ID категории.
- `price` (float): Цена товара.
- `stock` (int): Количество на складе.
- `status` (str): Статус товара.
- `unit` (str): Единица измерения.
- `manufacturer` (str): Производитель.
- `document` (str): Связанный документ.

**Returns:**
- `str`: Пустая строка при успехе, сообщение об ошибке при неудаче.

**Raises:**
- `Exception`: Если произошла ошибка при добавлении товара.

### Method `updateItem(self, row, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`
Обновляет существующий товар в базе данных.

**Args:**
- `row` (int): Индекс строки в отфильтрованном списке.
- `article` (str): Новый артикул товара.
- `name` (str): Новое название товара.
- `description` (str): Новое описание товара.
- `image_path` (str): Новый путь к изображению.
- `category_id` (int): Новый ID категории.
- `price` (float): Новая цена.
- `stock` (int): Новое количество на складе.
- `status` (str): Новый статус.
- `unit` (str): Новая единица измерения.
- `manufacturer` (str): Новый производитель.
- `document` (str): Новый документ.

**Returns:**
- `str`: Пустая строка при успехе, сообщение об ошибке при неудаче.

**Raises:**
- `Exception`: Если произошла ошибка при обновлении товара.

### Method `deleteItem(self, row)`
Удаляет товар из базы данных по индексу строки.

**Args:**
- `row` (int): Индекс строки в отфильтрованном списке.

**Raises:**
- `Exception`: Если произошла ошибка при удалении товара.

### Method `setFilterString(self, filter_string)`
Устанавливает строку для фильтрации товаров.

**Args:**
- `filter_string` (str): Строка для фильтрации.

### Method `setFilterField(self, field)`
Устанавливает поле для фильтрации товаров.

**Args:**
- `field` (str): Поле для фильтрации (article, name, description, category, price, stock).

### Method `clearFilter(self)`
Сбрасывает все фильтры, возвращая модель к полному списку товаров.

### Method `get(self, row)`
Получает данные товара по индексу строки.

**Args:**
- `row` (int): Индекс строки в отфильтрованном списке.

**Returns:**
- `dict`: Словарь с данными товара (index, article, name, description, image_path, category, price, stock, created_date, status, unit, manufacturer, document) или пустой словарь, если индекс недопустим.