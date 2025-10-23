# Module `database.py`


## Class `DatabaseManager`


### `DatabaseManager.__init__(self, db_path)`


_No docstring._


### `DatabaseManager._init_database(self)`


Инициализирует базу данных, создавая таблицы с правильной структурой.


### `DatabaseManager.load_categories(self)`


Загружает все категории


### `DatabaseManager.add_category(self, name, sku_prefix, sku_digits)`


Добавляет новую категорию с шаблоном SKU


### `DatabaseManager.generate_next_sku(self, category_id)`


Генерирует следующий артикул для категории


### `DatabaseManager.update_category(self, category_id, new_name, sku_prefix, sku_digits)`


Обновляет категорию с префиксом и количеством цифр


### `DatabaseManager.delete_category(self, category_id)`


Удаляет категорию по id


### `DatabaseManager.load_suppliers(self)`


_No docstring._


### `DatabaseManager.add_supplier(self, name, company, email, phone, website)`


_No docstring._


### `DatabaseManager.update_supplier(self, supplier_id, name, company, email, phone, website)`


_No docstring._


### `DatabaseManager.delete_supplier(self, supplier_id)`


_No docstring._


### `DatabaseManager.get_suppliers_for_item(self, article)`


Получить поставщиков для товара.
:param article:
:return:


### `DatabaseManager.set_suppliers_for_item(self, article, supplier_ids)`


Установить поставщиков для товара (полная замена).


### `DatabaseManager.load_data(self)`


Загружает все записи из таблицы items.


### `DatabaseManager.add_item(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`


_No docstring._


### `DatabaseManager.update_item(self, old_article, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document)`


Обновляет запись в таблице items по старому артикулу.


### `DatabaseManager.delete_item(self, article)`


Удаляет запись из таблицы items по артикулу.


### `DatabaseManager.load_specifications(self)`


Загружает все спецификации


### `DatabaseManager.get_specification(self, spec_id)`


Получает одну спецификацию по ID


### `DatabaseManager.add_specification(self, name, description, status, labor_cost, overhead_percentage)`


Создает новую спецификацию


### `DatabaseManager.update_specification(self, spec_id, name, description, status, labor_cost, overhead_percentage, final_price)`


Обновляет спецификацию


### `DatabaseManager.delete_specification(self, spec_id)`


Удаляет спецификацию (каскадно удаляются и позиции)


### `DatabaseManager.load_specification_items(self, spec_id)`


Загружает все позиции спецификации с данными о товарах


### `DatabaseManager.add_specification_item(self, spec_id, article, quantity, notes)`


Добавляет позицию в спецификацию


### `DatabaseManager.update_specification_item(self, item_id, quantity, notes)`


Обновляет позицию спецификации


### `DatabaseManager.delete_specification_item(self, item_id)`


Удаляет позицию из спецификации


### `DatabaseManager.clear_specification_items(self, spec_id)`


Удаляет все позиции спецификации


### `DatabaseManager.save_specification_with_items(self, spec_id, name, description, status, labor_cost, overhead_percentage, items)`


Сохраняет спецификацию вместе со всеми позициями (транзакционно)

:param spec_id: ID спецификации (None для новой)
:param name: Название
:param description: Описание
:param status: Статус
:param labor_cost: Стоимость работы
:param overhead_percentage: Процент накладных
:param items: Список словарей [{article, quantity, notes}, ...]
:return: ID спецификации или None при ошибке

