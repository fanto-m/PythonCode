"""Табличная модель для позиций спецификации с Loguru"""

from PySide6.QtCore import QAbstractTableModel, Qt, QModelIndex, Slot, Signal
from loguru import logger
from typing import List, Dict, Any


class SpecificationItemsTableModel(QAbstractTableModel):
    """
    Табличная модель для позиций спецификации.

    Столбцы: Вид | Артикул | Название | Категория | Кол-во | Ед. | Цена | Сумма | Статус | Удалить

    Примечание: Эта модель работает с временными данными в памяти,
    которые загружаются/сохраняются через SpecificationsModel.
    Не требует Repository Pattern.
    """

    # Индексы столбцов
    COL_IMAGE = 0
    COL_ARTICLE = 1
    COL_NAME = 2
    COL_CATEGORY = 3
    COL_QUANTITY = 4
    COL_UNIT = 5
    COL_PRICE = 6
    COL_TOTAL = 7
    COL_STATUS = 8
    COL_DELETE = 9

    COLUMN_COUNT = 10

    # Сигналы
    totalCostChanged = Signal(float)
    itemAdded = Signal()
    itemRemoved = Signal()

    def __init__(self):
        """Инициализация модели."""
        super().__init__()

        self._items: List[Dict[str, Any]] = []
        self._headers = [
            "Вид", "Артикул", "Название", "Категория",
            "Кол-во", "Ед.", "Цена", "Сумма", "Статус", "Удалить"
        ]

        logger.debug("SpecificationItemsTableModel initialized")

    # ==================== Qt Model API ====================

    def rowCount(self, parent=QModelIndex()):
        """Возвращает количество строк."""
        if parent.isValid():
            return 0
        return len(self._items)

    def columnCount(self, parent=QModelIndex()):
        """Возвращает количество столбцов."""
        if parent.isValid():
            return 0
        return self.COLUMN_COUNT

    def data(self, index, role=Qt.DisplayRole):
        """Возвращает данные для указанного индекса и роли."""
        if not index.isValid():
            return None

        if index.row() >= len(self._items) or index.row() < 0:
            return None

        item = self._items[index.row()]
        column = index.column()

        # Custom roles для QML (прямой доступ к свойствам)
        if role >= Qt.UserRole:
            if role == Qt.UserRole + 1:  # image_path
                value = item.get('image_path', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 2:  # article
                value = item.get('article', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 3:  # name
                value = item.get('name', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 4:  # category
                value = item.get('category', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 5:  # quantity
                value = item.get('quantity', 0.0)
                return float(value) if value is not None else 0.0
            elif role == Qt.UserRole + 6:  # unit
                value = item.get('unit', '')
                return value if value is not None else ''
            elif role == Qt.UserRole + 7:  # price
                value = item.get('price', 0.0)
                return float(value) if value is not None else 0.0
            elif role == Qt.UserRole + 8:  # total
                quantity = item.get('quantity', 0.0)
                price = item.get('price', 0.0)
                total = float(quantity) * float(price) if (quantity is not None and price is not None) else 0.0
                return total
            elif role == Qt.UserRole + 9:  # status
                value = item.get('status', '')
                return value if value is not None else ''
            return None

        # DisplayRole для TableView
        if role == Qt.DisplayRole or role == Qt.EditRole:
            return item

        return None

    def setData(self, index, value, role=Qt.EditRole):
        """Устанавливает данные для указанного индекса."""
        if not index.isValid():
            return False

        if index.row() >= len(self._items) or index.row() < 0:
            return False

        if role == Qt.EditRole:
            column = index.column()
            item = self._items[index.row()]

            if column == self.COL_QUANTITY:
                try:
                    new_quantity = float(value)
                    if new_quantity >= 0:
                        old_quantity = item['quantity']
                        item['quantity'] = new_quantity

                        logger.debug(
                            f"Quantity updated: row={index.row()}, "
                            f"{old_quantity} → {new_quantity}"
                        )

                        # Обновляем количество и сумму
                        self.dataChanged.emit(
                            index,
                            self.index(index.row(), self.COL_TOTAL)
                        )
                        self._emitTotalCostChanged()
                        return True
                except (ValueError, TypeError) as e:
                    logger.warning(f"⚠️ Invalid quantity value: {e}")
                    return False

        return False

    def flags(self, index):
        """Возвращает флаги для элемента."""
        if not index.isValid():
            return Qt.NoItemFlags

        flags = Qt.ItemIsEnabled | Qt.ItemIsSelectable

        # Только столбец количества редактируемый
        if index.column() == self.COL_QUANTITY:
            flags |= Qt.ItemIsEditable

        return flags

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        """Возвращает заголовки."""
        if role == Qt.DisplayRole:
            if orientation == Qt.Horizontal:
                if 0 <= section < len(self._headers):
                    return self._headers[section]
        return None

    def roleNames(self):
        """Роли для QML."""
        roles = {
            Qt.DisplayRole: b"display",
            Qt.UserRole + 1: b"image_path",
            Qt.UserRole + 2: b"article",
            Qt.UserRole + 3: b"name",
            Qt.UserRole + 4: b"category",
            Qt.UserRole + 5: b"quantity",
            Qt.UserRole + 6: b"unit",
            Qt.UserRole + 7: b"price",
            Qt.UserRole + 8: b"total",
            Qt.UserRole + 9: b"status"
        }
        return roles

    # ==================== CRUD Operations ====================

    @Slot(str, str, float, str, float, str, str, str, result=bool)
    def addItem(self, article: str, name: str, quantity: float, unit: str,
                price: float, image_path: str = "", category: str = "",
                status: str = "") -> bool:
        """
        Добавляет позицию в спецификацию.
        Если артикул уже существует, увеличивает количество.

        Args:
            article: Артикул товара.
            name: Название товара.
            quantity: Количество.
            unit: Единица измерения.
            price: Цена.
            image_path: Путь к изображению (опционально).
            category: Категория (опционально).
            status: Статус (опционально).

        Returns:
            bool: True если добавлен новый товар, False если увеличено количество.
        """
        # Нормализация
        article_normalized = str(article).strip()
        quantity_float = float(quantity) if quantity is not None else 1.0

        logger.info(
            f"Adding item: article={article_normalized}, "
            f"name={name}, qty={quantity_float}"
        )

        # Проверка на дубликат
        for i, existing_item in enumerate(self._items):
            existing_article = str(existing_item.get('article', '')).strip()

            if existing_article == article_normalized:
                # Найден дубликат - увеличиваем количество
                old_quantity = existing_item['quantity']
                existing_item['quantity'] += quantity_float

                logger.info(
                    f"📦 Duplicate found: '{article_normalized}', "
                    f"quantity {old_quantity} → {existing_item['quantity']}"
                )

                # Уведомляем об изменении
                index_start = self.index(i, self.COL_QUANTITY)
                index_end = self.index(i, self.COL_TOTAL)
                self.dataChanged.emit(index_start, index_end, [Qt.DisplayRole, Qt.EditRole])

                self._emitTotalCostChanged()
                return False  # Не добавлен, увеличено количество

        # Не найден дубликат - добавляем новый
        row = len(self._items)
        self.beginInsertRows(QModelIndex(), row, row)

        new_item = {
            'article': article_normalized,
            'name': str(name) if name is not None else '',
            'quantity': quantity_float,
            'unit': str(unit) if unit is not None else 'шт.',
            'price': float(price) if price is not None else 0.0,
            'image_path': str(image_path) if image_path is not None else '',
            'category': str(category) if category is not None else '',
            'status': str(status) if status is not None else '',
        }

        self._items.append(new_item)
        self.endInsertRows()

        self._emitTotalCostChanged()
        self.itemAdded.emit()

        logger.success(
            f"✅ New item added: {article_normalized}, "
            f"total items: {len(self._items)}"
        )

        return True  # Добавлен новый товар

    @Slot(int)
    def removeItem(self, row: int) -> bool:
        """
        Удаляет позицию по индексу.

        Args:
            row: Индекс строки.

        Returns:
            bool: True если удаление успешно.
        """
        if 0 <= row < len(self._items):
            item = self._items[row]
            article = item.get('article', 'unknown')

            logger.info(f"Removing item at row {row}: {article}")

            self.beginRemoveRows(QModelIndex(), row, row)
            self._items.pop(row)
            self.endRemoveRows()

            self._emitTotalCostChanged()
            self.itemRemoved.emit()

            logger.success(f"✅ Item removed: {article}")
            return True

        logger.warning(f"⚠️ Invalid row for removal: {row}")
        return False

    @Slot(int, float)
    def updateQuantity(self, row: int, new_quantity: float) -> bool:
        """
        Обновляет количество для позиции.

        Args:
            row: Индекс строки.
            new_quantity: Новое количество.

        Returns:
            bool: True если обновление успешно.
        """
        if 0 <= row < len(self._items):
            try:
                quantity = float(new_quantity)
                if quantity >= 0:
                    old_quantity = self._items[row]['quantity']
                    self._items[row]['quantity'] = quantity

                    logger.debug(
                        f"Quantity updated: row={row}, "
                        f"{old_quantity} → {quantity}"
                    )

                    # Обновляем количество и сумму
                    index_start = self.index(row, self.COL_QUANTITY)
                    index_end = self.index(row, self.COL_TOTAL)
                    self.dataChanged.emit(index_start, index_end)

                    self._emitTotalCostChanged()
                    return True
                else:
                    logger.warning(f"⚠️ Negative quantity rejected: {quantity}")

            except (ValueError, TypeError) as e:
                logger.error(f"❌ Invalid quantity value: {e}")

        return False

    # ==================== Utility Methods ====================

    @Slot(result=float)
    def getTotalMaterialsCost(self) -> float:
        """
        Вычисляет общую стоимость материалов.

        Returns:
            float: Общая стоимость.
        """
        total = sum(
            item.get('quantity', 0.0) * item.get('price', 0.0)
            for item in self._items
        )

        logger.trace(f"Total materials cost calculated: {total}")
        return float(total)

    @Slot()
    def clear(self):
        """Очищает все позиции."""
        if len(self._items) > 0:
            item_count = len(self._items)

            logger.info(f"Clearing {item_count} items")

            self.beginResetModel()
            self._items.clear()
            self.endResetModel()

            self._emitTotalCostChanged()

            logger.success(f"✅ Cleared {item_count} items")

    @Slot(result="QVariantList")
    def getAllItems(self):
        """
        Возвращает все позиции.

        Returns:
            QVariantList: Список словарей с данными позиций.
        """
        logger.debug(f"getAllItems called, returning {len(self._items)} items")

        items_copy = self._items.copy()

        # Логируем для отладки (только если TRACE включен)
        if logger.level("TRACE").no >= logger._core.min_level:
            for i, item in enumerate(items_copy):
                logger.trace(
                    f"  Item {i}: {item.get('article')} - {item.get('name')}, "
                    f"qty={item.get('quantity')}, price={item.get('price')}"
                )

        return items_copy

    @Slot(result="QVariantList")
    def getItems(self):
        """Алиас для getAllItems (для совместимости)."""
        return self.getAllItems()

    @Slot(result=int)
    def count(self) -> int:
        """Возвращает количество позиций."""
        return len(self._items)

    @Slot(result=int)
    def itemCount(self) -> int:
        """Алиас для count (для совместимости)."""
        return self.count()

    @Slot("QVariantList")
    def loadItems(self, items):
        """
        Загружает позиции из списка словарей.

        Args:
            items: Список словарей с данными позиций (QVariantList из QML).
        """
        logger.info(f"Loading {len(items)} items into table")

        self.beginResetModel()
        self._items = []

        for item_data in items:
            # Нормализация данных
            item = {
                'article': str(item_data.get('article', '')) if item_data.get('article') is not None else '',
                'name': str(item_data.get('name', '')) if item_data.get('name') is not None else '',
                'quantity': float(item_data.get('quantity', 1.0)) if item_data.get('quantity') is not None else 1.0,
                'unit': str(item_data.get('unit', 'шт.')) if item_data.get('unit') is not None else 'шт.',
                'price': float(item_data.get('price', 0.0)) if item_data.get('price') is not None else 0.0,
                'image_path': str(item_data.get('image_path', '')) if item_data.get('image_path') is not None else '',
                'category': str(item_data.get('category', '')) if item_data.get('category') is not None else '',
                'status': str(item_data.get('status', '')) if item_data.get('status') is not None else ''
            }
            self._items.append(item)

        self.endResetModel()
        self._emitTotalCostChanged()

        logger.success(f"✅ Loaded {len(self._items)} items")

    @Slot(int, result='QVariantMap')
    def getItem(self, row: int) -> Dict[str, Any]:
        """
        Возвращает данные позиции по индексу.

        Args:
            row: Индекс строки.

        Returns:
            dict: Словарь с данными позиции или пустой словарь.
        """
        if 0 <= row < len(self._items):
            return self._items[row].copy()

        logger.warning(f"⚠️ Invalid row index: {row}")
        return {}

    @Slot()
    def debugPrintItems(self):
        """Отладочный метод для вывода всех позиций."""
        logger.info("=" * 60)
        logger.info(f"DEBUG: Current items in table model")
        logger.info(f"Total items: {len(self._items)}")

        for i, item in enumerate(self._items):
            logger.info(f"Item {i}:")
            for key, value in item.items():
                logger.info(f"  {key}: {value} (type: {type(value).__name__})")

        logger.info("=" * 60)

    def _emitTotalCostChanged(self):
        """Испускает сигнал при изменении общей стоимости."""
        total = self.getTotalMaterialsCost()
        self.totalCostChanged.emit(total)
        logger.trace(f"Total cost changed signal emitted: {total}")