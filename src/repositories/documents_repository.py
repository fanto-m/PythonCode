#documents_repository.py
"""Репозиторий для управления документами товаров"""

from typing import List
from pathlib import Path
from loguru import logger

from repositories.base_repository import BaseRepository  # ← ПРАВИЛЬНО
from models.dto import Document  # ← ПРАВИЛЬНО


class DocumentsRepository(BaseRepository):
    """
    Репозиторий для управления документами товаров.

    Предоставляет методы для:
    - Добавления документов к товарам
    - Загрузки документов товара
    - Удаления и переименования документов
    - Миграции старых документов
    """

    def create_table(self):
        """Создает таблицу item_documents если не существует."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS item_documents (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        item_article TEXT NOT NULL,
                        document_path TEXT NOT NULL,
                        document_name TEXT,
                        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (item_article) REFERENCES items(article) ON DELETE CASCADE
                    )
                ''')

            logger.success("✅ Documents table created/verified")

        except Exception as e:
            logger.error(f"❌ Error creating documents table: {e}")
            raise

    def add(self, article: str, document_path: str, document_name: str = None) -> int:
        """
        Добавляет документ к товару.

        Args:
            article: Артикул товара.
            document_path: Относительный путь к документу.
            document_name: Пользовательское имя документа (опционально).

        Returns:
            int: ID добавленного документа.

        Raises:
            Exception: Если произошла ошибка при добавлении.
        """
        logger.debug(f"Adding document: article={article}, path={document_path}")

        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Если имя не указано, используем имя файла
                if document_name is None:
                    document_name = Path(document_path).name

                cursor.execute("""
                    INSERT INTO item_documents (item_article, document_path, document_name)
                    VALUES (?, ?, ?)
                """, (article, document_path, document_name))

                doc_id = cursor.lastrowid

            logger.success(f"✅ Document added for item {article}: {document_name} (ID: {doc_id})")
            return doc_id

        except Exception as e:
            logger.error(f"❌ Error adding document: {e}")
            raise

    def get_for_item(self, article: str) -> List[Document]:
        """
        Получает все документы товара.

        Args:
            article: Артикул товара.

        Returns:
            List[Document]: Список документов товара.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT id, item_article, document_path, document_name, added_date
                    FROM item_documents
                    WHERE item_article = ?
                    ORDER BY added_date DESC
                """, (article,))

                rows = cursor.fetchall()

                documents = [
                    Document(
                        id=row[0],
                        item_article=row[1],
                        document_path=row[2],
                        document_name=row[3],
                        added_date=row[4]
                    )
                    for row in rows
                ]

            logger.debug(f"📄 Loaded {len(documents)} document(s) for item {article}")
            return documents

        except Exception as e:
            logger.error(f"❌ Error loading documents for {article}: {e}")
            return []

    def delete(self, doc_id: int) -> bool:
        """
        Удаляет документ товара.

        Args:
            doc_id: ID документа.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM item_documents WHERE id = ?", (doc_id,))

            logger.warning(f"⚠️ Document {doc_id} deleted")
            return True

        except Exception as e:
            logger.error(f"❌ Error deleting document {doc_id}: {e}")
            return False

    def update_name(self, doc_id: int, new_name: str) -> bool:
        """
        Обновляет имя документа.

        Args:
            doc_id: ID документа.
            new_name: Новое имя документа.

        Returns:
            bool: True если обновление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE item_documents
                    SET document_name = ?
                    WHERE id = ?
                """, (new_name, doc_id))

            logger.success(f"✅ Document {doc_id} renamed to '{new_name}'")
            return True

        except Exception as e:
            logger.error(f"❌ Error updating document name: {e}")
            return False

    def count_for_item(self, article: str) -> int:
        """
        Подсчитывает количество документов товара.

        Args:
            article: Артикул товара.

        Returns:
            int: Количество документов.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM item_documents 
                    WHERE item_article = ?
                """, (article,))
                count = cursor.fetchone()[0]

            logger.trace(f"Document count for {article}: {count}")
            return count

        except Exception as e:
            logger.error(f"❌ Error counting documents: {e}")
            return 0

    def migrate_from_items_table(self) -> int:
        """
        Мигрирует существующие документы из поля document в таблицу item_documents.

        Эта функция должна быть вызвана один раз после обновления структуры БД.

        Returns:
            int: Количество мигрированных документов.
        """
        logger.info("🔄 Starting document migration...")

        try:
            migrated_count = 0

            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Получаем все товары с непустым полем document
                cursor.execute("""
                    SELECT article, document 
                    FROM items 
                    WHERE document IS NOT NULL AND document != ''
                """)
                items_with_docs = cursor.fetchall()

                logger.info(f"Found {len(items_with_docs)} items with documents")

                for article, document_path in items_with_docs:
                    # Проверяем, не добавлен ли уже этот документ
                    cursor.execute("""
                        SELECT COUNT(*) FROM item_documents 
                        WHERE item_article = ? AND document_path = ?
                    """, (article, document_path))

                    if cursor.fetchone()[0] == 0:
                        # Добавляем документ в новую таблицу
                        document_name = Path(document_path).name

                        cursor.execute("""
                            INSERT INTO item_documents (item_article, document_path, document_name)
                            VALUES (?, ?, ?)
                        """, (article, document_path, document_name))

                        migrated_count += 1
                        logger.debug(f"Migrated document for {article}: {document_name}")

            logger.success(f"✅ Migration completed: {migrated_count} document(s) migrated")
            return migrated_count

        except Exception as e:
            logger.error(f"❌ Error during document migration: {e}")
            return 0