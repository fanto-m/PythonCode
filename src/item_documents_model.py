"""Модель для управления документами товара с Repository Pattern"""

from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal
from pathlib import Path
from loguru import logger

from repositories.documents_repository import DocumentsRepository
from models.dto import Document


class ItemDocumentsModel(QAbstractListModel):
    """
    Модель для работы с документами конкретного товара.

    Использует Repository Pattern для работы с данными.
    Предоставляет интерфейс для отображения и управления документами в QML.
    """

    # Роли данных для QML
    IdRole = Qt.UserRole + 1
    PathRole = Qt.UserRole + 2
    NameRole = Qt.UserRole + 3
    DateRole = Qt.UserRole + 4

    # Сигналы
    documentAdded = Signal()
    documentDeleted = Signal()
    errorOccurred = Signal(str)
    documentsLoaded = Signal(int)  # Количество загруженных документов

    def __init__(self, documents_repository: DocumentsRepository, parent=None):
        """
        Инициализирует модель документов.

        Args:
            documents_repository: Репозиторий для работы с документами.
            parent: Родительский объект Qt (опционально).
        """
        super().__init__(parent)

        self.repository = documents_repository
        self.documents = []  # Список DTO объектов Document
        self._current_article = ""

        logger.debug("ItemDocumentsModel initialized")

    def roleNames(self):
        """
        Возвращает словарь ролей данных для QML.

        Returns:
            dict: Словарь ролей и их имен в байтовом формате.
        """
        return {
            self.IdRole: b"id",
            self.PathRole: b"path",
            self.NameRole: b"name",
            self.DateRole: b"date"
        }

    def rowCount(self, parent=QModelIndex()):
        """
        Возвращает количество документов.

        Args:
            parent: Родительский индекс модели.

        Returns:
            int: Количество документов.
        """
        return len(self.documents)

    def data(self, index, role=Qt.DisplayRole):
        """
        Получает данные для указанного индекса и роли.

        Args:
            index: Индекс документа.
            role: Роль данных.

        Returns:
            Значение данных или None.
        """
        if not index.isValid() or index.row() >= len(self.documents):
            return None

        doc = self.documents[index.row()]

        if role == self.IdRole:
            return doc.id
        elif role == self.PathRole:
            return doc.document_path
        elif role == self.NameRole:
            return doc.document_name
        elif role == self.DateRole:
            return doc.added_date

        return None

    # ==================== Data Loading ====================

    @Slot(str)
    def loadDocuments(self, article: str):
        """
        Загружает документы для указанного товара.

        Args:
            article: Артикул товара.
        """
        try:
            logger.info(f"Loading documents for item: {article}")

            self._current_article = article
            self.beginResetModel()

            # ✅ ПРАВИЛЬНЫЙ метод репозитория
            self.documents = self.repository.get_for_item(article)

            self.endResetModel()

            logger.success(f"✅ Loaded {len(self.documents)} documents for {article}")
            self.documentsLoaded.emit(len(self.documents))

        except Exception as e:
            error_msg = f"Ошибка загрузки документов: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    # ==================== CRUD Operations ====================

    @Slot(str, str, result=bool)
    def addDocument(self, document_path: str, document_name: str = "") -> bool:
        """
        Добавляет новый документ к текущему товару.

        Args:
            document_path: Относительный путь к документу.
            document_name: Пользовательское имя документа.

        Returns:
            bool: True если добавление успешно, False в случае ошибки.
        """
        logger.info(
            f"Adding document: path='{document_path}', "
            f"name='{document_name}', article='{self._current_article}'"
        )

        try:
            # Валидация
            if not self._current_article:
                error_msg = "Товар не выбран"
                logger.warning(f"⚠️ {error_msg}")
                self.errorOccurred.emit(error_msg)
                return False

            # Если имя не указано, используем имя файла
            if not document_name:
                document_name = Path(document_path).name
                logger.debug(f"Using filename as name: {document_name}")

            # ✅ ПРАВИЛЬНЫЙ вызов метода репозитория
            # add() принимает отдельные параметры, НЕ DTO!
            doc_id = self.repository.add(
                self._current_article,
                document_path,
                document_name
            )

            if doc_id:
                logger.success(f"✅ Document added with ID: {doc_id}")

                # Перезагружаем список документов
                self.loadDocuments(self._current_article)
                self.documentAdded.emit()
                return True
            else:
                error_msg = "Не удалось добавить документ"
                logger.error(f"❌ {error_msg}")
                self.errorOccurred.emit(error_msg)
                return False

        except Exception as e:
            error_msg = f"Ошибка добавления документа: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, result=bool)
    def deleteDocument(self, row: int) -> bool:
        """
        Удаляет документ по индексу.

        Args:
            row: Индекс документа в списке.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            # Валидация
            if row < 0 or row >= len(self.documents):
                error_msg = "Недопустимый индекс документа"
                logger.warning(f"⚠️ {error_msg}: {row}")
                self.errorOccurred.emit(error_msg)
                return False

            doc = self.documents[row]
            logger.info(f"Deleting document: ID={doc.id}, name='{doc.document_name}'")

            # ✅ ПРАВИЛЬНЫЙ метод репозитория
            success = self.repository.delete(doc.id)

            if success:
                logger.success(f"✅ Document {doc.id} deleted")

                # Перезагружаем список документов
                self.loadDocuments(self._current_article)
                self.documentDeleted.emit()
                return True
            else:
                error_msg = "Не удалось удалить документ"
                logger.error(f"❌ {error_msg}")
                self.errorOccurred.emit(error_msg)
                return False

        except Exception as e:
            error_msg = f"Ошибка удаления документа: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, str, result=bool)
    def renameDocument(self, row: int, new_name: str) -> bool:
        """
        Переименовывает документ.

        Args:
            row: Индекс документа в списке.
            new_name: Новое имя документа.

        Returns:
            bool: True если переименование успешно, False в случае ошибки.
        """
        try:
            # Валидация
            if row < 0 or row >= len(self.documents):
                error_msg = "Недопустимый индекс документа"
                logger.warning(f"⚠️ {error_msg}: {row}")
                self.errorOccurred.emit(error_msg)
                return False

            if not new_name or not new_name.strip():
                error_msg = "Имя документа не может быть пустым"
                logger.warning(f"⚠️ {error_msg}")
                self.errorOccurred.emit(error_msg)
                return False

            doc = self.documents[row]
            logger.info(
                f"Renaming document {doc.id}: "
                f"'{doc.document_name}' → '{new_name}'"
            )

            # ✅ ПРАВИЛЬНЫЙ метод репозитория: update_name, НЕ update_document_name
            success = self.repository.update_name(doc.id, new_name.strip())

            if success:
                logger.success(f"✅ Document {doc.id} renamed")

                # Перезагружаем список документов
                self.loadDocuments(self._current_article)
                return True
            else:
                error_msg = "Не удалось переименовать документ"
                logger.error(f"❌ {error_msg}")
                self.errorOccurred.emit(error_msg)
                return False

        except Exception as e:
            error_msg = f"Ошибка переименования документа: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    # ==================== Utility Methods ====================

    @Slot(int, result=str)
    def getDocumentPath(self, row: int) -> str:
        """
        Получает путь к документу по индексу.

        Args:
            row: Индекс документа в списке.

        Returns:
            str: Путь к документу или пустая строка.
        """
        if row < 0 or row >= len(self.documents):
            logger.warning(f"⚠️ Invalid document index: {row}")
            return ""

        path = self.documents[row].document_path
        logger.trace(f"Retrieved document path for index {row}: {path}")
        return path

    @Slot(int, result=str)
    def getDocumentName(self, row: int) -> str:
        """
        Получает имя документа по индексу.

        Args:
            row: Индекс документа в списке.

        Returns:
            str: Имя документа или пустая строка.
        """
        if row < 0 or row >= len(self.documents):
            logger.warning(f"⚠️ Invalid document index: {row}")
            return ""

        name = self.documents[row].document_name
        logger.trace(f"Retrieved document name for index {row}: {name}")
        return name

    @Slot()
    def clear(self):
        """Очищает модель."""
        logger.info("Clearing documents model")

        self.beginResetModel()
        self.documents = []
        self._current_article = ""
        self.endResetModel()

        logger.debug("Documents model cleared")

    @Slot(result=int)
    def count(self) -> int:
        """
        Возвращает количество документов.

        Returns:
            int: Количество документов.
        """
        return len(self.documents)

    @Slot(result=str)
    def getCurrentArticle(self) -> str:
        """
        Возвращает артикул текущего загруженного товара.

        Returns:
            str: Артикул товара или пустая строка.
        """
        return self._current_article if self._current_article else ""

    @Slot(result=bool)
    def hasDocuments(self) -> bool:
        """
        Проверяет наличие документов у текущего товара.

        Returns:
            bool: True если есть документы, иначе False.
        """
        return len(self.documents) > 0

    @Slot(str, result=int)
    def countDocumentsForItem(self, article: str) -> int:
        """
        Возвращает количество документов для указанного товара.

        Args:
            article: Артикул товара.

        Returns:
            int: Количество документов.
        """
        try:
            # ✅ ПРАВИЛЬНЫЙ метод репозитория
            count = self.repository.count_for_item(article)
            logger.trace(f"Document count for {article}: {count}")
            return count
        except Exception as e:
            logger.error(f"❌ Error counting documents: {e}")
            return 0