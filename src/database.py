import sqlite3
import os
from datetime import datetime


class DatabaseManager:
    """Класс для управления базой данных SQLite для хранения информации о товарах, категориях, поставщиках и спецификациях."""

    def __init__(self, db_path="items.db"):
        """Инициализирует экземпляр DatabaseManager.

        Args:
            db_path (str): Путь к файлу базы данных SQLite. По умолчанию 'items.db'.

        """
        self.db_path = db_path
        self._init_database()
        print(f"DEBUG: DatabaseManager initialized with db_path: {self.db_path}")

    def _init_database(self):
        """Инициализирует базу данных, создавая необходимые таблицы.

        Создает таблицы items, suppliers, item_suppliers и categories с соответствующей структурой.
        Обрабатывает ошибки при создании таблиц и выводит отладочные сообщения.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()

                # Создание таблицы items с полной структурой
                c.execute('''
                    CREATE TABLE IF NOT EXISTS items (
                        article TEXT PRIMARY KEY,
                        name TEXT NOT NULL,
                        description TEXT,
                        image_path TEXT NOT NULL,
                        category_id INTEGER,
                        price REAL NOT NULL DEFAULT 0.0,
                        stock INTEGER NOT NULL DEFAULT 0,
                        created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                        status TEXT DEFAULT 'в наличии',
                        unit TEXT DEFAULT 'шт.',
                        manufacturer TEXT,
                        document TEXT,
                        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
                    )
                ''')

                # Создание таблицы поставщики
                c.execute('''
                    CREATE TABLE IF NOT EXISTS suppliers (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT,
                        company TEXT NOT NULL,
                        email TEXT,
                        phone TEXT,
                        website TEXT
                    )
                ''')
                # Связь многие-ко-многим: товары — поставщики
                c.execute('''
                    CREATE TABLE IF NOT EXISTS item_suppliers (
                        item_article TEXT,
                        supplier_id INTEGER,
                        PRIMARY KEY (item_article, supplier_id),
                        FOREIGN KEY (item_article) REFERENCES items(article) ON DELETE CASCADE,
                        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
                    )
                ''')

                # Создание таблицы categories
                c.execute('''
                    CREATE TABLE IF NOT EXISTS categories (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT UNIQUE NOT NULL,
                        sku_prefix TEXT DEFAULT 'ITEM',
                        sku_digits INTEGER DEFAULT 4
                    )
                ''')
                # item_documents
                c.execute('''
                    CREATE TABLE IF NOT EXISTS item_documents (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        item_article TEXT NOT NULL,
                        document_path TEXT NOT NULL,
                        document_name TEXT,
                        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (item_article) REFERENCES items(article) ON DELETE CASCADE
                    )
                ''')
            print("DEBUG: Database tables 'items' and 'categories' created successfully")
        except Exception as e:
            print(f"DEBUG: Error initializing database: {str(e)}")

    def load_categories(self):
        """Загружает все категории из базы данных.

        Returns:
            list: Список кортежей с данными категорий (id, name, sku_prefix, sku_digits).
            Пустой список в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("SELECT id, name, sku_prefix, sku_digits FROM categories ORDER BY name")
                categories = c.fetchall()
            print(f"DEBUG: Loaded {len(categories)} categories from database")
            return categories
        except Exception as e:
            print(f"DEBUG: Error loading categories: {str(e)}")
            return []

    def add_category(self, name, sku_prefix='ITEM', sku_digits=4):
        """Добавляет новую категорию в базу данных.

        Args:
            name (str): Название категории.
            sku_prefix (str): Префикс для артикулов товаров в категории. По умолчанию 'ITEM'.
            sku_digits (int): Количество цифр в артикуле. По умолчанию 4.

        Raises:
            Exception: Если произошла ошибка при добавлении категории.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("INSERT INTO categories (name, sku_prefix, sku_digits) VALUES (?, ?, ?)",
                          (name, sku_prefix, sku_digits))
            print(f"DEBUG: Category '{name}' added with SKU template {sku_prefix}-{'X' * sku_digits}")
        except Exception as e:
            print(f"DEBUG: Error adding category: {str(e)}")
            raise

    def generate_next_sku(self, category_id):
        """Генерирует следующий артикул для указанной категории.

        Args:
            category_id (int): ID категории, для которой генерируется артикул.

        Returns:
            str: Новый артикул в формате {prefix}-{number}, или None в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()

                # Get category SKU template
                c.execute("SELECT sku_prefix, sku_digits FROM categories WHERE id = ?", (category_id,))
                result = c.fetchone()
                if not result:
                    return None

                prefix, digits = result

                # Find the highest existing SKU number for this category
                c.execute("""
                    SELECT article FROM items 
                    WHERE category_id = ? AND article LIKE ?
                    ORDER BY article DESC LIMIT 1
                """, (category_id, f"{prefix}-%"))

                last_sku = c.fetchone()
                if last_sku:
                    # Extract number from last SKU
                    try:
                        last_number = int(last_sku[0].split('-')[1])
                        next_number = last_number + 1
                    except (IndexError, ValueError):
                        next_number = 1
                else:
                    next_number = 1

                # Generate new SKU
                new_sku = f"{prefix}-{str(next_number).zfill(digits)}"
                return new_sku

        except Exception as e:
            print(f"DEBUG: Error generating SKU: {str(e)}")
            return None

    def update_category(self, category_id, new_name, sku_prefix, sku_digits):
        """Обновляет информацию о категории.

        Args:
            category_id (int): ID категории для обновления.
            new_name (str): Новое название категории.
            sku_prefix (str): Новый префикс артикула.
            sku_digits (int): Новое количество цифр в артикуле.

        Raises:
            Exception: Если произошла ошибка при обновлении категории.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                    UPDATE categories 
                    SET name = ?, sku_prefix = ?, sku_digits = ?
                    WHERE id = ?
                """, (new_name, sku_prefix, sku_digits, category_id))
            print(f"DEBUG: Category {category_id} updated: {new_name}, prefix={sku_prefix}, digits={sku_digits}")
        except Exception as e:
            print(f"DEBUG: Error updating category: {str(e)}")
            raise

    def delete_category(self, category_id):
        """Удаляет категорию из базы данных по ID.

        Args:
            category_id (int): ID категории для удаления.

        Raises:
            Exception: Если произошла ошибка при удалении категории.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM categories WHERE id = ?", (category_id,))
            print(f"DEBUG: Category {category_id} deleted successfully")
        except Exception as e:
            print(f"DEBUG: Error deleting category: {str(e)}")
            raise

    def load_suppliers(self):
        """Загружает всех поставщиков из базы данных.

        Returns:
            list: Список кортежей с данными поставщиков (id, name, company, email, phone, website).
            Пустой список в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("SELECT id, name, company, email, phone, website FROM suppliers")
                return c.fetchall()
        except Exception as e:
            print(f"DEBUG: Error loading suppliers: {e}")
            return []

    def add_supplier(self, name, company, email=None, phone=None, website=None):
        """Добавляет нового поставщика в базу данных.

        Args:
            name (str): Имя контактного лица поставщика.
            company (str): Название компании.
            email (str, optional): Электронная почта поставщика.
            phone (str, optional): Телефон поставщика.
            website (str, optional): Веб-сайт поставщика.

        Returns:
            list: Пустой список в случае ошибки (для обратной совместимости).

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("INSERT INTO suppliers (name, company, email, phone, website) VALUES (?, ?, ?, ?, ?)",
                          (name, company, email, phone, website))
        except Exception as e:
            print(f"DEBUG: Error add supplier: {e}")
            return []

    def update_supplier(self, supplier_id, name, company, email=None, phone=None, website=None):
        """Обновляет информацию о поставщике.

        Args:
            supplier_id (int): ID поставщика для обновления.
            name (str): Новое имя контактного лица.
            company (str): Новое название компании.
            email (str, optional): Новая электронная почта.
            phone (str, optional): Новый телефон.
            website (str, optional): Новый веб-сайт.

        Raises:
            Exception: Если произошла ошибка при обновлении поставщика.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("UPDATE suppliers SET name=?, company=?, email=?, phone=?, website=? WHERE id=?",
                          (name, company, email, phone, website, supplier_id))
        except Exception as e:
            print(f"DEBUG: Error update supplier: {e}")
            raise

    def delete_supplier(self, supplier_id):
        """Удаляет поставщика из базы данных по ID.

        Args:
            supplier_id (int): ID поставщика для удаления.

        Raises:
            Exception: Если произошла ошибка при удалении поставщика.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM suppliers WHERE id=?", (supplier_id,))
        except Exception as e:
            print(f"DEBUG: Error delete supplier: {e}")
            raise

    def get_suppliers_for_item(self, article):
        """Получает список поставщиков для указанного товара.

        Args:
            article (str): Артикул товара.

        Returns:
            list: Список кортежей с данными поставщиков (id, name, company, email, phone, website).
            Пустой список, если артикул некорректен или произошла ошибка.

        Raises:
            FileNotFoundError: Если файл базы данных не существует.

        """
        if not isinstance(article, str) or not article.strip():
            return []
        if not os.path.exists(self.db_path):
            raise FileNotFoundError(f"Database file {self.db_path} does not exist")
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                    SELECT s.id, s.name, s.company, s.email, s.phone, s.website
                    FROM suppliers s
                    JOIN item_suppliers item_supp ON s.id = item_supp.supplier_id
                    WHERE item_supp.item_article = ?
                """, (article,))
                return c.fetchall()
        except sqlite3.Error as e:
            print(f"Database error while fetching suppliers for article {article}: {e}")
            return []

    def set_suppliers_for_item(self, article, supplier_ids):
        """Устанавливает список поставщиков для товара, заменяя существующие связи.

        Args:
            article (str): Артикул товара.
            supplier_ids (list): Список ID поставщиков. Может быть пустым.

        Returns:
            bool: True, если операция успешна, False в случае ошибки или некорректных данных.

        Raises:
            FileNotFoundError: Если файл базы данных не существует.

        """
        if not isinstance(article, str) or not article.strip():
            print(f"Invalid article: {article}")
            return False

        if supplier_ids is None:
            print(f"supplier_ids cannot be None")
            return False

        if not os.path.exists(self.db_path):
            raise FileNotFoundError(f"Database file {self.db_path} does not exist")

        if supplier_ids:
            try:
                supplier_ids = [int(sid) for sid in supplier_ids]
            except (ValueError, TypeError) as e:
                print(f"Invalid supplier_ids conversion: {e}")
                return False

            if not all(isinstance(sid, int) and sid > 0 for sid in supplier_ids):
                print(f"Invalid supplier_ids after conversion: {supplier_ids}")
                return False

        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM item_suppliers WHERE item_article = ?", (article,))
                if supplier_ids:
                    c.executemany(
                        "INSERT INTO item_suppliers (item_article, supplier_id) VALUES (?, ?)",
                        [(article, sid) for sid in supplier_ids]
                    )
                conn.commit()
                return True
        except sqlite3.Error as e:
            return False

    def load_data(self):
        """Загружает все записи из таблицы items с информацией о категориях.

        Returns:
            list: Список кортежей с данными товаров (article, name, description, image_path,
            category_name, price, stock, created_date, status, unit, manufacturer, document).
            Пустой список в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                          SELECT i.article,
                                 i.name,
                                 i.description,
                                 i.image_path,
                                 COALESCE(c.name, 'Без категории') AS category_name,
                                 i.price,
                                 i.stock,
                                 i.created_date,
                                 i.status,
                                 i.unit,
                                 i.manufacturer,
                                 i.document
                          FROM items i
                                   LEFT JOIN categories c ON i.category_id = c.id
                          """)
                items = c.fetchall()
                return items
        except Exception as e:
            return []

    def add_item(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer,
                 document):
        """Добавляет новый товар в таблицу items.

        Args:
            article (str): Артикул товара.
            name (str): Название товара.
            description (str): Описание товара.
            image_path (str): Путь к изображению товара.
            category_id (int): ID категории.
            price (float): Цена товара.
            stock (int): Количество на складе.
            status (str): Статус товара (например, 'в наличии').
            unit (str): Единица измерения (например, 'шт.').
            manufacturer (str): Производитель.
            document (str): Связанный документ.

        Raises:
            Exception: Если произошла ошибка при добавлении товара.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                print(f"DEBUG: Executing INSERT for article={article}, category_id={category_id}, name={name}, description={description}, "
                      f"image_path={image_path}, price={price}, stock={stock}, status={status}, unit={unit}, "
                      f"manufacturer={manufacturer}, document={document}")
                cursor.execute('''
                    INSERT INTO items (
                        article, name, description, image_path, category_id, 
                        price, stock, status, unit, manufacturer, document
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    article, name, description, image_path, category_id,
                    price, stock, status or 'в наличии', unit or 'шт.',
                    manufacturer or '', document or ''
                ))
                conn.commit()
                print("DEBUG: Item inserted successfully. Commit done.")
        except sqlite3.Error as e:
            print(f"DEBUG: Database error in add_item: {str(e)}")
            raise Exception(f"Database error: {str(e)}")

    def update_item(self, old_article, article, name, description, image_path, category_id, price, stock, status='в наличии',
                    unit='шт.', manufacturer=None, document=None):
        """Обновляет запись о товаре в таблице items.

        Args:
            old_article (str): Текущий артикул товара.
            article (str): Новый артикул товара.
            name (str): Новое название товара.
            description (str): Новое описание товара.
            image_path (str): Новый путь к изображению.
            category_id (int): Новый ID категории.
            price (float): Новая цена.
            stock (int): Новое количество на складе.
            status (str): Новый статус (по умолчанию 'в наличии').
            unit (str): Новая единица измерения (по умолчанию 'шт.').
            manufacturer (str, optional): Новый производитель.
            document (str, optional): Новый документ.

        Raises:
            Exception: Если произошла ошибка при обновлении товара.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute(
                    """UPDATE items SET article=?, name=?, description=?, image_path=?, category_id=?, price=?, stock=?, status=?, unit=?, manufacturer=?, document=?
                       WHERE article=?""",
                    (article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document, old_article)
                )
            print("DEBUG: Item updated successfully in database")
        except Exception as e:
            print(f"DEBUG: Error updating item: {str(e)}")
            raise

    def delete_item(self, article):
        """Удаляет товар из таблицы items по артикулу и все связанные документы.

        Args:
            article (str): Артикул товара для удаления.

        Raises:
            Exception: Если произошла ошибка при удалении товара.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()

                # НОВОЕ: Сначала удаляем все документы этого товара
                c.execute("DELETE FROM item_documents WHERE item_article=?", (article,))
                deleted_docs = c.rowcount
                print(f"DEBUG: Deleted {deleted_docs} documents for article {article}")

                # Затем удаляем товар
                c.execute("DELETE FROM items WHERE article=?", (article,))

                conn.commit()

            print(f"DEBUG: Item with article {article} deleted successfully")
        except Exception as e:
            print(f"DEBUG: Error deleting item: {str(e)}")
            raise

    def load_specifications(self):
        """Загружает все спецификации из базы данных.

        Returns:
            list: Список кортежей с данными спецификаций (id, name, description, created_date,
            modified_date, status, labor_cost, overhead_percentage, final_price).
            Пустой список в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                          SELECT id,
                                 name,
                                 description,
                                 created_date,
                                 modified_date,
                                 status,
                                 labor_cost,
                                 overhead_percentage,
                                 final_price
                          FROM specifications
                          ORDER BY modified_date DESC
                          """)
                return c.fetchall()
        except Exception as e:
            print(f"DEBUG: Error loading specifications: {str(e)}")
            return []

    def get_specification(self, spec_id):
        """Получает спецификацию по её ID.

        Args:
            spec_id (int): ID спецификации.

        Returns:
            tuple: Кортеж с данными спецификации (id, name, description, created_date,
            modified_date, status, labor_cost, overhead_percentage, final_price).
            None в случае ошибки или если спецификация не найдена.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                          SELECT id,
                                 name,
                                 description,
                                 created_date,
                                 modified_date,
                                 status,
                                 labor_cost,
                                 overhead_percentage,
                                 final_price
                          FROM specifications
                          WHERE id = ?
                          """, (spec_id,))
                return c.fetchone()
        except Exception as e:
            print(f"DEBUG: Error getting specification: {str(e)}")
            return None

    def add_specification(self, name, description, status='черновик', labor_cost=0.0, overhead_percentage=0.0):
        """Создаёт новую спецификацию в базе данных.

        Args:
            name (str): Название спецификации.
            description (str): Описание спецификации.
            status (str): Статус спецификации (по умолчанию 'черновик').
            labor_cost (float): Стоимость работы (по умолчанию 0.0).
            overhead_percentage (float): Процент накладных расходов (по умолчанию 0.0).

        Returns:
            int: ID новой спецификации или None в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                c.execute("""
                          INSERT INTO specifications
                          (name, description, created_date, modified_date, status, labor_cost, overhead_percentage)
                          VALUES (?, ?, ?, ?, ?, ?, ?)
                          """, (name, description, now, now, status, labor_cost, overhead_percentage))
                spec_id = c.lastrowid
                conn.commit()
            print(f"DEBUG: Specification created with ID: {spec_id}")
            return spec_id
        except Exception as e:
            print(f"DEBUG: Error adding specification: {str(e)}")
            return None

    def update_specification(self, spec_id, name, description, status, labor_cost, overhead_percentage, final_price=0.0):
        """Обновляет существующую спецификацию.

        Args:
            spec_id (int): ID спецификации для обновления.
            name (str): Новое название.
            description (str): Новое описание.
            status (str): Новый статус.
            labor_cost (float): Новая стоимость работы.
            overhead_percentage (float): Новый процент накладных.
            final_price (float): Итоговая цена (по умолчанию 0.0).

        Returns:
            bool: True, если обновление успешно, False в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                c.execute("""
                          UPDATE specifications
                          SET name=?,
                              description=?,
                              modified_date=?,
                              status=?,
                              labor_cost=?,
                              overhead_percentage=?,
                              final_price=?
                          WHERE id = ?
                          """, (name, description, now, status, labor_cost, overhead_percentage, final_price, spec_id))
                conn.commit()
            print(f"DEBUG: Specification {spec_id} updated")
            return True
        except Exception as e:
            print(f"DEBUG: Error updating specification: {str(e)}")
            return False

    def delete_specification(self, spec_id):
        """Удаляет спецификацию и связанные с ней позиции.

        Args:
            spec_id (int): ID спецификации для удаления.

        Returns:
            bool: True, если удаление успешно, False в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM specifications WHERE id=?", (spec_id,))
                conn.commit()
            print(f"DEBUG: Specification {spec_id} deleted")
            return True
        except Exception as e:
            print(f"DEBUG: Error deleting specification: {str(e)}")
            return False

    def load_specification_items(self, spec_id):
        """Загружает все позиции спецификации с данными о товарах.

        Args:
            spec_id (int): ID спецификации.

        Returns:
            list: Список кортежей с данными позиций (id, specification_id, article, quantity, notes,
            name, unit, price, image_path, category, status, manufacturer, description).
            Пустой список в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                          SELECT si.id,
                                 si.specification_id,
                                 si.article,
                                 si.quantity,
                                 si.notes,
                                 i.name,
                                 i.unit,
                                 i.price,
                                 i.image_path,
                                 c.name as category,
                                 i.status,
                                 COALESCE(i.manufacturer, '') as manufacturer,
                                 COALESCE(i.description, '') as description
                          FROM specification_items si
                                   JOIN items i ON si.article = i.article
                                   LEFT JOIN categories c ON i.category_id = c.id
                          WHERE si.specification_id = ?
                          ORDER BY si.id
                          """, (spec_id,))
                return c.fetchall()
        except Exception as e:
            print(f"DEBUG: Error loading specification items: {str(e)}")
            return []

    def add_specification_item(self, spec_id, article, quantity, notes=None):
        """Добавляет новую позицию в спецификацию.

        Args:
            spec_id (int): ID спецификации.
            article (str): Артикул товара.
            quantity (int): Количество товара.
            notes (str, optional): Примечания к позиции.

        Returns:
            int: ID новой позиции или None в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                          INSERT INTO specification_items
                              (specification_id, article, quantity, notes)
                          VALUES (?, ?, ?, ?)
                          """, (spec_id, article, quantity, notes))
                item_id = c.lastrowid
                conn.commit()
            print(f"DEBUG: Specification item added with ID: {item_id}")
            return item_id
        except Exception as e:
            print(f"DEBUG: Error adding specification item: {str(e)}")
            return None

    def update_specification_item(self, item_id, quantity, notes=None):
        """Обновляет позицию в спецификации.

        Args:
            item_id (int): ID позиции для обновления.
            quantity (int): Новое количество.
            notes (str, optional): Новые примечания.

        Returns:
            bool: True, если обновление успешно, False в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                          UPDATE specification_items
                          SET quantity=?,
                              notes=?
                          WHERE id = ?
                          """, (quantity, notes, item_id))
                conn.commit()
            return True
        except Exception as e:
            print(f"DEBUG: Error updating specification item: {str(e)}")
            return False

    def delete_specification_item(self, item_id):
        """Удаляет позицию из спецификации.

        Args:
            item_id (int): ID позиции для удаления.

        Returns:
            bool: True, если удаление успешно, False в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM specification_items WHERE id=?", (item_id,))
                conn.commit()
            return True
        except Exception as e:
            print(f"DEBUG: Error deleting specification item: {str(e)}")
            return False

    def clear_specification_items(self, spec_id):
        """Удаляет все позиции указанной спецификации.

        Args:
            spec_id (int): ID спецификации.

        Returns:
            bool: True, если удаление успешно, False в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM specification_items WHERE specification_id=?", (spec_id,))
                conn.commit()
            return True
        except Exception as e:
            print(f"DEBUG: Error clearing specification items: {str(e)}")
            return False

    def save_specification_with_items(self, spec_id, name, description, status, labor_cost, overhead_percentage, items):
        """Сохраняет спецификацию и её позиции транзакционно.

        Args:
            spec_id (int): ID спецификации (None для новой).
            name (str): Название спецификации.
            description (str): Описание спецификации.
            status (str): Статус спецификации.
            labor_cost (float): Стоимость работы.
            overhead_percentage (float): Процент накладных расходов.
            items (list): Список словарей с данными позиций [{article, quantity, notes}, ...].

        Returns:
            int: ID спецификации или None в случае ошибки.

        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                materials_cost = 0
                for item in items:
                    c.execute("SELECT price FROM items WHERE article = ?", (item['article'],))
                    result = c.fetchone()
                    if result:
                        materials_cost += result[0] * item['quantity']

                overhead_cost = materials_cost * (overhead_percentage / 100)
                final_price = materials_cost + labor_cost + overhead_cost

                if spec_id is None or spec_id <= 0:
                    c.execute("""
                              INSERT INTO specifications
                              (name, description, created_date, modified_date, status,
                               labor_cost, overhead_percentage, final_price)
                              VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                              """, (name, description, now, now, status, labor_cost, overhead_percentage, final_price))
                    spec_id = c.lastrowid
                else:
                    c.execute("""
                              UPDATE specifications
                              SET name=?,
                                  description=?,
                                  modified_date=?,
                                  status=?,
                                  labor_cost=?,
                                  overhead_percentage=?,
                                  final_price=?
                              WHERE id = ?
                              """,
                              (name, description, now, status, labor_cost, overhead_percentage, final_price, spec_id))

                c.execute("DELETE FROM specification_items WHERE specification_id=?", (spec_id,))

                for item in items:
                    c.execute("""
                              INSERT INTO specification_items
                                  (specification_id, article, quantity, notes)
                              VALUES (?, ?, ?, ?)
                              """, (spec_id, item['article'], item['quantity'], item.get('notes', '')))

                conn.commit()
                print(f"DEBUG: Specification {spec_id} saved with {len(items)} items")
                return spec_id

        except Exception as e:
            print(f"DEBUG: Error saving specification with items: {str(e)}")
            return None

    # ===========================
    # МЕТОД 1: add_item_document
    # ===========================
    def add_item_document(self, article, document_path, document_name=None):
        """Добавляет документ к товару.

        Args:
            article (str): Артикул товара.
            document_path (str): Относительный путь к документу.
            document_name (str, optional): Пользовательское имя документа.

        Returns:
            int: ID добавленного документа или None в случае ошибки.
        """
        print("=" * 60)
        print("DATABASE: add_item_document CALLED")
        print(f"article: {article}")
        print(f"document_path: {document_path}")
        print(f"document_name: {document_name}")
        print("=" * 60)
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()

                # Если имя не указано, используем имя файла
                if document_name is None:
                    from pathlib import Path
                    document_name = Path(document_path).name

                c.execute("""
                    INSERT INTO item_documents (item_article, document_path, document_name)
                    VALUES (?, ?, ?)
                """, (article, document_path, document_name))

                doc_id = c.lastrowid
                conn.commit()

            print(f"DEBUG: Document added for item {article}: {document_name}")
            return doc_id

        except Exception as e:
            print(f"DEBUG: Error adding document: {str(e)}")
            return None

    # =============================
    # МЕТОД 2: get_item_documents
    # =============================
    def get_item_documents(self, article):
        """Получает все документы товара.

        Args:
            article (str): Артикул товара.

        Returns:
            list: Список кортежей (id, document_path, document_name, added_date)
        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                    SELECT id, document_path, document_name, added_date
                    FROM item_documents
                    WHERE item_article = ?
                    ORDER BY added_date DESC
                """, (article,))

                documents = c.fetchall()

            print(f"DEBUG: Loaded {len(documents)} documents for item {article}")
            return documents

        except Exception as e:
            print(f"DEBUG: Error loading documents: {str(e)}")
            return []

    # ===============================
    # МЕТОД 3: delete_item_document
    # ===============================
    def delete_item_document(self, doc_id):
        """Удаляет документ товара.

        Args:
            doc_id (int): ID документа.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM item_documents WHERE id = ?", (doc_id,))
                conn.commit()

            print(f"DEBUG: Document {doc_id} deleted")
            return True

        except Exception as e:
            print(f"DEBUG: Error deleting document: {str(e)}")
            return False

    # =====================================
    # МЕТОД 4: update_item_document_name
    # =====================================
    def update_item_document_name(self, doc_id, new_name):
        """Обновляет имя документа.

        Args:
            doc_id (int): ID документа.
            new_name (str): Новое имя документа.

        Returns:
            bool: True если обновление успешно, False в случае ошибки.
        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                    UPDATE item_documents
                    SET document_name = ?
                    WHERE id = ?
                """, (new_name, doc_id))
                conn.commit()

            print(f"DEBUG: Document {doc_id} renamed to {new_name}")
            return True

        except Exception as e:
            print(f"DEBUG: Error updating document name: {str(e)}")
            return False

    # ==========================================
    # МЕТОД 5: migrate_documents_to_new_table
    # ==========================================
    def migrate_documents_to_new_table(self):
        """Мигрирует существующие документы из поля document в новую таблицу item_documents.

        Эта функция должна быть вызвана один раз после обновления структуры БД.

        Returns:
            int: Количество мигрированных документов.
        """
        try:
            migrated_count = 0

            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()

                # Получаем все товары с непустым полем document
                c.execute("SELECT article, document FROM items WHERE document IS NOT NULL AND document != ''")
                items_with_docs = c.fetchall()

                for article, document_path in items_with_docs:
                    # Проверяем, не добавлен ли уже этот документ
                    c.execute("""
                        SELECT COUNT(*) FROM item_documents 
                        WHERE item_article = ? AND document_path = ?
                    """, (article, document_path))

                    if c.fetchone()[0] == 0:
                        # Добавляем документ в новую таблицу
                        from pathlib import Path
                        document_name = Path(document_path).name

                        c.execute("""
                            INSERT INTO item_documents (item_article, document_path, document_name)
                            VALUES (?, ?, ?)
                        """, (article, document_path, document_name))

                        migrated_count += 1

                conn.commit()

            print(f"DEBUG: Migration completed: {migrated_count} documents migrated")
            return migrated_count

        except Exception as e:
            print(f"DEBUG: Error during document migration: {str(e)}")
            return 0

