# item_suppliers_model.py
from PySide6.QtCore import QAbstractListModel, Qt, Slot, Signal
from database import DatabaseManager


class ItemSuppliersModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CompanyRole = Qt.UserRole + 3
    EmailRole = Qt.UserRole + 4
    PhoneRole = Qt.UserRole + 5
    WebsiteRole = Qt.UserRole + 6

    def __init__(self, article=""):
        super().__init__()
        self._db = DatabaseManager()
        self._article = article
        self._suppliers = []  # Full supplier data: [(id, name, company, email, phone, website), ...]
        if article:
            self.load()

    def load(self):
        """Load full supplier data for items bound to current article"""
        self.beginResetModel()

        # Get supplier IDs bound to this article
        supplier_ids = self._db.get_suppliers_for_item(self._article) or []

        # Handle different return formats
        if supplier_ids and isinstance(supplier_ids[0], (tuple, list)):
            supplier_ids = [int(sid[0]) for sid in supplier_ids]
        else:
            supplier_ids = [int(sid) for sid in supplier_ids]

        # Load full data for each supplier ID
        self._suppliers = []
        if supplier_ids:
            all_suppliers = self._db.load_suppliers()
            for supplier in all_suppliers:
                if int(supplier[0]) in supplier_ids:
                    self._suppliers.append(supplier)

        self.endResetModel()

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.CompanyRole: b"company",
            self.EmailRole: b"email",
            self.PhoneRole: b"phone",
            self.WebsiteRole: b"website"
        }

    def rowCount(self, parent=None):
        return len(self._suppliers)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._suppliers):
            return None

        supplier = self._suppliers[index.row()]

        role_map = {
            self.IdRole: 0,
            self.NameRole: 1,
            self.CompanyRole: 2,
            self.EmailRole: 3,
            self.PhoneRole: 4,
            self.WebsiteRole: 5
        }

        col_index = role_map.get(role, -1)
        if col_index >= 0 and col_index < len(supplier):
            return supplier[col_index]
        return None

    @Slot(str)
    def setArticle(self, article):
        """Set article and reload suppliers for that article"""
        self._article = article
        self.load()

    @Slot(int, result="QVariant")
    def get(self, index):
        """Get supplier data at index as a dictionary"""
        if 0 <= index < len(self._suppliers):
            supplier = self._suppliers[index]
            return {
                "id": supplier[0],
                "name": supplier[1],
                "company": supplier[2],
                "email": supplier[3],
                "phone": supplier[4],
                "website": supplier[5]
            }
        return {"id": -1, "name": "", "company": "", "email": "", "phone": "", "website": ""}