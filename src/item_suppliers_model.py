"""Модель для отображения поставщиков конкретного товара с Repository Pattern"""

from PySide6.QtCore import QAbstractListModel, Qt, Slot, Signal
from loguru import logger
from typing import List

from repositories.suppliers_repository import SuppliersRepository
from models.dto import Supplier


class ItemSuppliersModel(QAbstractListModel):
    """
    Модель для управления списком поставщиков товара.

    Предоставляет данные о поставщиках для отображения в QML.
    Использует Repository Pattern для работы с данными.
    """

    # Роли для QML
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CompanyRole = Qt.UserRole + 3
    EmailRole = Qt.UserRole + 4
    PhoneRole = Qt.UserRole + 5
    WebsiteRole = Qt.UserRole + 6

    # Сигналы
    dataLoaded = Signal(int)  # Количество загруженных поставщиков
    errorOccurred = Signal(str)

    def __init__(self, suppliers_repository: SuppliersRepository, article: str = "", parent=None):
        """
        Инициализация модели.

        Args:
            suppliers_repository: Репозиторий для работы с поставщиками.
            article: Артикул товара (опционально).
            parent: Родительский объект Qt.
        """
        super().__init__(parent)

        self.repository = suppliers_repository
        self._article = article
        self._suppliers: List[Supplier] = []  # Список DTO объектов

        logger.debug(f"ItemSuppliersModel initialized for article: '{article}'")

        # Загружаем данные если артикул указан
        if article:
            self.load()

    def roleNames(self):
        """Возвращает роли для QML."""
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.CompanyRole: b"company",
            self.EmailRole: b"email",
            self.PhoneRole: b"phone",
            self.WebsiteRole: b"website"
        }

    def rowCount(self, parent=None):
        """Возвращает количество поставщиков."""
        return len(self._suppliers)

    def data(self, index, role=Qt.DisplayRole):
        """Получение данных для указанного индекса и роли."""
        if not index.isValid() or index.row() >= len(self._suppliers):
            return None

        supplier = self._suppliers[index.row()]

        if role == self.IdRole:
            return supplier.id
        elif role == self.NameRole:
            return supplier.name
        elif role == self.CompanyRole:
            return supplier.company
        elif role == self.EmailRole:
            return supplier.email
        elif role == self.PhoneRole:
            return supplier.phone
        elif role == self.WebsiteRole:
            return supplier.website

        return None

    # ==================== Data Loading ====================

    def load(self):
        """Загрузка поставщиков для текущего артикула."""
        try:
            if not self._article:
                logger.warning("⚠️ Cannot load suppliers: article is empty")
                self.beginResetModel()
                self._suppliers = []
                self.endResetModel()
                return

            logger.info(f"Loading suppliers for article: {self._article}")

            self.beginResetModel()

            # Загружаем поставщиков через репозиторий
            self._suppliers = self.repository.get_suppliers_for_item(self._article)

            self.endResetModel()

            logger.success(
                f"✅ Loaded {len(self._suppliers)} suppliers for {self._article}"
            )

            # Логируем список для проверки
            if self._suppliers:
                for i, supplier in enumerate(self._suppliers, 1):
                    logger.debug(
                        f"  Supplier {i}: ID={supplier.id}, "
                        f"Company={supplier.company}"
                    )

            self.dataLoaded.emit(len(self._suppliers))

        except Exception as e:
            error_msg = f"Ошибка загрузки поставщиков: {str(e)}"
            logger.exception(f"❌ {error_msg}")

            self.beginResetModel()
            self._suppliers = []
            self.endResetModel()

            self.errorOccurred.emit(error_msg)

    @Slot(str)
    def setArticle(self, article: str):
        """
        Устанавливает новый артикул и перезагружает данные.

        Args:
            article: Артикул товара.
        """
        logger.info(f"Setting article: '{self._article}' → '{article}'")

        self._article = article
        self.load()

    @Slot(int, result="QVariant")
    def get(self, index: int):
        """
        Получение данных поставщика по индексу.

        Args:
            index: Индекс в списке.

        Returns:
            dict: Словарь с данными поставщика.
        """
        if 0 <= index < len(self._suppliers):
            supplier = self._suppliers[index]

            result = {
                "id": supplier.id,
                "name": supplier.name or "",
                "company": supplier.company or "",
                "email": supplier.email or "",
                "phone": supplier.phone or "",
                "website": supplier.website or ""
            }

            logger.trace(f"get({index}): {supplier.company}")
            return result

        logger.warning(f"⚠️ Invalid index: {index}")
        return {
            "id": -1,
            "name": "",
            "company": "",
            "email": "",
            "phone": "",
            "website": ""
        }

    @Slot(result=str)
    def getArticle(self) -> str:
        """
        Возвращает текущий артикул.

        Returns:
            str: Артикул товара.
        """
        return self._article

    @Slot(result=int)
    def count(self) -> int:
        """
        Возвращает количество поставщиков.

        Returns:
            int: Количество поставщиков.
        """
        return len(self._suppliers)

    @Slot(result=bool)
    def hasSuppliers(self) -> bool:
        """
        Проверяет наличие поставщиков.

        Returns:
            bool: True если есть поставщики.
        """
        return len(self._suppliers) > 0

    @Slot()
    def clear(self):
        """Очищает модель."""
        logger.info("Clearing suppliers model")

        self.beginResetModel()
        self._suppliers = []
        self._article = ""
        self.endResetModel()

        logger.debug("Suppliers model cleared")