"""Модель поставщиков для Qt/QML интерфейса с Repository Pattern"""

from PySide6.QtCore import QAbstractListModel, Qt, Slot, Signal
from loguru import logger

from repositories.suppliers_repository import SuppliersRepository
from models.dto import Supplier


class SuppliersModel(QAbstractListModel):
    """
    Модель для управления списком поставщиков в Qt/QML приложении.

    Использует Repository Pattern для работы с данными.
    Предоставляет данные о поставщиках для QML интерфейса.

    Attributes:
        repository: SuppliersRepository для работы с базой данных
        _suppliers: Список поставщиков для отображения
    """

    # Роли данных для QML
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CompanyRole = Qt.UserRole + 3
    EmailRole = Qt.UserRole + 4
    PhoneRole = Qt.UserRole + 5
    WebsiteRole = Qt.UserRole + 6

    # Сигналы
    errorOccurred = Signal(str)
    suppliersLoaded = Signal(int)  # Количество загруженных поставщиков

    def __init__(self, suppliers_repository: SuppliersRepository, parent=None):
        """
        Инициализирует модель поставщиков.

        Args:
            suppliers_repository: Репозиторий для работы с поставщиками.
            parent: Родительский объект Qt (опционально).
        """
        super().__init__(parent)

        self.repository = suppliers_repository
        self._suppliers = []

        logger.debug("SuppliersModel initialized")
        self.loadSuppliers()

    def roleNames(self):
        """
        Возвращает сопоставление ролей и их строковых имен для QML.

        Returns:
            dict: Словарь ролей и их имен в байтовом формате.
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
        """
        Возвращает количество поставщиков в модели.

        Args:
            parent: Родительский индекс модели.

        Returns:
            int: Количество поставщиков.
        """
        return len(self._suppliers)

    def data(self, index, role=Qt.DisplayRole):
        """
        Получает данные для указанного индекса и роли.

        Args:
            index: Индекс строки в модели.
            role: Роль данных.

        Returns:
            Значение данных или None.
        """
        if not index.isValid() or not (0 <= index.row() < len(self._suppliers)):
            return None

        supplier = self._suppliers[index.row()]

        if role == self.IdRole:
            return supplier.id
        elif role == self.NameRole:
            return supplier.name
        elif role == self.CompanyRole:
            return supplier.company
        elif role == self.EmailRole:
            return supplier.email or ""
        elif role == self.PhoneRole:
            return supplier.phone or ""
        elif role == self.WebsiteRole:
            return supplier.website or ""

        return None

    # ==================== Data Loading ====================

    def loadSuppliers(self):
        """
        Загружает поставщиков из репозитория и обновляет модель.

        Испускает сигнал suppliersLoaded при успешной загрузке.
        """
        logger.info("Loading suppliers...")

        try:
            self.beginResetModel()
            self._suppliers = self.repository.get_all()
            self.endResetModel()

            logger.success(f"✅ Loaded {len(self._suppliers)} suppliers")
            self.suppliersLoaded.emit(len(self._suppliers))

        except Exception as e:
            logger.exception("❌ Failed to load suppliers")
            self.errorOccurred.emit(f"Ошибка загрузки поставщиков: {str(e)}")

    @Slot()
    def refresh(self):
        """
        Принудительно обновляет данные модели.
        """
        logger.info("Manual refresh triggered")
        self.loadSuppliers()

    # ==================== CRUD Operations ====================

    @Slot(str, str, str, str, str)
    def addSupplier(
            self,
            name: str,
            company: str,
            email: str = "",
            phone: str = "",
            website: str = ""
    ):
        """
        Добавляет нового поставщика в базу данных.

        Args:
            name: Имя контактного лица.
            company: Название компании.
            email: Электронная почта (опционально).
            phone: Телефон (опционально).
            website: Веб-сайт (опционально).
        """
        try:
            logger.info(f"Adding supplier: company='{company}', name='{name}'")

            # Валидация
            if not company or not company.strip():
                error_msg = "Название компании не может быть пустым"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            # Создаем DTO объект
            supplier = Supplier(
                id=None,
                name=name.strip() if name else "",
                company=company.strip(),
                email=email.strip() if email else None,
                phone=phone.strip() if phone else None,
                website=website.strip() if website else None
            )

            # Добавляем через репозиторий
            supplier_id = self.repository.add(supplier)

            logger.success(f"✅ Supplier added: {company} (ID: {supplier_id})")

            # Обновляем модель
            self.loadSuppliers()

        except Exception as e:
            error_msg = f"Ошибка добавления поставщика: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(int, str, str, str, str, str)
    def updateSupplier(
            self,
            supplier_id: int,
            name: str,
            company: str,
            email: str = "",
            phone: str = "",
            website: str = ""
    ):
        """
        Обновляет данные существующего поставщика.

        Args:
            supplier_id: Идентификатор поставщика.
            name: Имя контактного лица.
            company: Название компании.
            email: Электронная почта (опционально).
            phone: Телефон (опционально).
            website: Веб-сайт (опционально).
        """
        try:
            logger.info(f"Updating supplier {supplier_id}: company='{company}'")

            # Валидация
            if not company or not company.strip():
                error_msg = "Название компании не может быть пустым"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            # Создаем DTO объект
            supplier = Supplier(
                id=supplier_id,
                name=name.strip() if name else "",
                company=company.strip(),
                email=email.strip() if email else None,
                phone=phone.strip() if phone else None,
                website=website.strip() if website else None
            )

            # Обновляем через репозиторий
            self.repository.update(supplier_id, supplier)

            logger.success(f"✅ Supplier {supplier_id} updated: {company}")

            # Обновляем модель
            self.loadSuppliers()

        except Exception as e:
            error_msg = f"Ошибка обновления поставщика: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(int)
    def deleteSupplier(self, supplier_id: int):
        """
        Удаляет поставщика из базы данных.

        Args:
            supplier_id: Идентификатор поставщика.
        """
        try:
            logger.info(f"Deleting supplier: {supplier_id}")

            # Удаляем через репозиторий
            self.repository.delete(supplier_id)

            logger.success(f"✅ Supplier {supplier_id} deleted")

            # Обновляем модель
            self.loadSuppliers()

        except Exception as e:
            error_msg = f"Ошибка удаления поставщика: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    # ==================== Utility Methods ====================

    @Slot(int, result="QVariant")
    def get(self, idx: int):
        """
        Возвращает данные поставщика по индексу.

        Args:
            idx: Индекс строки в модели.

        Returns:
            dict: Словарь с данными поставщика или пустой словарь.
        """
        if 0 <= idx < len(self._suppliers):
            supplier = self._suppliers[idx]

            result = {
                "id": supplier.id,
                "name": supplier.name or "",
                "company": supplier.company,
                "email": supplier.email or "",
                "phone": supplier.phone or "",
                "website": supplier.website or ""
            }

            logger.trace(f"Retrieved supplier data for index {idx}: {supplier.company}")
            return result

        logger.warning(f"⚠️ Invalid supplier index: {idx}")
        return {
            "id": -1,
            "name": "",
            "company": "",
            "email": "",
            "phone": "",
            "website": ""
        }

    @Slot(str, result=int)
    def getSupplierIdByName(self, name: str) -> int:
        """
        Возвращает идентификатор поставщика по имени контактного лица.

        Args:
            name: Имя контактного лица.

        Returns:
            int: Идентификатор поставщика или -1, если не найден.
        """
        for supplier in self._suppliers:
            if supplier.name == name:
                logger.trace(f"Found supplier by name '{name}': ID {supplier.id}")
                return supplier.id

        logger.debug(f"Supplier with name '{name}' not found")
        return -1

    @Slot(str, result=int)
    def getSupplierIdByCompany(self, company: str) -> int:
        """
        Возвращает идентификатор поставщика по названию компании.

        Args:
            company: Название компании.

        Returns:
            int: Идентификатор поставщика или -1, если не найден.
        """
        for supplier in self._suppliers:
            if supplier.company == company:
                logger.trace(f"Found supplier by company '{company}': ID {supplier.id}")
                return supplier.id

        logger.debug(f"Supplier with company '{company}' not found")
        return -1

    @Slot(int, result="QVariant")
    def getSupplierById(self, supplier_id: int):
        """
        Возвращает поставщика по его ID.

        Args:
            supplier_id: Идентификатор поставщика.

        Returns:
            dict: Словарь с данными поставщика или пустой словарь.
        """
        for supplier in self._suppliers:
            if supplier.id == supplier_id:
                logger.trace(f"Found supplier with ID {supplier_id}: {supplier.company}")
                return {
                    "id": supplier.id,
                    "name": supplier.name or "",
                    "company": supplier.company,
                    "email": supplier.email or "",
                    "phone": supplier.phone or "",
                    "website": supplier.website or ""
                }

        logger.warning(f"⚠️ Supplier with ID {supplier_id} not found")
        return {
            "id": -1,
            "name": "",
            "company": "",
            "email": "",
            "phone": "",
            "website": ""
        }

    @Slot(result=int)
    def count(self) -> int:
        """
        Возвращает количество поставщиков.

        Returns:
            int: Количество поставщиков в модели.
        """
        return len(self._suppliers)

    @Slot(str, result=bool)
    def existsByCompany(self, company: str) -> bool:
        """
        Проверяет существование поставщика по названию компании.

        Args:
            company: Название компании.

        Returns:
            bool: True если поставщик существует, иначе False.
        """
        exists = any(supplier.company == company for supplier in self._suppliers)
        logger.trace(f"Supplier with company '{company}' exists: {exists}")
        return exists

    @Slot(result=list)
    def getAllCompanies(self):
        """
        Возвращает список всех названий компаний.

        Returns:
            list: Список названий компаний.
        """
        companies = [supplier.company for supplier in self._suppliers]
        logger.trace(f"Retrieved {len(companies)} company names")
        return companies

    # ==================== Item-Supplier Relations ====================

    @Slot(str, "QVariantList")
    def bindSuppliersToItem(self, article: str, supplier_ids: list):
        """
        Привязывает список поставщиков к товару.

        Args:
            article: Артикул товара.
            supplier_ids: Список идентификаторов поставщиков.
        """
        try:
            logger.info(f"Binding {len(supplier_ids)} supplier(s) to item {article}")

            # Конвертируем в int
            supplier_ids = [int(sid) for sid in supplier_ids]

            # Привязываем через репозиторий
            success = self.repository.set_suppliers_for_item(article, supplier_ids)

            if success:
                logger.success(
                    f"✅ Suppliers {supplier_ids} bound to item {article}"
                )
            else:
                error_msg = f"Не удалось привязать поставщиков к товару {article}"
                logger.warning(f"⚠️ {error_msg}")
                self.errorOccurred.emit(error_msg)

        except Exception as e:
            error_msg = f"Ошибка привязки поставщиков: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(str, result="QVariantList")
    def getSuppliersForItem(self, article: str):
        """
        Получает список поставщиков для указанного товара.

        Args:
            article: Артикул товара.

        Returns:
            list: Список словарей с данными поставщиков.
        """
        try:
            logger.debug(f"Getting suppliers for item {article}")

            suppliers = self.repository.get_suppliers_for_item(article)

            result = [
                {
                    "id": s.id,
                    "name": s.name or "",
                    "company": s.company,
                    "email": s.email or "",
                    "phone": s.phone or "",
                    "website": s.website or ""
                }
                for s in suppliers
            ]

            logger.info(f"🔗 Found {len(result)} supplier(s) for item {article}")
            return result

        except Exception as e:
            logger.error(f"❌ Error getting suppliers for item: {e}")
            return []

    @Slot(str, result="QVariantList")
    def getSupplierIdsForItem(self, article: str):
        """
        Получает список ID поставщиков для указанного товара.

        Args:
            article: Артикул товара.

        Returns:
            list: Список ID поставщиков.
        """
        try:
            suppliers = self.repository.get_suppliers_for_item(article)
            ids = [s.id for s in suppliers]

            logger.debug(f"Retrieved {len(ids)} supplier ID(s) for item {article}")
            return ids

        except Exception as e:
            logger.error(f"❌ Error getting supplier IDs: {e}")
            return []