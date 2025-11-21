"""Табличная модель для управления поставщиками с Repository Pattern + DEBUG"""

from PySide6.QtCore import QAbstractTableModel, Qt, Slot, Signal
from loguru import logger
from typing import List

from repositories.suppliers_repository import SuppliersRepository
from models.dto import Supplier


class SuppliersTableModel(QAbstractTableModel):
    """
    Табличная модель для управления поставщиками.

    Предоставляет табличное представление поставщиков для QML,
    поддерживает фильтрацию, выбор через чекбоксы и привязку к товарам.
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
    errorOccurred = Signal(str)
    dataLoaded = Signal(int)  # Количество загруженных записей

    def __init__(self, suppliers_repository: SuppliersRepository, parent=None):
        """
        Инициализация модели.

        Args:
            suppliers_repository: Репозиторий для работы с поставщиками.
            parent: Родительский объект Qt.
        """
        super().__init__(parent)

        self.repository = suppliers_repository
        self._suppliers: List[Supplier] = []  # Все поставщики (DTO)
        self._filtered_suppliers: List[Supplier] = []  # Отфильтрованные поставщики
        self._checked = set()  # Множество ID выбранных поставщиков
        self._filter_string = ""  # Строка фильтра

        logger.debug("🔧 SuppliersTableModel initialized")
        self.load()

    # ==================== Filtering ====================

    @Slot(str)
    def setFilterString(self, filter_string: str):
        """
        Устанавливает строку фильтра.

        Args:
            filter_string: Строка для поиска по имени, компании, email.
        """
        self._filter_string = filter_string.lower().strip()
        logger.debug(f"🔍 Filter string set to: '{self._filter_string}'")
        self._applyFilter()

    def _applyFilter(self):
        """Применяет фильтр к списку поставщиков."""
        logger.debug("=" * 80)
        logger.debug("🔍 APPLYING FILTER")
        logger.debug(f"Filter string: '{self._filter_string}'")
        logger.debug(f"Total suppliers BEFORE filter: {len(self._suppliers)}")
        logger.debug(f"Checked IDs BEFORE filter: {self._checked}")

        self.beginResetModel()

        if not self._filter_string:
            # Без фильтра - показываем всех
            self._filtered_suppliers = self._suppliers.copy()
            logger.debug("✅ No filter - showing all suppliers")
        else:
            # Фильтруем по имени, компании и email
            self._filtered_suppliers = [
                supplier for supplier in self._suppliers
                if self._matchesFilter(supplier)
            ]
            logger.debug(f"✅ Filter applied - showing {len(self._filtered_suppliers)} suppliers")

        # Проверяем, какие ID в отфильтрованном списке
        filtered_ids = {s.id for s in self._filtered_suppliers}
        checked_in_filtered = self._checked & filtered_ids
        logger.debug(f"Filtered supplier IDs: {filtered_ids}")
        logger.debug(f"Checked IDs in filtered list: {checked_in_filtered}")
        logger.debug(f"Checked IDs NOT in filtered list: {self._checked - filtered_ids}")

        self.endResetModel()

        logger.debug("=" * 80)

    def _matchesFilter(self, supplier: Supplier) -> bool:
        """
        Проверяет соответствие поставщика фильтру.

        Args:
            supplier: DTO объект поставщика.

        Returns:
            bool: True если соответствует фильтру.
        """
        # Поиск в имени, компании и email
        search_fields = [
            str(supplier.name or "").lower(),
            str(supplier.company or "").lower(),
            str(supplier.email or "").lower(),
        ]

        return any(self._filter_string in field for field in search_fields)

    # ==================== Data Loading ====================

    @Slot()
    def load(self):
        """Загружает всех поставщиков (режим управления)."""
        try:
            logger.info("=" * 80)
            logger.info("📥 LOADING SUPPLIERS (Management Mode)")

            self.beginResetModel()

            # Загружаем через репозиторий
            self._suppliers = self.repository.get_all()
            logger.info(f"📊 Loaded {len(self._suppliers)} suppliers from repository")

            # Логируем первых 3 для проверки
            for i, s in enumerate(self._suppliers[:3]):
                logger.debug(f"  Supplier {i+1}: ID={s.id}, Company={s.company}")

            self._checked.clear()
            logger.debug("🔲 Cleared all checkboxes")

            # Применяем текущий фильтр
            self._applyFilter()

            self.endResetModel()

            logger.success(f"✅ Loaded {len(self._suppliers)} suppliers successfully")
            logger.info("=" * 80)
            self.dataLoaded.emit(len(self._suppliers))

        except Exception as e:
            error_msg = f"Ошибка загрузки поставщиков: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(str)
    def loadForArticle(self, article: str):
        """
        Загружает поставщиков для привязки к товару.

        Args:
            article: Артикул товара.
        """
        try:
            logger.info("=" * 80)
            logger.info(f"📥 LOADING SUPPLIERS FOR ARTICLE: {article}")

            self.beginResetModel()

            # Загружаем всех поставщиков
            logger.debug("Step 1: Loading ALL suppliers...")
            self._suppliers = self.repository.get_all()
            logger.info(f"📊 Loaded {len(self._suppliers)} total suppliers")

            # Логируем первых 3 для проверки
            for i, s in enumerate(self._suppliers[:3]):
                logger.debug(f"  Supplier {i+1}: ID={s.id}, Company={s.company}")

            # Загружаем привязанных поставщиков
            logger.debug(f"Step 2: Loading BOUND suppliers for article {article}...")
            bound_suppliers = self.repository.get_suppliers_for_item(article)
            logger.info(f"📌 Found {len(bound_suppliers)} bound suppliers")

            # Логируем привязанных
            for i, s in enumerate(bound_suppliers):
                logger.debug(f"  Bound supplier {i+1}: ID={s.id}, Company={s.company}")

            # Извлекаем ID привязанных поставщиков
            logger.debug("Step 3: Extracting bound supplier IDs...")
            self._checked = {supplier.id for supplier in bound_suppliers}
            logger.info(f"✅ Checked IDs set: {self._checked}")

            # Проверяем, что все ID существуют в общем списке
            all_ids = {s.id for s in self._suppliers}
            logger.debug(f"All supplier IDs: {all_ids}")

            invalid_checked = self._checked - all_ids
            if invalid_checked:
                logger.warning(f"⚠️ WARNING: Some checked IDs don't exist in suppliers list: {invalid_checked}")
            else:
                logger.debug("✅ All checked IDs are valid")

            # Применяем текущий фильтр
            logger.debug("Step 4: Applying current filter...")
            self._applyFilter()

            self.endResetModel()

            logger.success(
                f"✅ Loaded {len(self._suppliers)} suppliers, "
                f"{len(self._checked)} already bound to {article}"
            )
            logger.info("=" * 80)
            self.dataLoaded.emit(len(self._suppliers))

        except Exception as e:
            error_msg = f"Ошибка загрузки поставщиков: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            logger.info("=" * 80)
            self.errorOccurred.emit(error_msg)

    # ==================== Qt Model API ====================

    def roleNames(self):
        """Возвращает роли для QML."""
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
        """Количество столбцов."""
        return 7  # checkbox, ID, name, company, email, phone, website

    def rowCount(self, parent=None):
        """Количество строк (отфильтрованных поставщиков)."""
        count = len(self._filtered_suppliers)
        logger.trace(f"rowCount() called: {count}")
        return count

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        """Заголовки столбцов."""
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            headers = ["", "ID", "ФИО", "Компания", "Email", "Телефон", "Сайт"]
            return headers[section] if 0 <= section < len(headers) else ""
        return None

    def data(self, index, role=Qt.DisplayRole):
        """Получение данных."""
        if not index.isValid() or index.row() >= len(self._filtered_suppliers):
            return None

        supplier = self._filtered_suppliers[index.row()]

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
        elif role == Qt.CheckStateRole:
            is_checked = supplier.id in self._checked
            state = Qt.Checked.value if is_checked else Qt.Unchecked.value

            # Логируем только для первых 5 строк чтобы не захламлять лог
            if index.row() < 5:
                logger.trace(
                    f"data() CheckState: row={index.row()}, "
                    f"supplier_id={supplier.id}, checked={is_checked}, state={state}"
                )

            return state

        return None

    def setData(self, index, value, role=Qt.EditRole):
        """Установка данных (для чекбоксов)."""
        if not index.isValid() or role != Qt.CheckStateRole:
            return False

        supplier = self._filtered_suppliers[index.row()]
        is_checked = (value == Qt.Checked.value)

        logger.debug("=" * 60)
        logger.debug(f"📌 CHECKBOX CHANGED")
        logger.debug(f"Row: {index.row()}")
        logger.debug(f"Supplier ID: {supplier.id}")
        logger.debug(f"Company: {supplier.company}")
        logger.debug(f"New state: {'CHECKED' if is_checked else 'UNCHECKED'}")
        logger.debug(f"Checked IDs BEFORE: {self._checked}")

        if is_checked:
            self._checked.add(supplier.id)
        else:
            self._checked.discard(supplier.id)

        logger.debug(f"Checked IDs AFTER: {self._checked}")
        logger.debug("=" * 60)

        self.dataChanged.emit(index, index, [Qt.CheckStateRole])
        return True

    def flags(self, index):
        """Флаги элементов."""
        if not index.isValid():
            return Qt.NoItemFlags

        if index.column() == 0:
            return Qt.ItemIsEnabled | Qt.ItemIsUserCheckable

        return Qt.ItemIsEnabled | Qt.ItemIsSelectable

    # ==================== QML Slots ====================

    @Slot(result="QVariantList")
    def getSelectedSupplierIds(self) -> List[int]:
        """
        Возвращает список ID выбранных поставщиков.

        Returns:
            list: Список ID выбранных поставщиков.
        """
        selected = list(self._checked)
        logger.info(f"📋 getSelectedSupplierIds() called: {selected}")
        return selected

    @Slot(str, "QVariantList")
    def bindSuppliersToItem(self, article: str, supplier_ids: List[int]):
        """
        Привязывает поставщиков к товару.

        Args:
            article: Артикул товара.
            supplier_ids: Список ID поставщиков.
        """
        try:
            # Конвертируем в int на всякий случай
            supplier_ids = [int(sid) for sid in supplier_ids]

            logger.info("=" * 80)
            logger.info(f"💾 BINDING SUPPLIERS TO ITEM: {article}")
            logger.info(f"Supplier count: {len(supplier_ids)}")
            logger.debug(f"Supplier IDs: {supplier_ids}")

            # Сохраняем через репозиторий
            self.repository.set_suppliers_for_item(article, supplier_ids)

            # Очищаем чекбоксы
            logger.debug("Clearing checkboxes...")
            self._checked.clear()

            # Обновляем все чекбоксы
            if self.rowCount() > 0:
                top_left = self.index(0, 0)
                bottom_right = self.index(self.rowCount() - 1, 0)
                self.dataChanged.emit(top_left, bottom_right, [Qt.CheckStateRole])
                logger.debug("Checkboxes updated")

            logger.success(f"✅ Suppliers bound to item {article}")
            logger.info("=" * 80)

        except Exception as e:
            error_msg = f"Ошибка привязки поставщиков: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            logger.info("=" * 80)
            self.errorOccurred.emit(error_msg)

    @Slot(int, result="QVariant")
    def getSupplierRow(self, row: int):
        """
        Возвращает данные поставщика по индексу строки.

        Args:
            row: Индекс строки.

        Returns:
            dict: Словарь с данными поставщика.
        """
        if 0 <= row < len(self._filtered_suppliers):
            supplier = self._filtered_suppliers[row]
            return {
                "id": supplier.id,
                "name": supplier.name,
                "company": supplier.company,
                "email": supplier.email,
                "phone": supplier.phone,
                "website": supplier.website,
            }

        logger.warning(f"⚠️ Invalid row index: {row}")
        return {"id": -1}

    # ==================== CRUD Operations ====================

    @Slot(str, str, str, str, str)
    def addSupplier(self, name: str, company: str, email: str, phone: str, website: str):
        """Добавляет нового поставщика."""
        try:
            logger.info(f"Adding supplier: {company}")

            supplier = Supplier(
                id=None,
                name=name,
                company=company,
                email=email,
                phone=phone,
                website=website
            )

            supplier_id = self.repository.add(supplier)
            logger.success(f"✅ Supplier added with ID: {supplier_id}")

            self.load()

        except Exception as e:
            error_msg = f"Ошибка добавления поставщика: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(int, str, str, str, str, str)
    def updateSupplier(self, supplier_id: int, name: str, company: str,
                      email: str, phone: str, website: str):
        """Обновляет данные поставщика."""
        try:
            logger.info(f"Updating supplier {supplier_id}: {company}")

            supplier = Supplier(
                id=supplier_id,
                name=name,
                company=company,
                email=email,
                phone=phone,
                website=website
            )

            # ✅ ИСПРАВЛЕНО: передаем оба аргумента
            self.repository.update(supplier_id, supplier)
            logger.success(f"✅ Supplier {supplier_id} updated")

            self.load()

        except Exception as e:
            error_msg = f"Ошибка обновления поставщика: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(int)
    def deleteSupplier(self, supplier_id: int):
        """Удаляет поставщика."""
        try:
            logger.info(f"Deleting supplier {supplier_id}")

            self.repository.delete(supplier_id)
            logger.success(f"✅ Supplier {supplier_id} deleted")

            self.load()

        except Exception as e:
            error_msg = f"Ошибка удаления поставщика: {str(e)}"
            logger.exception(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)