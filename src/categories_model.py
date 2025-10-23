# categories_model.py
from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex, Slot, Signal
from database import DatabaseManager


class CategoriesModel(QAbstractListModel):
    """Модель данных для управления категориями товаров в Qt/QML-приложении.

    Эта модель наследуется от QAbstractListModel и предоставляет интерфейс
    для отображения и редактирования категорий через QML. Каждая категория
    содержит идентификатор, название, префикс SKU и количество цифр в номере SKU.

    Атрибуты ролей:
        IdRole (int): Роль для получения идентификатора категории.
        NameRole (int): Роль для получения названия категории.
        PrefixRole (int): Роль для получения префикса SKU.
        DigitsRole (int): Роль для получения количества цифр в SKU.

    Сигналы:
        errorOccurred (str): Сигнал, испускаемый при возникновении ошибки
            в методах добавления, обновления или удаления категории.
    """

    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    PrefixRole = Qt.UserRole + 3
    DigitsRole = Qt.UserRole + 4

    errorOccurred = Signal(str)

    def __init__(self, parent=None):
        """Инициализирует модель категорий.

        Подключается к менеджеру базы данных и загружает список категорий.

        Args:
            parent (QObject, optional): Родительский объект Qt. По умолчанию None.
        """
        super().__init__(parent)
        self._db = DatabaseManager()
        self._categories = []
        self.loadCategories()

    def roleNames(self):
        """Возвращает сопоставление ролей и их строковых имён для QML.

        Используется QML для доступа к данным модели по именам (например, `model.name`).

        Returns:
            dict: Словарь, сопоставляющий роли (int) с байтовыми строками имён.
        """
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.PrefixRole: b"sku_prefix",
            self.DigitsRole: b"sku_digits"
        }

    def rowCount(self, parent=QModelIndex()):
        """Возвращает количество категорий в модели.

        Args:
            parent (QModelIndex, optional): Родительский индекс (игнорируется,
                так как модель плоская). По умолчанию QModelIndex().

        Returns:
            int: Количество строк (категорий) в модели.
        """
        return len(self._categories)

    def data(self, index, role=Qt.DisplayRole):
        """Возвращает данные для указанного индекса и роли.

        Args:
            index (QModelIndex): Индекс запрашиваемого элемента.
            role (int, optional): Роль данных. По умолчанию Qt.DisplayRole.

        Returns:
            Любое: Значение данных (id, имя, префикс или цифры SKU) или None,
            если индекс недопустим или роль не поддерживается.
        """
        if not index.isValid() or not (0 <= index.row() < len(self._categories)):
            return None
        category = self._categories[index.row()]
        if role == self.IdRole:
            return category[0]
        elif role == self.NameRole:
            return category[1]
        elif role == self.PrefixRole:
            return category[2]
        elif role == self.DigitsRole:
            return category[3]
        return None

    def loadCategories(self):
        """Загружает категории из базы данных и обновляет модель.

        Вызывает beginResetModel() и endResetModel() для корректного
        уведомления представления об изменении данных.
        """
        self.beginResetModel()
        # теперь возвращаем (id, name, prefix, digits)
        self._categories = self._db.load_categories()
        self.endResetModel()
        print("DEBUG: CategoriesModel loaded")

    @Slot(str, str, int)
    def addCategory(self, name, sku_prefix, sku_digits):
        """Добавляет новую категорию в базу данных и обновляет модель.

        Args:
            name (str): Название новой категории.
            sku_prefix (str): Префикс SKU для категории.
            sku_digits (int): Количество цифр в генерируемом SKU.

        При ошибке испускается сигнал errorOccurred с текстом исключения.
        """
        try:
            self._db.add_category(name, sku_prefix, sku_digits)
            self.loadCategories()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(int, str, str, int)
    def updateCategory(self, category_id, new_name, sku_prefix, sku_digits):
        """Обновляет существующую категорию в базе данных.

        Args:
            category_id (int): Идентификатор обновляемой категории.
            new_name (str): Новое название категории.
            sku_prefix (str): Новый префикс SKU.
            sku_digits (int): Новое количество цифр в SKU.

        При ошибке испускается сигнал errorOccurred с текстом исключения.
        """
        try:
            self._db.update_category(category_id, new_name, sku_prefix, sku_digits)
            self.loadCategories()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(int)
    def deleteCategory(self, category_id):
        """Удаляет категорию из базы данных по её идентификатору.

        Args:
            category_id (int): Идентификатор удаляемой категории.

        При ошибке испускается сигнал errorOccurred с текстом исключения.
        """
        try:
            self._db.delete_category(category_id)
            self.loadCategories()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(int, result="QVariant")
    def get(self, idx):
        """Возвращает объект категории по индексу для использования в QML.

        Args:
            idx (int): Индекс категории в модели.

        Returns:
            dict: Словарь с ключами 'id', 'name', 'sku_prefix', 'sku_digits'.
                  Если индекс недопустим, возвращается словарь с пустыми значениями
                  и id = -1.
        """
        if 0 <= idx < len(self._categories):
            cid, name, prefix, digits = self._categories[idx]
            return {
                'id': cid,
                'name': name,
                'sku_prefix': prefix,
                'sku_digits': digits
            }
        return {'id': -1, 'name': '', 'sku_prefix': '', 'sku_digits': 4}

    @Slot(str, result=int)
    def indexOfName(self, name):
        """Возвращает индекс категории по её названию.

        Args:
            name (str): Название категории.

        Returns:
            int: Индекс категории в списке `_categories`, или -1, если не найдена.
        """
        for i, c in enumerate(self._categories):
            if c[1] == name:
                return i
        return -1

    @Slot(str, result=int)
    def getCategoryIdByName(self, name):
        """Возвращает идентификатор категории по её названию.

        Args:
            name (str): Название категории.

        Returns:
            int: Идентификатор категории, или -1, если категория не найдена.
        """
        for category in self._categories:
            if category[1] == name:
                return category[0]
        return -1

    @Slot(int, result=str)
    def generateSkuForCategory(self, category_id):
        """Генерирует следующий уникальный SKU для указанной категории.

        Args:
            category_id (int): Идентификатор категории.

        Returns:
            str: Сгенерированный SKU в формате "PREFIX0001", или пустая строка,
                 если генерация не удалась.
        """
        return self._db.generate_next_sku(category_id) or ""