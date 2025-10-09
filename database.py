#database.py
import sqlite3
import os
from datetime import datetime

class DatabaseManager:
    def __init__(self, db_path="items.db"):
        self.db_path = db_path
        self._init_database()
        print(f"DEBUG: DatabaseManager initialized with db_path: {self.db_path}")

    def _init_database(self):
        """Инициализирует базу данных, создавая таблицы с правильной структурой."""
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
                        barcode TEXT,
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
                # In _init_database method, modify the categories table:
                c.execute('''
                    CREATE TABLE IF NOT EXISTS categories (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT UNIQUE NOT NULL,
                        sku_prefix TEXT DEFAULT 'ITEM',
                        sku_digits INTEGER DEFAULT 4
                    )
                ''')
            print("DEBUG: Database tables 'items' and 'categories' created successfully")
        except Exception as e:
            print(f"DEBUG: Error initializing database: {str(e)}")



    # ------------------ Категории ---------------------------

    def load_categories(self):
        """Загружает все категории"""
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
        """Добавляет новую категорию с шаблоном SKU"""
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
        """Генерирует следующий артикул для категории"""
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
        """Обновляет категорию с префиксом и количеством цифр"""
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
        """Удаляет категорию по id"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM categories WHERE id = ?", (category_id,))
            print(f"DEBUG: Category {category_id} deleted successfully")
        except Exception as e:
            print(f"DEBUG: Error deleting category: {str(e)}")
            raise

    def load_suppliers(self):
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("SELECT id, name, company, email, phone, website FROM suppliers")
                return c.fetchall()
        except Exception as e:
            print(f"DEBUG: Error loading suppliers: {e}")
            return []

    def add_supplier(self, name, company, email=None, phone=None, website=None):
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("INSERT INTO suppliers (name, company, email, phone, website) VALUES (?, ?, ?, ?, ?)",
                    (name, company, email, phone, website)
                )
        except Exception as e:
            print(f"DEBUG: Error add supplier: {e}")
            return []
    def update_supplier(self, supplier_id, name, company, email=None, phone=None, website=None):
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("UPDATE suppliers SET name=?, company=?, email=?, phone=?, website=? WHERE id=?",
                    (name, company, email, phone, website, supplier_id)
                )
        except Exception as e:
            print(f"DEBUG: Error update supplier: {e}")
            raise


    def delete_supplier(self, supplier_id):
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM suppliers WHERE id=?", (supplier_id,))
        except Exception as e:
            print(f"DEBUG: Error delete supplier: {e}")
            raise

    def get_suppliers_for_item(self, article):
        """Получить поставщиков для товара.
        :param article:
        :return:
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
                #print(f"DEBUG: get_suppliers_for_item({article}) returned {rusult}")
                return c.fetchall()  # ← Возвращаем кортежи, как в load_suppliers()
        except sqlite3.Error as e:
            print(f"Database error while fetching suppliers for article {article}: {e}")
            return []  # Или выбросить кастомное исключение

    def set_suppliers_for_item(self, article, supplier_ids):
        """Установить поставщиков для товара (полная замена)."""

        if not isinstance(article, str) or not article.strip():
            print(f"Invalid article: {article}")
            return False

        # Allow empty list, but validate non-empty lists
        if supplier_ids is None:
            print(f"supplier_ids cannot be None")
            return False

        if not os.path.exists(self.db_path):
            raise FileNotFoundError(f"Database file {self.db_path} does not exist")

        # Convert and validate supplier_ids if list is not empty
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
                # Удаляем все существующие связи для артикула
                c.execute("DELETE FROM item_suppliers WHERE item_article = ?", (article,))

                # Добавляем новые связи только если список не пустой
                if supplier_ids:
                    c.executemany(
                        "INSERT INTO item_suppliers (item_article, supplier_id) VALUES (?, ?)",
                        [(article, sid) for sid in supplier_ids]
                    )

                conn.commit()
                return True
        except sqlite3.Error as e:
            print(f"Database error while setting suppliers for article {article}: {e}")
            return False
    def load_data(self):
        """Загружает все записи из таблицы items."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("""
                            SELECT 
                                i.article, 
                                i.name, 
                                i.description, 
                                i.image_path, 
                                COALESCE(c.name, 'Без категории') AS category_name,  -- ← заменяем category_id на имя
                                i.price, 
                                i.stock, 
                                i.created_date, 
                                i.status, 
                                i.unit, 
                                i.manufacturer, 
                                i.barcode 
                            FROM items i
                            LEFT JOIN categories c ON i.category_id = c.id
                        """)
                items = c.fetchall()
            print(f"DEBUG: Loaded {len(items)} items from database")
            for i, item in enumerate(items):
                print(f"DEBUG: Item {i}: {item}")
            return items
        except Exception as e:
            print(f"DEBUG: Error loading data: {str(e)}")
            return []

    def add_item(self, article, name, description, image_path, category_id, price, stock, status='в наличии', unit='шт.', manufacturer=None, barcode=None):
        """Добавляет новую запись в таблицу items."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute(
                    "INSERT INTO items (article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, barcode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    (article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, barcode)
                )
            print("DEBUG: Item added successfully to database")
        except Exception as e:
            print(f"DEBUG: Error adding item: {str(e)}")
            raise

    def update_item(self, old_article, article, name, description, image_path, category_id, price, stock, status='в наличии', unit='шт.', manufacturer=None, barcode=None):
        """Обновляет запись в таблице items по старому артикулу."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute(
                    """UPDATE items SET article=?, name=?, description=?, image_path=?, category_id=?, price=?, stock=?, status=?, unit=?, manufacturer=?, barcode=?
                       WHERE article=?""",
                    (article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, barcode, old_article)
                )

            print("DEBUG: Item updated successfully in database")
        except Exception as e:
            print(f"DEBUG: Error updating item: {str(e)}")
            raise

    def delete_item(self, article):
        """Удаляет запись из таблицы items по артикулу."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                c.execute("DELETE FROM items WHERE article=?", (article,))
            print(f"DEBUG: Item with article {article} deleted successfully")
        except Exception as e:
            print(f"DEBUG: Error deleting item: {str(e)}")
            raise

    # database_specifications_methods.py
    # Add these methods to your DatabaseManager class in database.py

    """
    Добавьте эти методы в класс DatabaseManager в файле database.py
    """

    # ========================================
    # СПЕЦИФИКАЦИИ
    # ========================================

    def load_specifications(self):
        """Загружает все спецификации"""
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
        """Получает одну спецификацию по ID"""
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
        """Создает новую спецификацию"""
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

    def update_specification(self, spec_id, name, description, status, labor_cost, overhead_percentage,
                             final_price=0.0):
        """Обновляет спецификацию"""
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
        """Удаляет спецификацию (каскадно удаляются и позиции)"""
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

    # ------------------ Позиции спецификации ---------------------------

    def load_specification_items(self, spec_id):
        """Загружает все позиции спецификации с данными о товарах"""
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
                                 i.image_path
                          FROM specification_items si
                                   JOIN items i ON si.article = i.article
                          WHERE si.specification_id = ?
                          ORDER BY si.id
                          """, (spec_id,))
                return c.fetchall()
        except Exception as e:
            print(f"DEBUG: Error loading specification items: {str(e)}")
            return []

    def add_specification_item(self, spec_id, article, quantity, notes=None):
        """Добавляет позицию в спецификацию"""
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
        """Обновляет позицию спецификации"""
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
        """Удаляет позицию из спецификации"""
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
        """Удаляет все позиции спецификации"""
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
        """
        Сохраняет спецификацию вместе со всеми позициями (транзакционно)

        :param spec_id: ID спецификации (None для новой)
        :param name: Название
        :param description: Описание
        :param status: Статус
        :param labor_cost: Стоимость работы
        :param overhead_percentage: Процент накладных
        :param items: Список словарей [{article, quantity, notes}, ...]
        :return: ID спецификации или None при ошибке
        """
        try:
            with sqlite3.connect(self.db_path) as conn:
                c = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                # Calculate total costs
                materials_cost = 0
                for item in items:
                    # Get price from items table
                    c.execute("SELECT price FROM items WHERE article = ?", (item['article'],))
                    result = c.fetchone()
                    if result:
                        materials_cost += result[0] * item['quantity']

                overhead_cost = materials_cost * (overhead_percentage / 100)
                final_price = materials_cost + labor_cost + overhead_cost

                if spec_id is None or spec_id <= 0:
                    # Create new specification
                    c.execute("""
                              INSERT INTO specifications
                              (name, description, created_date, modified_date, status,
                               labor_cost, overhead_percentage, final_price)
                              VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                              """, (name, description, now, now, status, labor_cost, overhead_percentage, final_price))
                    spec_id = c.lastrowid
                else:
                    # Update existing specification
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

                # Clear old items and insert new ones
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