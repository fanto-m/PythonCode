# File: `database.py`

### Imports
datetime, os, sqlite3

## Class `DatabaseManager`
### Method `__init__(self, db_path = 'items.db')`
_No docstring._

### Method `_init_database(self)`
Инициализирует базу данных, создавая таблицы с правильной структурой.

### Method `load_categories(self)`
Загружает все категории

### Method `add_category(self, name, sku_prefix = 'ITEM', sku_digits = 4)`
Добавляет новую категорию с шаблоном SKU

### Method `generate_next_sku(self, category_id)`
Генерирует следующий артикул для категории

### Method `update_category(self, category_id, new_name, sku_prefix, sku_digits)`
Обновляет категорию с префиксом и количеством цифр

### Method `delete_category(self, category_id)`
Удаляет категорию по id

### Method `load_suppliers(self)`
_No docstring._

### Method `add_supplier(self, name, company, email = None, phone = None, website = None)`
_No docstring._

### Method `update_supplier(self, supplier_id, name, company, email = None, phone = None, website = None)`
_No docstring._

### Method `delete_supplier(self, supplier_id)`
_No docstring._

### Method `get_suppliers_for_item(self, article)`
Получить поставщиков для товара.
:param article:
:return:

### Method `set_suppliers_for_item(self, article, supplier_ids)`
Установить поставщиков для товара (полная замена).

### Method `load_data(self)`
Загружает все записи из таблицы items.

### Method `add_item(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`
_No docstring._

### Method `update_item(self, old_article, article, name, description, image_path, category_id, price, stock, status = 'в наличии', unit = 'шт.', manufacturer = None, document = None)`
Обновляет запись в таблице items по старому артикулу.

### Method `delete_item(self, article)`
Удаляет запись из таблицы items по артикулу.

### Method `load_specifications(self)`
Загружает все спецификации

### Method `get_specification(self, spec_id)`
Получает одну спецификацию по ID

### Method `add_specification(self, name, description, status = 'черновик', labor_cost = 0.0, overhead_percentage = 0.0)`
Создает новую спецификацию

### Method `update_specification(self, spec_id, name, description, status, labor_cost, overhead_percentage, final_price = 0.0)`
Обновляет спецификацию

### Method `delete_specification(self, spec_id)`
Удаляет спецификацию (каскадно удаляются и позиции)

### Method `load_specification_items(self, spec_id)`
Загружает все позиции спецификации с данными о товарах

### Method `add_specification_item(self, spec_id, article, quantity, notes = None)`
Добавляет позицию в спецификацию

### Method `update_specification_item(self, item_id, quantity, notes = None)`
Обновляет позицию спецификации

### Method `delete_specification_item(self, item_id)`
Удаляет позицию из спецификации

### Method `clear_specification_items(self, spec_id)`
Удаляет все позиции спецификации

### Method `save_specification_with_items(self, spec_id, name, description, status, labor_cost, overhead_percentage, items)`
Сохраняет спецификацию вместе со всеми позициями (транзакционно)

:param spec_id: ID спецификации (None для новой)
:param name: Название
:param description: Описание
:param status: Статус
:param labor_cost: Стоимость работы
:param overhead_percentage: Процент накладных
:param items: Список словарей [{article, quantity, notes}, ...]
:return: ID спецификации или None при ошибке
