from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal, Property
from database import DatabaseManager
from validators import validate_item


class ItemsModel(QAbstractListModel):
    """Модель для работы с данными товаров в интерфейсе Qt, основанная на QAbstractListModel.

    Поддерживает загрузку, фильтрацию, добавление, обновление и удаление товаров из базы данных.
    """

    ArticleRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    DescriptionRole = Qt.UserRole + 3
    ImagePathRole = Qt.UserRole + 4
    CategoryRole = Qt.UserRole + 5
    PriceRole = Qt.UserRole + 6
    StockRole = Qt.UserRole + 7
    CreatedDateRole = Qt.UserRole + 8
    StatusRole = Qt.UserRole + 9
    UnitRole = Qt.UserRole + 10
    ManufacturerRole = Qt.UserRole + 11
    DocumentCodeRole = Qt.UserRole + 12

    errorOccurred = Signal(str)

    _ROLE_TO_INDEX = {
        ArticleRole: 0,
        NameRole: 1,
        DescriptionRole: 2,
        ImagePathRole: 3,
        CategoryRole: 4,
        PriceRole: 5,
        StockRole: 6,
        CreatedDateRole: 7,
        StatusRole: 8,
        UnitRole: 9,
        ManufacturerRole: 10,
        DocumentCodeRole: 11,
    }

    def __init__(self, db_path="items.db"):
        """Инициализирует экземпляр ItemsModel.

        Args:
            db_path (str): Путь к файлу базы данных SQLite. По умолчанию 'items.db'.
        """
        super().__init__()
        self.db_manager = DatabaseManager(db_path)
        self.items = []
        self._all_items = []  # Store all items for filtering
        self._filter_string = ""
        self._filter_field = "name"
        self.loadData()
        print("DEBUG: Model initialized and data loaded.")

    def loadData(self):
        """Загружает все данные товаров из базы данных.

        Использует DatabaseManager для получения данных и применяет текущий фильтр.
        """
        print("DEBUG: Loading data via DatabaseManager")
        self._all_items = self.db_manager.load_data()
        self._applyFilter()
        print(f"DEBUG: Data loaded. Total items: {len(self._all_items)}, Filtered: {len(self.items)}")

    def _applyFilter(self):
        """Применяет текущий фильтр к списку товаров.

        Фильтрует товары на основе строки фильтра и выбранного поля (например, article, name).
        """
        if not self._filter_string:
            self.items = self._all_items.copy()
            return

        filter_lower = self._filter_string.lower()

        # Map filter field to column index
        field_map = {
            "article": 0,
            "name": 1,
            "description": 2,
            "category": 4,
            "price": 5,
            "stock": 6
        }

        field_index = field_map.get(self._filter_field, 1)  # Default to name

        self.items = [
            item for item in self._all_items
            if filter_lower in str(item[field_index]).lower()
        ]

    def rowCount(self, parent=QModelIndex()):
        """Возвращает количество строк в модели.

        Args:
            parent (QModelIndex): Родительский индекс модели. По умолчанию пустой QModelIndex.

        Returns:
            int: Количество товаров в отфильтрованном списке.
        """
        return len(self.items)

    def data(self, index, role=Qt.DisplayRole):
        """Получает данные для указанного индекса и роли.

        Args:
            index (QModelIndex): Индекс элемента в модели.
            role (int): Роль данных (например, ArticleRole, NameRole). По умолчанию Qt.DisplayRole.

        Returns:
            Значение для указанной роли или None, если индекс или роль недопустимы.
        """
        if not index.isValid() or index.row() >= len(self.items):
            return None

        if role not in self._ROLE_TO_INDEX:
            return None

        item = self.items[index.row()]
        value = item[self._ROLE_TO_INDEX[role]]

        # Special handling for DocumentCodeRole - return empty string for None
        if role == self.DocumentCodeRole:
            return value if value is not None else ""

        return value

    def roleNames(self):
        """Возвращает словарь ролей данных для использования в QML.

        Returns:
            dict: Словарь, сопоставляющий роли данных с их именами в байтовом формате.
        """
        return {
            self.ArticleRole: b"article",
            self.NameRole: b"name",
            self.DescriptionRole: b"description",
            self.ImagePathRole: b"image_path",
            self.CategoryRole: b"category",
            self.PriceRole: b"price",
            self.StockRole: b"stock",
            self.CreatedDateRole: b"created_date",
            self.StatusRole: b"status",
            self.UnitRole: b"unit",
            self.ManufacturerRole: b"manufacturer",
            self.DocumentCodeRole: b"document"
        }

    @Slot(str, str, str, str, int, float, int, str, str, str, str, result=str)
    def addItem(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer,
                document):
        """Добавляет новый товар в базу данных.

        Args:
            article (str): Артикул товара.
            name (str): Название товара.
            description (str): Описание товара.
            image_path (str): Путь к изображению товара.
            category_id (int): ID категории.
            price (float): Цена товара.
            stock (int): Количество на складе.
            status (str): Статус товара.
            unit (str): Единица измерения.
            manufacturer (str): Производитель.
            document (str): Связанный документ.

        Returns:
            str: Пустая строка при успехе, сообщение об ошибке при неудаче.

        Raises:
            Exception: Если произошла ошибка при добавлении товара.
        """
        try:
            print(f"DEBUG: addItem called with: article={article}, name={name}, description={description}, "
                  f"image_path={image_path}, category_id={category_id}, price={price}, stock={stock}, "
                  f"status={status}, unit={unit}, manufacturer={manufacturer}, document={document}")

            # Validate input
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )
            print(f"DEBUG: Validation result: is_valid={is_valid}, error_message={error_message}")
            if not is_valid:
                self.errorOccurred.emit(error_message)
                return error_message

            # Add to database - БЕЗ добавления папок!
            self.db_manager.add_item(
                article, name, description, image_path,
                category_id, price, stock, status, unit, manufacturer, document
            )

            print("DEBUG: Item added successfully. Reloading data...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print(f"DEBUG: Model reset complete. Total items after load: {len(self.items)}")
            print("DEBUG addItem object id:", id(self.items[-1]))
            return ""

        except Exception as e:
            error_message = f"Ошибка добавления товара: {str(e)}"
            print(f"DEBUG: Error in addItem: {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str, result=str)
    def updateItem(self, row, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document):
        """Обновляет существующий товар в базе данных.

        Args:
            row (int): Индекс строки в отфильтрованном списке.
            article (str): Новый артикул товара.
            name (str): Новое название товара.
            description (str): Новое описание товара.
            image_path (str): Новый путь к изображению.
            category_id (int): Новый ID категории.
            price (float): Новая цена.
            stock (int): Новое количество на складе.
            status (str): Новый статус.
            unit (str): Новая единица измерения.
            manufacturer (str): Новый производитель.
            document (str): Новый документ.

        Returns:
            str: Пустая строка при успехе, сообщение об ошибке при неудаче.

        Raises:
            Exception: Если произошла ошибка при обновлении товара.
        """
        try:
            # Validate row index
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                print(f"DEBUG: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Validate input
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )
            if not is_valid:
                print(f"DEBUG: Validation failed in updateItem: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Get old article for updating
            old_article = self.items[row][0]

            # Update in database
            self.db_manager.update_item(
                old_article, article, name, description, image_path,
                category_id, price, stock, status, unit, manufacturer, document
            )

            print("DEBUG: Item updated successfully. Reloading data...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")

            return ""

        except Exception as e:
            error_message = f"Ошибка обновления товара: {str(e)}"
            print(f"DEBUG: Error in updateItem: {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int)
    def deleteItem(self, row):
        """Удаляет товар из базы данных по индексу строки.

        Args:
            row (int): Индекс строки в отфильтрованном списке.

        Raises:
            Exception: Если произошла ошибка при удалении товара.
        """
        try:
            # Validate row index
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                print(f"DEBUG: {error_message}")
                self.errorOccurred.emit(error_message)
                return

            article = self.items[row][0]
            print(f"DEBUG: Deleting item: article = {article}")

            self.db_manager.delete_item(article)

            print("DEBUG: Item deleted successfully. Reloading data...")
            self.beginResetModel()
            self.loadData()
            self.endResetModel()
            print("DEBUG: Model reset complete.")

        except Exception as e:
            error_message = f"Ошибка удаления товара: {str(e)}"
            print(f"DEBUG: Error in deleteItem: {error_message}")
            self.errorOccurred.emit(error_message)

    @Slot(str)
    def setFilterString(self, filter_string):
        """Устанавливает строку для фильтрации товаров.

        Args:
            filter_string (str): Строка для фильтрации.
        """
        if self._filter_string != filter_string:
            self._filter_string = filter_string
            print(f"DEBUG: Filter string set to: '{filter_string}'")
            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot(str)
    def setFilterField(self, field):
        """Устанавливает поле для фильтрации товаров.

        Args:
            field (str): Поле для фильтрации (article, name, description, category, price, stock).
        """
        if self._filter_field != field:
            self._filter_field = field
            print(f"DEBUG: Filter field set to: '{field}'")
            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot()
    def clearFilter(self):
        """Сбрасывает все фильтры, возвращая модель к полному списку товаров.
        """
        self._filter_string = ""
        self._filter_field = "name"
        print("DEBUG: Filters cleared")
        self.beginResetModel()
        self._applyFilter()
        self.endResetModel()

    @Slot(int, result='QVariantMap')
    def get(self, row):
        """Получает данные товара по индексу строки.

        Args:
            row (int): Индекс строки в отфильтрованном списке.

        Returns:
            dict: Словарь с данными товара (index, article, name, description, image_path,
            category, price, stock, created_date, status, unit, manufacturer, document)
            или пустой словарь, если индекс недопустим.
        """
        if row < 0 or row >= len(self.items):
            return {}

        item = self.items[row]
        return {
            "index": row,
            "article": item[0],
            "name": item[1],
            "description": item[2],
            "image_path": item[3],
            "category": item[4],
            "price": item[5],
            "stock": item[6],
            "created_date": item[7],
            "status": item[8] if len(item) > 8 else "в наличии",
            "unit": item[9] if len(item) > 9 else "шт.",
            "manufacturer": item[10] if len(item) > 10 else "",
            "document": item[11] if len(item) > 11 else ""
        }

    @Slot(str, result=bool)
    def deleteItemByArticle(self, article):
        """Удаляет товар по артикулу"""
        try:
            print(f"=== ItemsModel.deleteItemByArticle called ===")
            print(f"article: {article}")

            for i, item in enumerate(self.items):
                if item.get('article') == article:
                    print(f"Found item at index {i}")
                    return self.deleteItem(i)

            print(f"ERROR: Item not found: {article}")
            return False

        except Exception as e:
            print(f"ERROR: {e}")
            import traceback
            traceback.print_exc()
            return False