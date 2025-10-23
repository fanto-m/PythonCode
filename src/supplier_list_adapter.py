# supplier_list_adapter.py
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex

class SupplierListAdapter(QAbstractListModel):
    def __init__(self, table_model, parent=None):
        super().__init__(parent)
        self._table_model = table_model

    def rowCount(self, parent=QModelIndex()):
        return self._table_model.rowCount()

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        row = index.row()
        # Используем getSupplierRow для получения данных строки
        row_data = self._table_model.getSupplierRow(row)
        if role == Qt.DisplayRole:
            return row_data.get("name", "")
        if role == Qt.UserRole:
            return row_data
        # Можно добавить другие роли по необходимости
        return None

    def roleNames(self):
        return {
            Qt.DisplayRole: b"name",
            Qt.UserRole: b"rowData",
        }
