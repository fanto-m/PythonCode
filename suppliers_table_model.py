# suppliers_table_model.py
from PySide6.QtCore import QAbstractTableModel, Qt, Slot, Signal

from database import DatabaseManager


class SuppliersTableModel(QAbstractTableModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CompanyRole = Qt.UserRole + 3
    EmailRole = Qt.UserRole + 4
    PhoneRole = Qt.UserRole + 5
    WebsiteRole = Qt.UserRole + 6

    errorOccurred = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._db = DatabaseManager()
        self._suppliers = []
        self._checked = set()  # set of int IDs
        self.load()

    # ------------------- Loading -------------------

    @Slot()
    def load(self):
        """Load all suppliers for management mode"""
        self.beginResetModel()
        raw_suppliers = self._db.load_suppliers()
        # Ensure IDs are integers
        self._suppliers = [(int(s[0]),) + s[1:] for s in raw_suppliers]
        self._checked.clear()
        self.endResetModel()

    @Slot(str)
    def loadForArticle(self, article):
        """Load suppliers with pre-checked ones for binding mode"""
        self.beginResetModel()

        # Load all suppliers
        raw_suppliers = self._db.load_suppliers()
        self._suppliers = [(int(s[0]),) + s[1:] for s in raw_suppliers]

        # Load checked IDs for this article
        checked_ids = self._db.get_suppliers_for_item(article) or []

        # Handle different return formats
        if checked_ids and isinstance(checked_ids[0], (tuple, list)):
            self._checked = {int(sid[0]) for sid in checked_ids}
        else:
            self._checked = {int(sid) for sid in checked_ids}

        self.endResetModel()

    # ------------------- Qt Model API -------------------

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.CompanyRole: b"company",
            self.EmailRole: b"email",
            self.PhoneRole: b"phone",
            self.WebsiteRole: b"website",
            Qt.CheckStateRole: b"checkState",
        }

    def columnCount(self, parent=None):
        return 7

    def rowCount(self, parent=None):
        return len(self._suppliers)

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            headers = ["", "ID", "ФИО", "Компания", "Email", "Телефон", "Сайт"]
            return headers[section] if 0 <= section < len(headers) else ""
        return None

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._suppliers):
            return None

        supplier = self._suppliers[index.row()]
        sid, name, company, email, phone, website = supplier

        if role == self.IdRole:
            return sid
        if role == self.NameRole:
            return name
        if role == self.CompanyRole:
            return company
        if role == self.EmailRole:
            return email
        if role == self.PhoneRole:
            return phone
        if role == self.WebsiteRole:
            return website
        if role == Qt.CheckStateRole:
            is_checked = int(sid) in self._checked
            # Return integer value, not enum object
            result = Qt.Checked.value if is_checked else Qt.Unchecked.value
            print(
                f"DEBUG data(): row={index.row()}, col={index.column()}, sid={sid}, checked={is_checked}, returning={result}")
            return result

        return None

    def setData(self, index, value, role=Qt.EditRole):
        if not index.isValid() or role != Qt.CheckStateRole:
            return False

        supplier_id = int(self._suppliers[index.row()][0])

        # value comes as integer from QML
        is_checked = (value == Qt.Checked.value)

        if is_checked:
            self._checked.add(supplier_id)
        else:
            self._checked.discard(supplier_id)

        print(
            f"DEBUG setData(): row={index.row()}, supplier_id={supplier_id}, value={value}, is_checked={is_checked}, _checked={self._checked}")

        # Emit dataChanged for this cell
        self.dataChanged.emit(index, index, [Qt.CheckStateRole])
        return True

    def flags(self, index):
        if not index.isValid():
            return Qt.NoItemFlags
        if index.column() == 0:
            return Qt.ItemIsEnabled | Qt.ItemIsUserCheckable
        return Qt.ItemIsEnabled | Qt.ItemIsSelectable

    # ------------------- QML Slots -------------------

    @Slot(result="QVariantList")
    def getSelectedSupplierIds(self):
        return list(self._checked)

    @Slot(str, "QVariantList")
    def bindSuppliersToItem(self, article, supplier_ids):
        try:
            supplier_ids = [int(sid) for sid in supplier_ids]
            self._db.set_suppliers_for_item(article, supplier_ids)
            self._checked.clear()

            # Update all checkboxes
            if self.rowCount() > 0:
                top_left = self.index(0, 0)
                bottom_right = self.index(self.rowCount() - 1, 0)
                self.dataChanged.emit(top_left, bottom_right, [Qt.CheckStateRole])
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка привязки поставщиков: {str(e)}")

    @Slot(int, result="QVariant")
    def getSupplierRow(self, row):
        if 0 <= row < len(self._suppliers):
            sid, name, company, email, phone, website = self._suppliers[row]
            return {
                "id": sid,
                "name": name,
                "company": company,
                "email": email,
                "phone": phone,
                "website": website,
            }
        return {"id": -1}

    @Slot(str, str, str, str, str)
    def addSupplier(self, name, company, email, phone, website):
        """Add a new supplier"""
        try:
            self._db.add_supplier(name, company, email, phone, website)
            self.load()  # Reload the table
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка добавления поставщика: {str(e)}")

    @Slot(int, str, str, str, str, str)
    def updateSupplier(self, supplier_id, name, company, email, phone, website):
        """Update an existing supplier"""
        try:
            self._db.update_supplier(supplier_id, name, company, email, phone, website)
            self.load()  # Reload the table
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка обновления поставщика: {str(e)}")

    @Slot(int)
    def deleteSupplier(self, supplier_id):
        """Delete a supplier"""
        try:
            self._db.delete_supplier(supplier_id)
            self.load()  # Reload the table
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка удаления поставщика: {str(e)}")