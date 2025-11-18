# item_documents_model.py - Модель данных для управления документами товара

from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal, Property
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

    # Добавлен сигнал изменения count
    countChanged = Signal()

    def __init__(self, db_manager, parent=None):
        super().__init__(parent)
        self.db_manager = db_manager
        self.documents = []
        self._current_article = ""

    # ----------------------------
    # Qt Property: count
    # ----------------------------
    @Property(int, notify=countChanged)
    def count(self):
        return len(self.documents)

    # ----------------------------

    def rowCount(self, parent=QModelIndex()):
        return len(self.documents)

    def data(self, index, role=Qt.DisplayRole):
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
        return {
            self.IdRole: b"id",
            self.PathRole: b"path",
            self.NameRole: b"name",
            self.DateRole: b"date"
        }

    # ----------------------------
    # Slots
    # ----------------------------

    @Slot(str)
    def loadDocuments(self, article):
        try:
            self._current_article = article

            # 1️⃣ Сначала полностью очищаем модель
            old_docs = len(self.documents)
            self.beginResetModel()
            self.documents = []
            self.endResetModel()

            if old_docs != 0:
                self.countChanged.emit()

            # 2️⃣ Теперь загружаем реальные документы
            docs = self.db_manager.get_item_documents(article)

            self.beginResetModel()
            self.documents = docs
            self.endResetModel()

            self.countChanged.emit()

            print(f"DEBUG: Loaded {len(self.documents)} documents for {article}")

        except Exception as e:
            error_msg = f"Ошибка загрузки документов: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(str, str, result=bool)
    def addDocument(self, document_path, document_name=""):
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

            if not document_name:
                from pathlib import Path
                document_name = Path(document_path).name

            doc_id = self.db_manager.add_item_document(
                self._current_article,
                document_path,
                document_name
            )

            if doc_id:
                self.loadDocuments(self._current_article)

                # Изменение количества — уведомляем
                self.countChanged.emit()

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
        try:
            if row < 0 or row >= len(self.documents):
                self.errorOccurred.emit("Недопустимый индекс документа")
                return False

            doc_id = self.documents[row][0]

            if self.db_manager.delete_item_document(doc_id):
                self.loadDocuments(self._current_article)

                # Изменение количества — уведомляем
                self.countChanged.emit()

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
        try:
            if row < 0 or row >= len(self.documents):
                self.errorOccurred.emit("Недопустимый индекс документа")
                return False

            doc_id = self.documents[row][0]

            if self.db_manager.update_item_document_name(doc_id, new_name):
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
        if row < 0 or row >= len(self.documents):
            return ""
        return self.documents[row][1]

    @Slot(int, result=str)
    def getDocumentName(self, row):
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

        # количество стало 0 — уведомляем
        self.countChanged.emit()

        print("Documents cleared")

    @Slot(result=str)
    def getCurrentArticle(self):
        return self._current_article if self._current_article else ""
