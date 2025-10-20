# File: `database.py`

### Imports
datetime, os, sqlite3

## Class `DatabaseManager`

Класс для управления базой данных SQLite для хранения информации о товарах, категориях, поставщиках и спецификациях.

### Method `__init__(self, db_path='items.db')`

Инициализирует экземпляр DatabaseManager.

**Args:**
- `db_path` (str): Путь к файлу базы данных SQLite. По умолчанию 'items.db'.

### Method `_init_database(self)`

Инициализирует базу данных, создавая необходимые таблицы.

Создает таблицы items, suppliers, item_suppliers и categories с соответствующей структурой. Обрабатывает ошибки при создании таблиц и выводит отладочные сообщения.

### Method `load_categories(self)`

Загружает все категории из базы данных.

**Returns:**
- `list`: Список кортежей с данными категорий (id, name, sku_prefix, sku_digits). Пустой список в случае ошибки.

### Method `add_category(self, name, sku_prefix='ITEM', sku_digits=4)`

Добавляет новую категорию в базу данных.

**Args:**
- `name` (str): Название категории.
- `sku_prefix` (str): Префикс для артикулов товаров в категории. По умолчанию 'ITEM'.
- `sku_digits` (int): Количество цифр в артикуле. По умолчанию 4.

**Raises:**
- `Exception`: Если произошла ошибка при добавлении категории.

### Method `generate_next_sku(self, category_id)`

Генерирует следующий артикул для указанной категории.

**Args:**
- `category_id` (int): ID категории, для которой генерируется артикул.

**Returns:**
- `str`: Новый артикул в формате {prefix}-{number}, или None в случае ошибки.

### Method `update_category(self, category_id, new_name, sku_prefix, sku_digits)`

Обновляет информацию о категории.

**Args:**
- `category_id` (int): ID категории для обновления.
- `new_name` (str): Новое название категории.
- `sku_prefix` (str): Новый префикс артикула.
- `sku_digits` (int): Новое количество цифр в артикуле.

**Raises:**
- `Exception`: Если произошла ошибка при обновлении категории.

### Method `delete_category(self, category_id)`

Удаляет категорию из базы данных по ID.

**Args:**
- `category_id` (int): ID категории для удаления.

**Raises:**
- `Exception`: Если произошла ошибка при удалении категории.

### Method `load_suppliers(self)`

Загружает всех поставщиков из базы данных.

**Returns:**
- `list`: Список кортежей с данными поставщиков (id, name, company, email, phone, website). Пустой список в случае ошибки.

### Method `add_supplier(self, name, company, email=None, phone=None, website=None)`

Добавляет нового поставщика в базу данных.

**Args:**
- `name` (str): Имя контактного лица поставщика.
- `company` (str): Название компании.
- `email` (str, optional): Электронная почта поставщика.
- `phone` (str, optional): Телефон поставщика.
- `website` (str, optional): Веб-сайт поставщика.

**Returns:**
- `list`: Пустой список в случае ошибки (для обратной совместимости).

### Method `update_supplier(self, supplier_id, name, company, email=None, phone=None, website=None)`

Обновляет информацию о поставщике.

**Args:**
- `supplier_id` (int): ID поставщика для обновления.
- `name` (str): Новое имя контактного лица.
- `company` (str): Новое название компании.
- `email` (str, optional): Новая электронная почта.
- `phone` (str, optional): Новый телефон.
- `website` (str, optional): Новый веб-сайт.

**Raises:**
- `Exception`: Если произошла ошибка при обновлении поставщика.

### Method `delete_supplier(self, supplier_id)`

Удаляет поставщика из базы данных по ID.

**Args:**
- `supplier_id` (int): ID поставщика для удаления.

**Raises:**
- `Exception`: Если произошла ошибка при удалении поставщика.

### Method `get_suppliers_for_item(self, article)`

Получает список поставщиков для указанного товара.

**Args:**
- `article` (str): Артикул товара.

**Returns:**
- `list`: Список кортежей с данными поставщиков (id, name, company, email, phone, website). Пустой список, если артикул некорректен или произошла ошибка.

**Raises:**
- `FileNotFoundError`: Если файл базы данных не существует.

### Method `set_suppliers_for_item(self, article, supplier_ids)`

Устанавливает список поставщиков для товара, заменяя существующие связи.

**Args:**
- `article` (str): Артикул товара.
- `supplier_ids` (list): Список ID поставщиков. Может быть пустым.

**Returns:**
- `bool`: True, если операция успешна, False в случае ошибки или некорректных данных.

**Raises:**
- `FileNotFoundError`: Если файл базы данных не существует.

### Method `load_data(self)`

Загружает все записи из таблицы items с информацией о категориях.

**Returns:**
- `list`: Список кортежей с данными товаров (article, name, description, image_path, category_name, price, stock, created_date, status, unit, manufacturer, document). Пустой список в случае ошибки.

### Method `add_item(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`

Добавляет новый товар в таблицу items.

**Args:**
- `article` (str): Артикул товара.
- `name` (str): Название товара.
- `description` (str): Описание товара.
- `image_path` (str): Путь к изображению товара.
- `category_id` (int): ID категории.
- `price` (float): Цена товара.
- `stock` (int): Количество на складе.
- `status` (str): Статус товара (например, 'в наличии').
- `unit` (str): Единица измерения (например, 'шт.').
- `manufacturer` (str): Производитель.
- `document` (str): Связанный документ.

