from PySide6.QtCore import QAbstractTableModel, Qt, Slot, Signal
from database import DatabaseManager

class SuppliersTableModel(QAbstractTableModel):
    """Табличная модель данных для управления списком поставщиков в Qt/QML-приложении.

    Наследуется от QAbstractTableModel. Предоставляет данные о поставщиках для табличного представления
    в QML, включая идентификатор, имя, компанию, email, телефон и веб-сайт. Поддерживает выбор
    поставщиков с помощью флажков, загрузку данных, добавление, обновление, удаление и привязку
    поставщиков к товарам через DatabaseManager. Испускает сигнал errorOccurred при ошибках.
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
        """Инициализация табличной модели поставщиков.

        Args:
            parent (QObject, optional): Родительский объект Qt. По умолчанию None.
        """
        super().__init__(parent)
        self._db = DatabaseManager()  # Менеджер базы данных
        self._suppliers = []         # Список данных поставщиков: [(id, name, company, email, phone, website), ...]
        self._checked = set()        # Множество ID выбранных поставщиков
        self.load()

    # ------------------- Loading -------------------

    @Slot()
    def load(self):
        """Загружает всех поставщиков из базы данных для режима управления.

        Сбрасывает модель, загружает данные поставщиков через DatabaseManager,
        преобразует идентификаторы в целые числа и очищает множество выбранных поставщиков.
        """
        self.beginResetModel()
        raw_suppliers = self._db.load_suppliers()
        self._suppliers = [(int(s[0]),) + s[1:] for s in raw_suppliers]
        self._checked.clear()
        self.endResetModel()

    @Slot(str)
    def loadForArticle(self, article):
        """Загружает поставщиков с предварительно отмеченными для режима привязки к товару.

        Args:
            article (str): Артикул товара.

        Сбрасывает модель, загружает всех поставщиков и отмечает тех, которые уже привязаны к указанному артикулу.
        """
        self.beginResetModel()
        raw_suppliers = self._db.load_suppliers()
        self._suppliers = [(int(s[0]),) + s[1:] for s in raw_suppliers]
        checked_ids = self._db.get_suppliers_for_item(article) or []
        if checked_ids and isinstance(checked_ids[0], (tuple, list)):
            self._checked = {int(sid[0]) for sid in checked_ids}
        else:
            self._checked = {int(sid) for sid in checked_ids}
        self.endResetModel()

    # ------------------- Qt Model API -------------------

    def roleNames(self):
        """Возвращает сопоставление ролей и их строковых имен для QML.

        Returns:
            dict: Словарь вида {роль: b"имя"}, включая CheckStateRole для флажков.
        """
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
        """Возвращает количество столбцов в таблице.

        Args:
            parent (QModelIndex, optional): Родительский индекс (не используется). По умолчанию None.

        Returns:
            int: Количество столбцов (7: флажок, ID, ФИО, компания, email, телефон, сайт).
        """
        return 7

    def rowCount(self, parent=None):
        """Возвращает количество строк в модели (число поставщиков).

        Args:
            parent (QModelIndex, optional): Родительский индекс (не используется). По умолчанию None.

        Returns:
            int: Количество поставщиков в списке.
        """
        return len(self._suppliers)

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        """Возвращает заголовки столбцов для табличного представления.

        Args:
            section (int): Индекс столбца.
            orientation (Qt.Orientation): Ориентация (горизонтальная или вертикальная).
            role (int): Роль данных. По умолчанию Qt.DisplayRole.

        Returns:
            str: Заголовок столбца или None, если роль или индекс недействительны.
        """
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            headers = ["", "ID", "ФИО", "Компания", "Email", "Телефон", "Сайт"]
            return headers[section] if 0 <= section < len(headers) else ""
        return None

    def data(self, index, role=Qt.DisplayRole):
        """Получение данных для указанного индекса и роли.

        Args:
            index (QModelIndex): Индекс строки и столбца в модели.
            role (int): Роль данных (например, IdRole, NameRole, CheckStateRole). По умолчанию Qt.DisplayRole.

        Returns:
            Значение, соответствующее роли, или None, если индекс недействителен.
        """
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
            return Qt.Checked.value if is_checked else Qt.Unchecked.value
        return None

    def setData(self, index, value, role=Qt.EditRole):
        """Устанавливает данные для указанного индекса и роли.

        Args:
            index (QModelIndex): Индекс строки и столбца в модели.
            value: Значение для установки (ожидается integer для CheckStateRole).
            role (int): Роль данных. По умолчанию Qt.EditRole.

        Returns:
            bool: True, если данные успешно установлены, иначе False.

        Поддерживает только изменение состояния флажка (CheckStateRole).
        """
        if not index.isValid() or role != Qt.CheckStateRole:
            return False

        supplier_id = int(self._suppliers[index.row()][0])
        is_checked = (value == Qt.Checked.value)

        if is_checked:
            self._checked.add(supplier_id)
        else:
            self._checked.discard(supplier_id)

        print(
            f"DEBUG setData(): row={index.row()}, supplier_id={supplier_id}, value={value}, is_checked={is_checked}, _checked={self._checked}")

        self.dataChanged.emit(index, index, [Qt.CheckStateRole])
        return True

    def flags(self, index):
        """Возвращает флаги для указанного индекса.

        Args:
            index (QModelIndex): Индекс строки и столбца в модели.

        Returns:
            Qt.ItemFlags: Флаги, определяющие поведение элемента (выбираемый, включаемый, с флажком для первого столбца).
        """
        if not index.isValid():
            return Qt.NoItemFlags
        if index.column() == 0:
            return Qt.ItemIsEnabled | Qt.ItemIsUserCheckable
        return Qt.ItemIsEnabled | Qt.ItemIsSelectable

    # ------------------- QML Slots -------------------

    @Slot(result="QVariantList")
    def getSelectedSupplierIds(self):
        """Возвращает список идентификаторов выбранных поставщиков.

        Returns:
            list: Список ID поставщиков, отмеченных флажками.
        """
        return list(self._checked)

    @Slot(str, "QVariantList")
    def bindSuppliersToItem(self, article, supplier_ids):
        """Привязывает список поставщиков к товару.

        Args:
            article (str): Артикул товара.
            supplier_ids (list): Список идентификаторов поставщиков.

        Вызывает метод DatabaseManager для привязки и обновляет состояние флажков.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            supplier_ids = [int(sid) for sid in supplier_ids]
            self._db.set_suppliers_for_item(article, supplier_ids)
            self._checked.clear()
            if self.rowCount() > 0:
                top_left = self.index(0, 0)
                bottom_right = self.index(self.rowCount() - 1, 0)
                self.dataChanged.emit(top_left, bottom_right, [Qt.CheckStateRole])
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка привязки поставщиков: {str(e)}")

    @Slot(int, result="QVariant")
    def getSupplierRow(self, row):
        """Возвращает данные поставщика по указанной строке.

        Args:
            row (int): Индекс строки в модели.

        Returns:
            dict: Словарь с данными поставщика (id, name, company, email, phone, website)
                  или словарь с id=-1, если строка недействительна.
        """
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
        """Добавляет нового поставщика в базу данных.

        Args:
            name (str): Имя поставщика.
            company (str): Название компании.
            email (str): Электронная почта.
            phone (str): Телефон.
            website (str): Веб-сайт.

        Вызывает метод DatabaseManager и перезагружает таблицу.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            self._db.add_supplier(name, company, email, phone, website)
            self.load()
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

        Вызывает метод DatabaseManager и перезагружает таблицу.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            self._db.update_supplier(supplier_id, name, company, email, phone, website)
            self.load()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка обновления поставщика: {str(e)}")

    @Slot(int)
    def deleteSupplier(self, supplier_id):
        """Удаляет поставщика из базы данных.

        Args:
            supplier_id (int): Идентификатор поставщика.

        Вызывает метод DatabaseManager и перезагружает таблицу.
        При ошибке испускает сигнал errorOccurred.
        """
        try:
            self._db.delete_supplier(supplier_id)
            self.load()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка удаления поставщика: {str(e)}")