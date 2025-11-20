"""Репозиторий для управления товарами"""

from typing import List, Tuple
from loguru import logger

from repositories.base_repository import BaseRepository  # ← ПРАВИЛЬНО
from models.dto import Item  # ← ПРАВИЛЬНО

class ItemsRepository(BaseRepository):
    """
    Репозиторий для управления товарами.

    Предоставляет методы для:
    - Создания и загрузки товаров
    - Обновления и удаления товаров
    - Поиска и фильтрации товаров
    """

    def create_table(self):
        """Создает таблицу items если не существует."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('''
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

            logger.success("✅ Items table created/verified")

        except Exception as e:
            logger.error(f"❌ Error creating items table: {e}")
            raise

    def get_all(self) -> List[Tuple]:
        """
        Загружает все товары с информацией о категориях.

        Returns:
            List[Tuple]: Список кортежей с данными товаров.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT 
                        i.article,
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
                    ORDER BY i.created_date DESC
                """)
                items = cursor.fetchall()

            logger.info(f"📦 Loaded {len(items)} items")
            return items

        except Exception as e:
            logger.error(f"❌ Error loading items: {e}")
            return []

    def add(self, item: Item) -> str:
        """
        Добавляет новый товар в базу данных.

        Args:
            item: Объект товара для добавления.

        Returns:
            str: Артикул добавленного товара.

        Raises:
            Exception: Если произошла ошибка при добавлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                logger.debug(
                    f"Inserting item: article={item.article}, name={item.name}, "
                    f"category_id={item.category_id}, price={item.price}, stock={item.stock}"
                )

                cursor.execute('''
                    INSERT INTO items (
                        article, name, description, image_path, category_id, 
                        price, stock, status, unit, manufacturer, document
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    item.article,
                    item.name,
                    item.description,
                    item.image_path,
                    item.category_id,
                    item.price,
                    item.stock,
                    item.status or 'в наличии',
                    item.unit or 'шт.',
                    item.manufacturer or '',
                    item.document or ''
                ))

            logger.success(f"✅ Item added: {item.article} - {item.name}")
            return item.article

        except Exception as e:
            logger.error(f"❌ Error adding item {item.article}: {e}")
            raise

    def update(self, old_article: str, item: Item) -> None:
        """
        Обновляет информацию о товаре.

        Args:
            old_article: Текущий артикул товара.
            item: Объект товара с новыми данными.

        Raises:
            Exception: Если произошла ошибка при обновлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE items 
                    SET article=?, name=?, description=?, image_path=?, 
                        category_id=?, price=?, stock=?, status=?, 
                        unit=?, manufacturer=?, document=?
                    WHERE article=?
                """, (
                    item.article,
                    item.name,
                    item.description,
                    item.image_path,
                    item.category_id,
                    item.price,
                    item.stock,
                    item.status,
                    item.unit,
                    item.manufacturer,
                    item.document,
                    old_article
                ))

            logger.success(f"✅ Item updated: {old_article} -> {item.article}")

        except Exception as e:
            logger.error(f"❌ Error updating item {old_article}: {e}")
            raise

    def delete(self, article: str) -> None:
        """
        Удаляет товар и все связанные документы.

        Args:
            article: Артикул товара для удаления.

        Raises:
            Exception: Если произошла ошибка при удалении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Удаляем документы товара
                cursor.execute(
                    "DELETE FROM item_documents WHERE item_article=?",
                    (article,)
                )
                deleted_docs = cursor.rowcount

                # Удаляем товар
                cursor.execute("DELETE FROM items WHERE article=?", (article,))

            logger.success(
                f"✅ Item deleted: {article} "
                f"(with {deleted_docs} document(s))"
            )

        except Exception as e:
            logger.error(f"❌ Error deleting item {article}: {e}")
            raise

    def search(self, query: str, field: str = "name") -> List[Tuple]:
        """
        Ищет товары по заданному полю.

        Args:
            query: Поисковый запрос.
            field: Поле для поиска (name, article, manufacturer и т.д.).

        Returns:
            List[Tuple]: Список найденных товаров.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Безопасная подстановка имени поля
                allowed_fields = ['name', 'article', 'manufacturer', 'description']
                if field not in allowed_fields:
                    field = 'name'

                cursor.execute(f"""
                    SELECT 
                        i.article,
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
                    WHERE i.{field} LIKE ?
                    ORDER BY i.created_date DESC
                """, (f"%{query}%",))

                results = cursor.fetchall()

            logger.info(f"🔍 Search '{query}' in '{field}': {len(results)} results")
            return results

        except Exception as e:
            logger.error(f"❌ Error searching items: {e}")
            return []

    def get_by_article(self, article: str) -> Tuple | None:
        """
        Получает товар по артикулу.

        Args:
            article: Артикул товара.

        Returns:
            Tuple: Данные товара или None, если не найден.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT 
                        i.article,
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
                    WHERE i.article = ?
                """, (article,))

                item = cursor.fetchone()

            if item:
                logger.debug(f"✅ Found item: {article}")
            else:
                logger.warning(f"⚠️ Item not found: {article}")

            return item

        except Exception as e:
            logger.error(f"❌ Error getting item {article}: {e}")
            return None