**Raises:**
- `Exception`: Если произошла ошибка при добавлении товара.

### Method `update_item(self, old_article, article, name, description, image_path, category_id, price, stock, status='в наличии', unit='шт.', manufacturer=None, document=None)`

Обновляет запись о товаре в таблице items.

**Args:**
- `old_article` (str): Текущий артикул товара.
- `article` (str): Новый артикул товара.
- `name` (str): Новое название товара.
- `description` (str): Новое описание товара.
- `image_path` (str): Новый путь к изображению.
- `category_id` (int): Новый ID категории.
- `price` (float): Новая цена.
- `stock` (int): Новое количество на складе.
- `status` (str): Новый статус (по умолчанию 'в наличии').
- `unit` (str): Новая единица измерения (по умолчанию 'шт.').
- `manufacturer` (str, optional): Новый производитель.
- `document` (str, optional): Новый документ.

**Raises:**
- `Exception`: Если произошла ошибка при обновлении товара.

### Method `delete_item(self, article)`

Удаляет товар из таблицы items по артикулу.

**Args:**
- `article` (str): Артикул товара для удаления.

**Raises:**
- `Exception`: Если произошла ошибка при удалении товара.

### Method `load_specifications(self)`

Загружает все спецификации из базы данных.

**Returns:**
- `list`: Список кортежей с данными спецификаций (id, name, description, created_date, modified_date, status, labor_cost, overhead_percentage, final_price). Пустой список в случае ошибки.

### Method `get_specification(self, spec_id)`

Получает спецификацию по её ID.

**Args:**
- `spec_id` (int): ID спецификации.

**Returns:**
- `tuple`: Кортеж с данными спецификации (id, name, description, created_date, modified_date, status, labor_cost, overhead_percentage, final_price). None в случае ошибки или если спецификация не найдена.

### Method `add_specification(self, name, description, status='черновик', labor_cost=0.0, overhead_percentage=0.0)`

Создаёт новую спецификацию в базе данных.

**Args:**
- `name` (str): Название спецификации.
- `description` (str): Описание спецификации.
- `status` (str): Статус спецификации (по умолчанию 'черновик').
- `labor_cost` (float): Стоимость работы (по умолчанию 0.0).
- `overhead_percentage` (float): Процент накладных расходов (по умолчанию 0.0).

**Returns:**
- `int`: ID новой спецификации или None в случае ошибки.

### Method `update_specification(self, spec_id, name, description, status, labor_cost, overhead_percentage, final_price=0.0)`

Обновляет существующую спецификацию.

**Args:**
- `spec_id` (int): ID спецификации для обновления.
- `name` (str): Новое название.
- `description` (str): Новое описание.
- `status` (str): Новый статус.
- `labor_cost` (float): Новая стоимость работы.
- `overhead_percentage` (float): Новый процент накладных.
- `final_price` (float): Итоговая цена (по умолчанию 0.0).

**Returns:**
- `bool`: True, если обновление успешно, False в случае ошибки.

### Method `delete_specification(self, spec_id)`

Удаляет спецификацию и связанные с ней позиции.

**Args:**
- `spec_id` (int): ID спецификации для удаления.

**Returns:**
- `bool`: True, если удаление успешно, False в случае ошибки.

### Method `load_specification_items(self, spec_id)`

Загружает все позиции спецификации с данными о товарах.

**Args:**
- `spec_id` (int): ID спецификации.

**Returns:**
- `list`: Список кортежей с данными позиций (id, specification_id, article, quantity, notes, name, unit, price, image_path, category, status). Пустой список в случае ошибки.

### Method `add_specification_item(self, spec_id, article, quantity, notes=None)`

Добавляет новую позицию в спецификацию.

**Args:**
- `spec_id` (int): ID спецификации.
- `article` (str): Артикул товара.
- `quantity` (int): Количество товара.
- `notes` (str, optional): Примечания к позиции.

**Returns:**
- `int`: ID новой позиции или None в случае ошибки.

### Method `update_specification_item(self, item_id, quantity, notes=None)`

Обновляет позицию в спецификации.

**Args:**
- `item_id` (int): ID позиции для обновления.
- `quantity` (int): Новое количество.
- `notes` (str, optional): Новые примечания.

**Returns:**
- `bool`: True, если обновление успешно, False в случае ошибки.

### Method `delete_specification_item(self, item_id)`

Удаляет позицию из спецификации.

**Args:**
- `item_id` (int): ID позиции для удаления.

**Returns:**
- `bool`: True, если удаление успешно, False в случае ошибки.

### Method `clear_specification_items(self, spec_id)`

Удаляет все позиции указанной спецификации.

**Args:**
- `spec_id` (int): ID спецификации.

**Returns:**
- `bool`: True, если удаление успешно, False в случае ошибки.

### Method `save_specification_with_items(self, spec_id, name, description, status, labor_cost, overhead_percentage, items)`

Сохраняет спецификацию и её позиции транзакционно.

**Args:**
- `spec_id` (int): ID спецификации (None для новой).
- `name` (str): Название спецификации.
- `description` (str): Описание спецификации.
- `status` (str): Статус спецификации.
- `labor_cost` (float): Стоимость работы.
- `overhead_percentage` (float): Процент накладных расходов.
- `items` (list): Список словарей с данными позиций [{article, quantity, notes}, ...].

**Returns:**
- `int`: ID спецификации или None в случае ошибки.