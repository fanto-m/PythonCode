"""Прокси-модель для фильтрации и сортировки товаров с Loguru"""

from PySide6.QtCore import QSortFilterProxyModel, Slot, QSettings, Property, Qt
from loguru import logger

from items_model import ItemsModel


class FilterProxyModel(QSortFilterProxyModel):
    """
    Прокси-модель для фильтрации и сортировки данных из ItemsModel.

    Предоставляет функциональность фильтрации по указанному полю,
    сортировки данных, а также сохранения настроек фильтрации.
    Делегирует операции CRUD в исходную модель (ItemsModel).
    """

    def __init__(self, parent=None):
        """
        Инициализация прокси-модели.

        Args:
            parent: Родительский объект Qt.
        """
        super().__init__(parent)

        self._filter_field = "name"  # Поле для фильтрации по умолчанию
        self._filter_string = ""     # Строка фильтра по умолчанию
        self._settings = QSettings("ООО ОЗТМ", "Склад-0.1")

        # Загрузка сохраненных настроек
        self._loadSettings()

        # Включение динамической сортировки
        self.setDynamicSortFilter(True)

        logger.debug(
            f"FilterProxyModel initialized: "
            f"field={self._filter_field}, filter='{self._filter_string}'"
        )

    # ==================== Properties ====================

    def get_filter_string(self):
        """Получение текущей строки фильтра."""
        return self._filter_string

    def get_filter_field(self):
        """Получение текущего поля фильтрации."""
        return self._filter_field

    filterString = Property(str, get_filter_string, notify=None)
    filterField = Property(str, get_filter_field, notify=None)

    # ==================== Settings ====================

    def _loadSettings(self):
        """Загрузка настроек фильтрации из QSettings."""
        saved_field = self._settings.value("filterField", "name")
        saved_string = self._settings.value("filterString", "")

        self._filter_field = saved_field
        self._filter_string = saved_string.lower()

        logger.debug(
            f"Loaded filter settings: "
            f"field={self._filter_field}, string='{self._filter_string}'"
        )

    def _saveSettings(self):
        """Сохранение настроек фильтрации в QSettings."""
        self._settings.setValue("filterField", self._filter_field)
        self._settings.setValue("filterString", self._filter_string)

        logger.trace(
            f"Saved filter settings: "
            f"field={self._filter_field}, string='{self._filter_string}'"
        )

    # ==================== Filter & Sort ====================

    @Slot(str)
    def setFilterString(self, filterString: str):
        """
        Установка строки фильтра.

        Args:
            filterString: Новая строка фильтра.
        """
        self._filter_string = filterString.lower()
        self.invalidateFilter()
        self._saveSettings()

        logger.debug(f"Filter string set to: '{self._filter_string}'")

    @Slot(str)
    def setFilterField(self, field: str):
        """
        Установка поля фильтрации.

        Args:
            field: Новое поле для фильтрации.
        """
        self._filter_field = field
        self.invalidateFilter()
        self._saveSettings()

        logger.debug(f"Filter field set to: {self._filter_field}")

    @Slot(str, str)
    def setSort(self, role_name: str, order: str = "ascending"):
        """
        Установка сортировки данных.

        Args:
            role_name: Имя роли (поля) для сортировки.
            order: Порядок сортировки ("ascending" или "descending").
        """
        # Маппинг имен ролей на константы
        role_map = {
            "article": ItemsModel.ArticleRole,
            "name": ItemsModel.NameRole,
            "description": ItemsModel.DescriptionRole,
            "category": ItemsModel.CategoryRole,
            "price": ItemsModel.PriceRole,
            "stock": ItemsModel.StockRole
        }

        role = role_map.get(role_name, ItemsModel.NameRole)
        order_qt = Qt.AscendingOrder if order.lower() == "ascending" else Qt.DescendingOrder

        self.setSortRole(role)
        self.sort(0, order_qt)

        logger.info(f"Sorting set: role={role_name}, order={order}")

        # Логируем первые 5 строк для проверки
        if logger.level("TRACE").no >= logger._core.min_level:
            for row in range(min(5, self.rowCount())):
                index = self.index(row, 0)
                source_index = self.mapToSource(index)
                if source_index.isValid():
                    value = self.sourceModel().data(source_index, role)
                    logger.trace(
                        f"Row {row} (source {source_index.row()}): {value}"
                    )

    def filterAcceptsRow(self, sourceRow: int, sourceParent):
        """
        Проверка, проходит ли строка фильтр.

        Args:
            sourceRow: Индекс строки в исходной модели.
            sourceParent: Родительский индекс.

        Returns:
            bool: True если строка проходит фильтр.
        """
        if not self.sourceModel():
            return False

        index = self.sourceModel().index(sourceRow, 0, sourceParent)
        if not index.isValid():
            return False

        # Без фильтра - показываем все
        if not self._filter_string:
            return True

        # Маппинг полей на роли
        role_map = {
            "article": ItemsModel.ArticleRole,
            "name": ItemsModel.NameRole,
            "description": ItemsModel.DescriptionRole,
            "category": ItemsModel.CategoryRole,
            "price": ItemsModel.PriceRole,
            "stock": ItemsModel.StockRole
        }

        role = role_map.get(self._filter_field, ItemsModel.NameRole)
        value = self.sourceModel().data(index, role)
        value_str = "" if value is None else str(value).lower()

        result = self._filter_string in value_str

        # Логируем только если TRACE включен
        if result and logger.level("TRACE").no >= logger._core.min_level:
            logger.trace(
                f"Row {sourceRow} PASSED filter: "
                f"field={self._filter_field}, value='{value_str}'"
            )

        return result

    # ==================== CRUD Operations (delegated to source model) ====================

    @Slot(str, str, str, str, int, float, int, str, str, str, str)
    def addItem(self, article: str, name: str, description: str, image_path: str,
                category_id: int, price: float, stock: int, status: str,
                unit: str, manufacturer: str, document: str):
        """
        Добавление нового элемента (делегируется в исходную модель).

        Args:
            article: Артикул.
            name: Название.
            description: Описание.
            image_path: Путь к изображению.
            category_id: ID категории.
            price: Цена.
            stock: Количество на складе.
            status: Статус.
            unit: Единица измерения.
            manufacturer: Производитель.
            document: Документ.

        Returns:
            Результат операции или сообщение об ошибке.
        """
        logger.info(f"Adding item via proxy: article={article}, name={name}")

        try:
            # Безопасное преобразование типов
            price = float(price) if price else 0.0
            stock = int(stock) if stock else 0

            # Делегируем в source model
            result = self.sourceModel().addItem(
                article, name, description, image_path, category_id,
                price, stock, status, unit, manufacturer, document
            )

            logger.success(f"✅ Item added via proxy: {article}")
            return result

        except Exception as e:
            error_msg = f"Ошибка добавления товара: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            return error_msg

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str)
    def updateItem(self, proxy_row: int, article: str, name: str, description: str,
                   image_path: str, category_id: int, price: float, stock: int,
                   status: str, unit: str, manufacturer: str, document: str):
        """
        Обновление элемента (делегируется в исходную модель).

        Args:
            proxy_row: Индекс строки в прокси-модели.
            Остальные параметры - данные товара.
        """
        logger.info(f"Updating item via proxy: proxy_row={proxy_row}, article={article}")

        try:
            # Маппинг proxy_row -> source_row
            proxy_index = self.index(proxy_row, 0)
            if not proxy_index.isValid():
                raise ValueError(f"Invalid proxy index for row {proxy_row}")

            source_index = self.mapToSource(proxy_index)
            if not source_index.isValid():
                raise ValueError(f"Invalid source index for proxy row {proxy_row}")

            source_row = source_index.row()
            logger.debug(f"Mapped proxy_row {proxy_row} → source_row {source_row}")

            # Безопасное преобразование типов
            price = float(price) if price is not None and str(price).strip() else 0.0
            stock = int(stock) if stock is not None and str(stock).strip() else 0

            # Делегируем в source model
            self.sourceModel().updateItem(
                source_row, article, name, description, image_path,
                category_id, price, stock, status, unit, manufacturer, document
            )

            logger.success(f"✅ Item updated via proxy: {article}")

        except Exception as e:
            logger.exception(f"❌ Error updating item via proxy: {e}")

    @Slot(int)
    def deleteItem(self, proxy_row: int):
        """
        Удаление элемента по индексу (делегируется в исходную модель).

        Args:
            proxy_row: Индекс строки в прокси-модели.
        """
        logger.info(f"Deleting item via proxy: proxy_row={proxy_row}")

        try:
            # Маппинг proxy_row -> source_row
            proxy_index = self.index(proxy_row, 0)
            if not proxy_index.isValid():
                raise ValueError(f"Invalid proxy index for row {proxy_row}")

            source_index = self.mapToSource(proxy_index)
            if not source_index.isValid():
                raise ValueError(f"Invalid source index for proxy row {proxy_row}")

            source_row = source_index.row()
            logger.debug(f"Mapped proxy_row {proxy_row} → source_row {source_row}")

            # Делегируем в source model
            self.sourceModel().deleteItem(source_row)

            logger.success(f"✅ Item deleted via proxy: row {proxy_row}")

        except Exception as e:
            logger.exception(f"❌ Error deleting item via proxy: {e}")

    @Slot(str, result=bool)
    def deleteItemByArticle(self, article: str) -> bool:
        """
        Удаление элемента по артикулу (делегируется в исходную модель).

        Args:
            article: Артикул товара.

        Returns:
            bool: True если удаление успешно.
        """
        logger.info(f"Deleting item by article via proxy: {article}")

        try:
            source_model = self.sourceModel()
            if not source_model:
                logger.error("❌ No source model available")
                return False

            # Делегируем в source model
            result = source_model.deleteItemByArticle(article)

            if result:
                logger.success(f"✅ Item deleted by article: {article}")
            else:
                logger.warning(f"⚠️ Failed to delete item by article: {article}")

            return result

        except Exception as e:
            logger.exception(f"❌ Error deleting item by article: {e}")
            return False