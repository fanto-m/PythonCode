# suppliers_model.py
from PySide6.QtCore import QAbstractListModel, Qt, Slot, Signal

from database import DatabaseManager


class SuppliersModel(QAbstractListModel):
    # Роли для QML
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CompanyRole = Qt.UserRole + 3
    EmailRole = Qt.UserRole + 4
    PhoneRole = Qt.UserRole + 5
    WebsiteRole = Qt.UserRole + 6

    # Сигнал для ошибок
    errorOccurred = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._db = DatabaseManager()
        self._suppliers = []
        self.loadSuppliers()

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
        if not index.isValid() or not (0 <= index.row() < len(self._suppliers)):
            return None
        supplier = self._suppliers[index.row()]
        return supplier[{
            self.IdRole: 0,
            self.NameRole: 1,
            self.CompanyRole: 2,
            self.EmailRole: 3,
            self.PhoneRole: 4,
            self.WebsiteRole: 5
        }.get(role, -1)]

    def loadSuppliers(self):
        """Загружает всех поставщиков из БД."""
        self.beginResetModel()
        self._suppliers = self._db.load_suppliers()
        self.endResetModel()
        print(f"DEBUG: SuppliersModel loaded {len(self._suppliers)} suppliers")

    # ------------------- Слоты для QML -------------------


    @Slot(str, str, str, str, str)
    def addSupplier(self, name, company, email, phone, website):
        """Добавляет нового поставщика."""
        try:
            self._db.add_supplier(name, company, email, phone, website)
            self.loadSuppliers()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка добавления поставщика: {str(e)}")

    @Slot(int, str, str, str, str, str)
    def updateSupplier(self, supplier_id, name, company, email, phone, website):
        """Обновляет данные поставщика."""
        try:
            self._db.update_supplier(supplier_id, name, company, email, phone, website)
            self.loadSuppliers()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка обновления поставщика: {str(e)}")

    @Slot(int)
    def deleteSupplier(self, supplier_id):
        """Удаляет поставщика."""
        try:
            self._db.delete_supplier(supplier_id)
            self.loadSuppliers()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка удаления поставщика: {str(e)}")

    # ------------------- Вспомогательные методы для QML -------------------

    @Slot(int, result="QVariant")
    def get(self, idx):
        """Возвращает объект поставщика по индексу."""
        if 0 <= idx < len(self._suppliers):
            sid, name, company, email, phone, website = self._suppliers[idx]
            return {
                "id": sid,
                "name": name,
                "company": company,
                "email": email,
                "phone": phone,
                "website": website
            }
        return {"id": -1, "name": "", "company": "", "email": "", "phone": "", "website": ""}

    @Slot(str, result=int)
    def getSupplierIdByName(self, name):
        """Возвращает ID поставщика по имени (name)."""
        for supplier in self._suppliers:
            if supplier[1] == name:  # supplier[1] = name
                return supplier[0]
        return -1

    @Slot(str, result=int)
    def getSupplierIdByCompany(self, company):
        """Возвращает ID поставщика по названию компании."""
        for supplier in self._suppliers:
            if supplier[2] == company:  # supplier[2] = company
                return supplier[0]
        return -1

    @Slot(str, "QVariantList")
    def bindSuppliersToItem(self, article, supplier_ids):
        """Привязать поставщиков к товару."""
        try:
            db = DatabaseManager()
            db.set_suppliers_for_item(article, supplier_ids)
            print(f"DEBUG: Suppliers {supplier_ids} bound to item {article}")
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка привязки поставщиков: {str(e)}")