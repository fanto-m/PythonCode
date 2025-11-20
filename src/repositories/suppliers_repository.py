"""Репозиторий для управления поставщиками"""

from typing import List
from loguru import logger

from repositories.base_repository import BaseRepository  # ← ПРАВИЛЬНО
from models.dto import Supplier  # ← ПРАВИЛЬНО


class SuppliersRepository(BaseRepository):
    """
    Репозиторий для управления поставщиками.

    Предоставляет методы для:
    - Создания и загрузки поставщиков
    - Обновления и удаления поставщиков
    - Управления связями товар-поставщик
    """

    def create_table(self):
        """Создает таблицы suppliers и item_suppliers если не существуют."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Таблица поставщиков
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS suppliers (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT,
                        company TEXT NOT NULL,
                        email TEXT,
                        phone TEXT,
                        website TEXT
                    )
                ''')

                # Таблица связей многие-ко-многим: товары — поставщики
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS item_suppliers (
                        item_article TEXT,
                        supplier_id INTEGER,
                        PRIMARY KEY (item_article, supplier_id),
                        FOREIGN KEY (item_article) REFERENCES items(article) ON DELETE CASCADE,
                        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
                    )
                ''')

            logger.success("✅ Suppliers tables created/verified")

        except Exception as e:
            logger.error(f"❌ Error creating suppliers tables: {e}")
            raise

    def get_all(self) -> List[Supplier]:
        """
        Загружает всех поставщиков из базы данных.

        Returns:
            List[Supplier]: Список всех поставщиков.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT id, name, company, email, phone, website 
                    FROM suppliers
                    ORDER BY company
                """)
                rows = cursor.fetchall()

                suppliers = [
                    Supplier(
                        id=row[0],
                        name=row[1],
                        company=row[2],
                        email=row[3],
                        phone=row[4],
                        website=row[5]
                    )
                    for row in rows
                ]

            logger.info(f"🏢 Loaded {len(suppliers)} suppliers")
            return suppliers

        except Exception as e:
            logger.error(f"❌ Error loading suppliers: {e}")
            return []

    def add(self, supplier: Supplier) -> int:
        """
        Добавляет нового поставщика в базу данных.

        Args:
            supplier: Объект поставщика для добавления.

        Returns:
            int: ID созданного поставщика.

        Raises:
            Exception: Если произошла ошибка при добавлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO suppliers (name, company, email, phone, website) 
                    VALUES (?, ?, ?, ?, ?)
                """, (supplier.name, supplier.company, supplier.email,
                      supplier.phone, supplier.website))

                supplier_id = cursor.lastrowid

            logger.success(f"✅ Supplier added: {supplier.company} (ID: {supplier_id})")
            return supplier_id

        except Exception as e:
            logger.error(f"❌ Error adding supplier '{supplier.company}': {e}")
            raise

    def update(self, supplier_id: int, supplier: Supplier) -> None:
        """
        Обновляет информацию о поставщике.

        Args:
            supplier_id: ID поставщика для обновления.
            supplier: Объект поставщика с новыми данными.

        Raises:
            Exception: Если произошла ошибка при обновлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE suppliers 
                    SET name=?, company=?, email=?, phone=?, website=? 
                    WHERE id=?
                """, (supplier.name, supplier.company, supplier.email,
                      supplier.phone, supplier.website, supplier_id))

            logger.success(f"✅ Supplier {supplier_id} updated: {supplier.company}")

        except Exception as e:
            logger.error(f"❌ Error updating supplier {supplier_id}: {e}")
            raise

    def delete(self, supplier_id: int) -> None:
        """
        Удаляет поставщика из базы данных.

        Args:
            supplier_id: ID поставщика для удаления.

        Raises:
            Exception: Если произошла ошибка при удалении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM suppliers WHERE id=?", (supplier_id,))

            logger.warning(f"⚠️ Supplier {supplier_id} deleted")

        except Exception as e:
            logger.error(f"❌ Error deleting supplier {supplier_id}: {e}")
            raise

    def get_suppliers_for_item(self, article: str) -> List[Supplier]:
        """
        Получает список поставщиков для указанного товара.

        Args:
            article: Артикул товара.

        Returns:
            List[Supplier]: Список поставщиков товара.
        """
        if not isinstance(article, str) or not article.strip():
            logger.warning(f"⚠️ Invalid article: {article}")
            return []

        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT s.id, s.name, s.company, s.email, s.phone, s.website
                    FROM suppliers s
                    JOIN item_suppliers item_supp ON s.id = item_supp.supplier_id
                    WHERE item_supp.item_article = ?
                """, (article,))
                rows = cursor.fetchall()

                suppliers = [
                    Supplier(
                        id=row[0],
                        name=row[1],
                        company=row[2],
                        email=row[3],
                        phone=row[4],
                        website=row[5]
                    )
                    for row in rows
                ]

            logger.debug(f"🔗 Found {len(suppliers)} suppliers for article {article}")
            return suppliers

        except Exception as e:
            logger.error(f"❌ Error fetching suppliers for article {article}: {e}")
            return []

    def set_suppliers_for_item(self, article: str, supplier_ids: List[int]) -> bool:
        """
        Устанавливает список поставщиков для товара, заменяя существующие связи.

        Args:
            article: Артикул товара.
            supplier_ids: Список ID поставщиков.

        Returns:
            bool: True, если операция успешна, False в случае ошибки.
        """
        if not isinstance(article, str) or not article.strip():
            logger.warning(f"⚠️ Invalid article: {article}")
            return False

        if supplier_ids is None:
            logger.warning("⚠️ supplier_ids cannot be None")
            return False

        # Валидация ID поставщиков
        if supplier_ids:
            try:
                supplier_ids = [int(sid) for sid in supplier_ids]
            except (ValueError, TypeError) as e:
                logger.error(f"❌ Invalid supplier_ids conversion: {e}")
                return False

            if not all(isinstance(sid, int) and sid > 0 for sid in supplier_ids):
                logger.error(f"❌ Invalid supplier_ids: {supplier_ids}")
                return False

        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Удаляем старые связи
                cursor.execute(
                    "DELETE FROM item_suppliers WHERE item_article = ?",
                    (article,)
                )

                # Добавляем новые связи
                if supplier_ids:
                    cursor.executemany(
                        "INSERT INTO item_suppliers (item_article, supplier_id) VALUES (?, ?)",
                        [(article, sid) for sid in supplier_ids]
                    )

            logger.success(
                f"✅ Suppliers updated for article {article}: "
                f"{len(supplier_ids)} supplier(s) linked"
            )
            return True

        except Exception as e:
            logger.error(f"❌ Error setting suppliers for article {article}: {e}")
            return False