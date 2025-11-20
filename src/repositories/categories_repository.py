"""Репозиторий для управления категориями товаров"""

from typing import List, Optional
from loguru import logger

from repositories.base_repository import BaseRepository  # ← ПРАВИЛЬНО
from models.dto import Category  # ← ПРАВИЛЬНО


class CategoriesRepository(BaseRepository):
    """
    Репозиторий для управления категориями товаров.

    Предоставляет методы для:
    - Создания и загрузки категорий
    - Обновления и удаления категорий
    - Генерации артикулов (SKU) для товаров
    """

    def create_table(self):
        """Создает таблицу categories если не существует."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS categories (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT UNIQUE NOT NULL,
                        sku_prefix TEXT DEFAULT 'ITEM',
                        sku_digits INTEGER DEFAULT 4
                    )
                ''')
            logger.success("✅ Categories table created/verified")
        except Exception as e:
            logger.error(f"❌ Error creating categories table: {e}")
            raise

    def get_all(self) -> List[Category]:
        """
        Загружает все категории из базы данных.

        Returns:
            List[Category]: Список всех категорий, отсортированных по имени.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT id, name, sku_prefix, sku_digits 
                    FROM categories 
                    ORDER BY name
                """)
                rows = cursor.fetchall()

                categories = [
                    Category(
                        id=row[0],
                        name=row[1],
                        sku_prefix=row[2],
                        sku_digits=row[3]
                    )
                    for row in rows
                ]

            logger.info(f"📦 Loaded {len(categories)} categories")
            return categories

        except Exception as e:
            logger.error(f"❌ Error loading categories: {e}")
            return []

    def add(self, category: Category) -> int:
        """
        Добавляет новую категорию в базу данных.

        Args:
            category: Объект категории для добавления.

        Returns:
            int: ID созданной категории.

        Raises:
            Exception: Если произошла ошибка при добавлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO categories (name, sku_prefix, sku_digits) 
                    VALUES (?, ?, ?)
                """, (category.name, category.sku_prefix, category.sku_digits))

                category_id = cursor.lastrowid

            logger.success(
                f"✅ Category added: '{category.name}' "
                f"(SKU: {category.sku_prefix}-{'X' * category.sku_digits})"
            )
            return category_id

        except Exception as e:
            logger.error(f"❌ Error adding category '{category.name}': {e}")
            raise

    def update(self, category_id: int, category: Category) -> None:
        """
        Обновляет информацию о категории.

        Args:
            category_id: ID категории для обновления.
            category: Объект категории с новыми данными.

        Raises:
            Exception: Если произошла ошибка при обновлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE categories 
                    SET name = ?, sku_prefix = ?, sku_digits = ?
                    WHERE id = ?
                """, (category.name, category.sku_prefix, category.sku_digits, category_id))

            logger.success(
                f"✅ Category {category_id} updated: {category.name} "
                f"(prefix={category.sku_prefix}, digits={category.sku_digits})"
            )

        except Exception as e:
            logger.error(f"❌ Error updating category {category_id}: {e}")
            raise

    def delete(self, category_id: int) -> None:
        """
        Удаляет категорию из базы данных.

        Args:
            category_id: ID категории для удаления.

        Raises:
            Exception: Если произошла ошибка при удалении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM categories WHERE id = ?", (category_id,))

            logger.warning(f"⚠️ Category {category_id} deleted")

        except Exception as e:
            logger.error(f"❌ Error deleting category {category_id}: {e}")
            raise

    def generate_next_sku(self, category_id: int) -> Optional[str]:
        """
        Генерирует следующий артикул (SKU) для указанной категории.

        Артикул генерируется в формате: {prefix}-{number}
        Например: ITEM-0001, TOOL-0042

        Args:
            category_id: ID категории.

        Returns:
            str: Новый артикул или None, если категория не найдена.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Получаем шаблон SKU для категории
                cursor.execute("""
                    SELECT sku_prefix, sku_digits 
                    FROM categories 
                    WHERE id = ?
                """, (category_id,))

                result = cursor.fetchone()
                if not result:
                    logger.warning(f"⚠️ Category {category_id} not found")
                    return None

                prefix, digits = result

                # Находим последний артикул для этой категории
                cursor.execute("""
                    SELECT article FROM items 
                    WHERE category_id = ? AND article LIKE ?
                    ORDER BY article DESC LIMIT 1
                """, (category_id, f"{prefix}-%"))

                last_sku = cursor.fetchone()

                if last_sku:
                    try:
                        # Извлекаем номер из последнего артикула
                        last_number = int(last_sku[0].split('-')[1])
                        next_number = last_number + 1
                    except (IndexError, ValueError):
                        next_number = 1
                else:
                    next_number = 1

                # Генерируем новый SKU
                new_sku = f"{prefix}-{str(next_number).zfill(digits)}"

            logger.info(f"🔢 Generated SKU: {new_sku} for category {category_id}")
            return new_sku

        except Exception as e:
            logger.error(f"❌ Error generating SKU for category {category_id}: {e}")
            return None