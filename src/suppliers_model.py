from PySide6.QtCore import QAbstractListModel, Qt, Slot, Signal
from database import DatabaseManager

class SuppliersModel(QAbstractListModel):
    """Модель данных для управления списком поставщиков в Qt/QML-приложении.

    Наследуется от QAbstractListModel. Предоставляет данные о поставщиках для QML-интерфейса,
    включая их идентификатор, имя, компанию, email, телефон и веб-сайт. Поддерживает
    загрузку, добавление, обновление и удаление поставщиков через DatabaseManager.
    Испускает сигнал errorOccurred при возникновении ошибок.
    """

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
        """Инициализация модели поставщиков.

        Args:
            parent (QObject, optional): Родительский объект Qt. По умолчанию None.
        """
        super().__init__(parent)
        self._db = DatabaseManager()  # Менеджер базы данных
        self._suppliers = []         # Список данных поставщиков: [(id, name, company, email, phone, website), ...]
        self.loadSuppliers()

    def roleNames(self):
        """Возвращает сопоставление ролей и их строковых имен для QML.

        Returns:
            dict: Словарь вида {роль: b"имя"}, используемый QML для доступа к данным модели.
        """
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.CompanyRole: b"company",
            self.EmailRole: b"email",
            self.PhoneRole: b"phone",
            self.WebsiteRole: b"website"
        }

    def rowCount(self, parent=None):
        """Возвращает количество строк в модели (число поставщиков).

        Args:
            parent (QModelIndex, optional): Родительский индекс (не используется). По умолчанию None.

        Returns:
            int: Количество поставщиков в списке.
        """
        return len(self._suppliers)

    def data(self, index, role=Qt.DisplayRole):
        """Получение данных для указанного индекса и роли.

        Args:
            index (QModelIndex): Индекс строки в модели.
            role (int): Роль данных (например, IdRole, NameRole). По умолчанию Qt.DisplayRole.

        Returns:
            Значение, соответствующее роли, или None, если индекс или роль недействительны.
        """
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
        """Загружает всех поставщиков из базы данных.

        Сбрасывает модель, загружает данные поставщиков через DatabaseManager
        и обновляет внутренний список _suppliers.
        """
        self.beginResetModel()
        self._suppliers = self._db.load_suppliers()
        self.endResetModel()
        print(f"DEBUG: SuppliersModel loaded {len(self._suppliers)} suppliers")

    @Slot(str, str, str, str, str)
    def addSupplier(self, name, company, email, phone, website):
        """Добавляет нового поставщика в базу данных.

        Args:
            name (str): Имя поставщика.
            company (str): Название компании.
            email (str): Электронная почта.
            phone (str): Телефон.
            website (str): Веб-сайт.

        Вызывает метод добавления в DatabaseManager и перезагружает список поставщиков.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            self._db.add_supplier(name, company, email, phone, website)
            self.loadSuppliers()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка добавления поставщика: {str(e)}")

    @Slot(int, str, str, str, str, str)
    def updateSupplier(self, supplier_id, name, company, email, phone, website):
        """Обновляет данные существующего поставщика.

        Args:
            supplier_id (int): Идентификатор поставщика.
            name (str): Имя поставщика.
            company (str): Название компании.
            email (str): Электронная почта.
            phone (str): Телефон.
            website (str): Веб-сайт.

        Вызывает метод обновления в DatabaseManager и перезагружает список поставщиков.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            self._db.update_supplier(supplier_id, name, company, email, phone, website)
            self.loadSuppliers()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка обновления поставщика: {str(e)}")

    @Slot(int)
    def deleteSupplier(self, supplier_id):
        """Удаляет поставщика из базы данных.

        Args:
            supplier_id (int): Идентификатор поставщика.

        Вызывает метод удаления в DatabaseManager и перезагружает список поставщиков.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            self._db.delete_supplier(supplier_id)
            self.loadSuppliers()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка удаления поставщика: {str(e)}")

    @Slot(int, result="QVariant")
    def get(self, idx):
        """Возвращает данные поставщика по указанному индексу.

        Args:
            idx (int): Индекс строки в модели.

        Returns:
            dict: Словарь с данными поставщика (id, name, company, email, phone, website)
                  или словарь с пустыми значениями, если индекс недействителен.
        """
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
        """Возвращает идентификатор поставщика по его имени.

        Args:
            name (str): Имя поставщика.

        Returns:
            int: Идентификатор поставщика или -1, если поставщик не найден.
        """
        for supplier in self._suppliers:
            if supplier[1] == name:  # supplier[1] = name
                return supplier[0]
        return -1

    @Slot(str, result=int)
    def getSupplierIdByCompany(self, company):
        """Возвращает идентификатор поставщика по названию компании.

        Args:
            company (str): Название компании.

        Returns:
            int: Идентификатор поставщика или -1, если поставщик не найден.
        """
        for supplier in self._suppliers:
            if supplier[2] == company:  # supplier[2] = company
                return supplier[0]
        return -1

    @Slot(str, "QVariantList")
    def bindSuppliersToItem(self, article, supplier_ids):
        """Привязывает список поставщиков к товару.

        Args:
            article (str): Артикул товара.
            supplier_ids (list): Список идентификаторов поставщиков.

        Вызывает метод DatabaseManager для привязки поставщиков к товару.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            db = DatabaseManager()
            db.set_suppliers_for_item(article, supplier_ids)
            print(f"DEBUG: Suppliers {supplier_ids} bound to item {article}")
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка привязки поставщиков: {str(e)}")