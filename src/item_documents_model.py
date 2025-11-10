# item_documents_model.py - Модель данных для управления документами товара

from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal
from database import DatabaseManager


class ItemDocumentsModel(QAbstractListModel):
    """Модель для работы с документами конкретного товара."""

    IdRole = Qt.UserRole + 1
    PathRole = Qt.UserRole + 2
    NameRole = Qt.UserRole + 3
    DateRole = Qt.UserRole + 4

    documentAdded = Signal()
    documentDeleted = Signal()
    errorOccurred = Signal(str)

    def __init__(self, db_manager, parent=None):
        """Инициализирует модель документов.

        Args:
            db_manager: Экземпляр DatabaseManager.
            parent: Родительский объект Qt.
        """
        super().__init__(parent)
        self.db_manager = db_manager
        self.documents = []
        self._current_article = ""

    def rowCount(self, parent=QModelIndex()):
        """Возвращает количество документов."""
        return len(self.documents)

    def data(self, index, role=Qt.DisplayRole):
        """Получает данные для указанного индекса и роли."""
        if not index.isValid() or index.row() >= len(self.documents):
            return None

        doc = self.documents[index.row()]

        if role == self.IdRole:
            return doc[0]
        elif role == self.PathRole:
            return doc[1]
        elif role == self.NameRole:
            return doc[2]
        elif role == self.DateRole:
            return doc[3]

        return None

    def roleNames(self):
        """Возвращает словарь ролей данных для использования в QML."""
        return {
            self.IdRole: b"id",
            self.PathRole: b"path",
            self.NameRole: b"name",
            self.DateRole: b"date"
        }

    @Slot(str)
    def loadDocuments(self, article):
        """Загружает документы для указанного товара.

        Args:
            article (str): Артикул товара.
        """
        try:
            self._current_article = article
            self.beginResetModel()
            self.documents = self.db_manager.get_item_documents(article)
            self.endResetModel()
            print(f"DEBUG: Loaded {len(self.documents)} documents for {article}")
        except Exception as e:
            error_msg = f"Ошибка загрузки документов: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(str, str, result=bool)
    def addDocument(self, document_path, document_name=""):
        """Добавляет новый документ к текущему товару.

        Args:
            document_path (str): Относительный путь к документу.
            document_name (str): Пользовательское имя документа.

        Returns:
            bool: True если добавление успешно, False в случае ошибки.
        """

        print("=" * 60)
        print("addDocument CALLED")
        print(f"document_path: {document_path}")
        print(f"document_name: {document_name}")
        print(f"_current_article: {self._current_article}")
        print("=" * 60)
        try:
            if not self._current_article:
                self.errorOccurred.emit("Товар не выбран")
                return False

            # Если имя не указано, используем имя файла
            if not document_name:
                from pathlib import Path
                document_name = Path(document_path).name

            doc_id = self.db_manager.add_item_document(
                self._current_article,
                document_path,
                document_name
            )

            if doc_id:
                # Перезагружаем список документов
                self.loadDocuments(self._current_article)
                self.documentAdded.emit()
                return True
            else:
                self.errorOccurred.emit("Не удалось добавить документ")
                return False

        except Exception as e:
            error_msg = f"Ошибка добавления документа: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, result=bool)
    def deleteDocument(self, row):
        """Удаляет документ по индексу.

        Args:
            row (int): Индекс документа в списке.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            if row < 0 or row >= len(self.documents):
                self.errorOccurred.emit("Недопустимый индекс документа")
                return False

            doc_id = self.documents[row][0]

            if self.db_manager.delete_item_document(doc_id):
                # Перезагружаем список документов
                self.loadDocuments(self._current_article)
                self.documentDeleted.emit()
                return True
            else:
                self.errorOccurred.emit("Не удалось удалить документ")
                return False

        except Exception as e:
            error_msg = f"Ошибка удаления документа: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, str, result=bool)
    def renameDocument(self, row, new_name):
        """Переименовывает документ.

        Args:
            row (int): Индекс документа в списке.
            new_name (str): Новое имя документа.

        Returns:
            bool: True если переименование успешно, False в случае ошибки.
        """
        try:
            if row < 0 or row >= len(self.documents):
                self.errorOccurred.emit("Недопустимый индекс документа")
                return False

            doc_id = self.documents[row][0]

            if self.db_manager.update_item_document_name(doc_id, new_name):
                # Перезагружаем список документов
                self.loadDocuments(self._current_article)
                return True
            else:
                self.errorOccurred.emit("Не удалось переименовать документ")
                return False

        except Exception as e:
            error_msg = f"Ошибка переименования документа: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, result=str)
    def getDocumentPath(self, row):
        """Получает путь к документу по индексу.

        Args:
            row (int): Индекс документа в списке.

        Returns:
            str: Путь к документу или пустая строка.
        """
        if row < 0 or row >= len(self.documents):
            return ""
        return self.documents[row][1]

    @Slot(int, result=str)
    def getDocumentName(self, row):
        """Получает имя документа по индексу.

        Args:
            row (int): Индекс документа в списке.

        Returns:
            str: Имя документа или пустая строка.
        """
        if row < 0 or row >= len(self.documents):
            return ""
        return self.documents[row][2]

    @Slot()
    def clear(self):
        """Очищает модель."""
        self.beginResetModel()
        self.documents = []
        self._current_article = ""
        self.endResetModel()
        print("Documents cleared")
    @Slot(result=int)
    def count(self):
        """Возвращает количество документов."""
        return len(self.documents)

    @Slot(result=str)
    def getCurrentArticle(self):
        """Возвращает артикул текущего загруженного товара"""
        return self._current_article if self._current_article else ""