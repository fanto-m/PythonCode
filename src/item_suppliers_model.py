# item_suppliers_model.py
from PySide6.QtCore import QAbstractListModel, Qt, Slot, Signal
from database import DatabaseManager

class ItemSuppliersModel(QAbstractListModel):
    """Модель данных для управления списком поставщиков, связанных с конкретным товаром.

    Наследуется от QAbstractListModel. Предоставляет данные о поставщиках для QML-интерфейса,
    включая их идентификатор, имя, компанию, email, телефон и веб-сайт. Поддерживает загрузку
    данных из базы данных через DatabaseManager и обновление данных при изменении артикула товара.
    """

    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CompanyRole = Qt.UserRole + 3
    EmailRole = Qt.UserRole + 4
    PhoneRole = Qt.UserRole + 5
    WebsiteRole = Qt.UserRole + 6

    def __init__(self, article=""):
        """Инициализация модели поставщиков.

        Args:
            article (str, optional): Артикул товара, для которого загружаются поставщики.
                                    По умолчанию пустая строка.
        """
        super().__init__()
        self._db = DatabaseManager()  # Менеджер базы данных
        self._article = article       # Артикул текущего товара
        self._suppliers = []          # Список данных поставщиков: [(id, name, company, email, phone, website), ...]
        if article:
            self.load()

    def load(self):
        """Загрузка данных поставщиков для текущего артикула.

        Сбрасывает модель, получает идентификаторы поставщиков для текущего артикула
        из базы данных и загружает полные данные для соответствующих поставщиков.
        """
        self.beginResetModel()

        # Получение идентификаторов поставщиков для текущего артикула
        supplier_ids = self._db.get_suppliers_for_item(self._article) or []

        # Обработка различных форматов возвращаемых данных
        if supplier_ids and isinstance(supplier_ids[0], (tuple, list)):
            supplier_ids = [int(sid[0]) for sid in supplier_ids]
        else:
            supplier_ids = [int(sid) for sid in supplier_ids]

        # Загрузка полных данных для каждого идентификатора поставщика
        self._suppliers = []
        if supplier_ids:
            all_suppliers = self._db.load_suppliers()
            for supplier in all_suppliers:
                if int(supplier[0]) in supplier_ids:
                    self._suppliers.append(supplier)

        self.endResetModel()

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
            parent: Родительский индекс (не используется, по умолчанию None).

        Returns:
            int: Количество поставщиков в списке.
        """
        return len(self._suppliers)

    def data(self, index, role=Qt.DisplayRole):
        """Получение данных для указанного индекса и роли.

        Args:
            index (QModelIndex): Индекс строки в модели.
            role (int): Роль данных (например, IdRole, NameRole).

        Returns:
            Значение, соответствующее роли, или None, если индекс или роль недействительны.
        """
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
        """Устанавливает новый артикул и перезагружает данные поставщиков.

        Args:
            article (str): Артикул товара, для которого нужно загрузить поставщиков.

        Вызывает метод load() для обновления списка поставщиков.
        """
        self._article = article
        self.load()

    @Slot(int, result="QVariant")
    def get(self, index):
        """Получение данных поставщика по индексу в виде словаря.

        Args:
            index (int): Индекс строки в модели.

        Returns:
            dict: Словарь с данными поставщика (id, name, company, email, phone, website)
                  или словарь с пустыми значениями, если индекс недействителен.
        """
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