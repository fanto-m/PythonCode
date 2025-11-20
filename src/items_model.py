"""Модель товаров для Qt/QML интерфейса с Repository Pattern"""

from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal
from loguru import logger

from repositories.items_repository import ItemsRepository
from models.dto import Item
from validators import validate_item


class ItemsModel(QAbstractListModel):
    """
    Модель для работы с данными товаров в интерфейсе Qt/QML.

    Использует Repository Pattern для работы с данными.
    Поддерживает загрузку, фильтрацию, добавление, обновление и удаление товаров.

    Attributes:
        repository: ItemsRepository для работы с базой данных
        items: Отфильтрованный список товаров для отображения
    """

    # Роли данных для QML
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

    # Сигналы
    errorOccurred = Signal(str)
    itemsLoaded = Signal(int)  # Новый сигнал - количество загруженных товаров

    # Маппинг ролей на индексы в кортеже
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

    def __init__(self, items_repository: ItemsRepository):
        """
        Инициализирует модель товаров.

        Args:
            items_repository: Репозиторий для работы с товарами.
        """
        super().__init__()

        self.repository = items_repository
        self.items = []
        self._all_items = []  # Полный список для фильтрации
        self._filter_string = ""
        self._filter_field = "name"

        logger.debug("ItemsModel initialized")
        self.loadData()

    def loadData(self):
        """
        Загружает все данные товаров из репозитория.

        Применяет текущий фильтр к загруженным данным.
        """
        logger.info("Loading items data...")

        try:
            self._all_items = self.repository.get_all()
            self._applyFilter()

            logger.success(
                f"✅ Loaded {len(self._all_items)} items, "
                f"filtered to {len(self.items)}"
            )

            self.itemsLoaded.emit(len(self.items))

        except Exception as e:
            logger.exception("❌ Failed to load items")
            self.errorOccurred.emit(f"Ошибка загрузки: {str(e)}")

    def _applyFilter(self):
        """
        Применяет текущий фильтр к списку товаров.

        Фильтрует товары на основе строки фильтра и выбранного поля.
        """
        if not self._filter_string:
            self.items = self._all_items.copy()
            logger.debug("No filter applied, showing all items")
            return

        filter_lower = self._filter_string.lower()

        # Маппинг поля фильтра на индекс колонки
        field_map = {
            "article": 0,
            "name": 1,
            "description": 2,
            "category": 4,
            "manufacturer": 10,
        }

        field_index = field_map.get(self._filter_field, 1)  # По умолчанию name

        self.items = [
            item for item in self._all_items
            if filter_lower in str(item[field_index]).lower()
        ]

        logger.debug(
            f"🔍 Filter applied: '{self._filter_string}' in '{self._filter_field}' "
            f"-> {len(self.items)} results"
        )

    # ==================== Qt Model Methods ====================

    def rowCount(self, parent=QModelIndex()):
        """
        Возвращает количество строк в модели.

        Args:
            parent: Родительский индекс модели.

        Returns:
            int: Количество товаров в отфильтрованном списке.
        """
        return len(self.items)

    def data(self, index, role=Qt.DisplayRole):
        """
        Получает данные для указанного индекса и роли.

        Args:
            index: Индекс элемента в модели.
            role: Роль данных (ArticleRole, NameRole и т.д.).

        Returns:
            Значение для указанной роли или None.
        """
        if not index.isValid() or index.row() >= len(self.items):
            return None

        if role not in self._ROLE_TO_INDEX:
            return None

        item = self.items[index.row()]
        value = item[self._ROLE_TO_INDEX[role]]

        # Специальная обработка для DocumentCodeRole
        if role == self.DocumentCodeRole:
            return value if value is not None else ""

        return value

    def roleNames(self):
        """
        Возвращает словарь ролей данных для использования в QML.

        Returns:
            dict: Словарь ролей и их имен в байтовом формате.
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

    # ==================== CRUD Operations ====================

    @Slot(str, str, str, str, int, float, int, str, str, str, str, result=str)
    def addItem(
            self,
            article: str,
            name: str,
            description: str,
            image_path: str,
            category_id: int,
            price: float,
            stock: int,
            status: str,
            unit: str,
            manufacturer: str,
            document: str
    ) -> str:
        """
        Добавляет новый товар в базу данных.

        Args:
            article: Артикул товара.
            name: Название товара.
            description: Описание товара.
            image_path: Путь к изображению товара.
            category_id: ID категории.
            price: Цена товара.
            stock: Количество на складе.
            status: Статус товара.
            unit: Единица измерения.
            manufacturer: Производитель.
            document: Связанный документ.

        Returns:
            str: Пустая строка при успехе, сообщение об ошибке при неудаче.
        """
        try:
            logger.info(
                f"Adding item: article={article}, name={name}, "
                f"category_id={category_id}, price={price}, stock={stock}"
            )

            # Валидация входных данных
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )

            if not is_valid:
                logger.warning(f"⚠️ Validation failed: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Создаем DTO объект
            item = Item(
                article=article,
                name=name,
                description=description,
                image_path=image_path,
                category_id=category_id,
                price=price,
                stock=stock,
                status=status or 'в наличии',
                unit=unit or 'шт.',
                manufacturer=manufacturer or '',
                document=document or ''
            )

            # Добавляем в базу данных через репозиторий
            self.repository.add(item)

            logger.success(f"✅ Item added: {article} - {name}")

            # Обновляем модель
            self.beginResetModel()
            self.loadData()
            self.endResetModel()

            logger.debug(f"Model refreshed. Total items: {len(self.items)}")
            return ""

        except Exception as e:
            error_message = f"Ошибка добавления товара: {str(e)}"
            logger.error(f"❌ {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str, result=str)
    def updateItem(
            self,
            row: int,
            article: str,
            name: str,
            description: str,
            image_path: str,
            category_id: int,
            price: float,
            stock: int,
            status: str,
            unit: str,
            manufacturer: str,
            document: str
    ) -> str:
        """
        Обновляет существующий товар в базе данных.

        Args:
            row: Индекс строки в отфильтрованном списке.
            article: Новый артикул товара.
            name: Новое название товара.
            description: Новое описание товара.
            image_path: Новый путь к изображению.
            category_id: Новый ID категории.
            price: Новая цена.
            stock: Новое количество на складе.
            status: Новый статус.
            unit: Новая единица измерения.
            manufacturer: Новый производитель.
            document: Новый документ.

        Returns:
            str: Пустая строка при успехе, сообщение об ошибке при неудаче.
        """
        try:
            # Проверка индекса строки
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                logger.warning(f"⚠️ {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Получаем старый артикул
            old_article = self.items[row][0]

            logger.info(
                f"Updating item: {old_article} -> {article}, "
                f"name={name}, price={price}"
            )

            # Валидация входных данных
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )

            if not is_valid:
                logger.warning(f"⚠️ Validation failed: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Создаем DTO объект с новыми данными
            item = Item(
                article=article,
                name=name,
                description=description,
                image_path=image_path,
                category_id=category_id,
                price=price,
                stock=stock,
                status=status,
                unit=unit,
                manufacturer=manufacturer,
                document=document
            )

            # Обновляем в базе данных через репозиторий
            self.repository.update(old_article, item)

            logger.success(f"✅ Item updated: {old_article} -> {article}")

            # Обновляем модель
            self.beginResetModel()
            self.loadData()
            self.endResetModel()

            logger.debug("Model refreshed after update")
            return ""

        except Exception as e:
            error_message = f"Ошибка обновления товара: {str(e)}"
            logger.error(f"❌ {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int)
    def deleteItem(self, row: int):
        """
        Удаляет товар из базы данных по индексу строки.

        Args:
            row: Индекс строки в отфильтрованном списке.
        """
        try:
            # Проверка индекса строки
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                logger.warning(f"⚠️ {error_message}")
                self.errorOccurred.emit(error_message)
                return

            article = self.items[row][0]
            logger.info(f"Deleting item: {article}")

            # Удаляем через репозиторий
            self.repository.delete(article)

            logger.success(f"✅ Item deleted: {article}")

            # Обновляем модель
            self.beginResetModel()
            self.loadData()
            self.endResetModel()

            logger.debug("Model refreshed after deletion")

        except Exception as e:
            error_message = f"Ошибка удаления товара: {str(e)}"
            logger.error(f"❌ {error_message}")
            self.errorOccurred.emit(error_message)

    @Slot(str, result=bool)
    def deleteItemByArticle(self, article: str) -> bool:
        """
        Удаляет товар по артикулу.

        Args:
            article: Артикул товара для удаления.

        Returns:
            bool: True при успехе, False при ошибке.
        """
        try:
            logger.info(f"Deleting item by article: {article}")

            # Ищем товар в текущем списке
            for i, item in enumerate(self.items):
                if item[0] == article:  # item[0] это article
                    logger.debug(f"Found item at index {i}")
                    self.deleteItem(i)
                    return True

            logger.warning(f"⚠️ Item not found: {article}")
            self.errorOccurred.emit(f"Товар с артикулом {article} не найден")
            return False

        except Exception as e:
            logger.exception(f"❌ Error deleting item by article: {e}")
            self.errorOccurred.emit(f"Ошибка удаления: {str(e)}")
            return False

    # ==================== Filter Methods ====================

    @Slot(str)
    def setFilterString(self, filter_string: str):
        """
        Устанавливает строку для фильтрации товаров.

        Args:
            filter_string: Строка для фильтрации.
        """
        if self._filter_string != filter_string:
            self._filter_string = filter_string
            logger.debug(f"Filter string set to: '{filter_string}'")

            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot(str)
    def setFilterField(self, field: str):
        """
        Устанавливает поле для фильтрации товаров.

        Args:
            field: Поле для фильтрации (article, name, description, category, manufacturer).
        """
        if self._filter_field != field:
            self._filter_field = field
            logger.debug(f"Filter field set to: '{field}'")

            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot()
    def clearFilter(self):
        """
        Сбрасывает все фильтры, возвращая модель к полному списку товаров.
        """
        self._filter_string = ""
        self._filter_field = "name"
        logger.debug("Filters cleared")

        self.beginResetModel()
        self._applyFilter()
        self.endResetModel()

    # ==================== Utility Methods ====================

    @Slot(int, result='QVariantMap')
    def get(self, row: int):
        """
        Получает данные товара по индексу строки.

        Args:
            row: Индекс строки в отфильтрованном списке.

        Returns:
            dict: Словарь с данными товара или пустой словарь при ошибке.
        """
        if row < 0 or row >= len(self.items):
            logger.warning(f"⚠️ Invalid row index: {row}")
            return {}

        item = self.items[row]

        result = {
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

        logger.trace(f"Retrieved item data for row {row}: {item[0]}")
        return result

    @Slot(str, str, result=list)
    def searchItems(self, query: str, field: str = "name"):
        """
        Поиск товаров по запросу в указанном поле.

        Args:
            query: Поисковый запрос.
            field: Поле для поиска (name, article, manufacturer, description).

        Returns:
            list: Список найденных товаров.
        """
        try:
            logger.info(f"Searching items: query='{query}', field='{field}'")

            results = self.repository.search(query, field)

            logger.info(f"🔍 Found {len(results)} results")
            return results

        except Exception as e:
            logger.error(f"❌ Search error: {e}")
            self.errorOccurred.emit(f"Ошибка поиска: {str(e)}")
            return []

    @Slot()
    def refresh(self):
        """
        Принудительно обновляет данные модели.
        """
        logger.info("Manual refresh triggered")

        self.beginResetModel()
        self.loadData()
        self.endResetModel()

        logger.debug("Model manually refreshed")

    @Slot(result=int)
    def getTotalCount(self) -> int:
        """
        Возвращает общее количество товаров (без фильтра).

        Returns:
            int: Общее количество товаров.
        """
        return len(self._all_items)

    @Slot(result=int)
    def getFilteredCount(self) -> int:
        """
        Возвращает количество отфильтрованных товаров.

        Returns:
            int: Количество товаров после применения фильтра.
        """
        return len(self.items)