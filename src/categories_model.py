"""Модель категорий для Qt/QML интерфейса с Repository Pattern"""

from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex, Slot, Signal
from loguru import logger

from repositories.categories_repository import CategoriesRepository
from models.dto import Category


class CategoriesModel(QAbstractListModel):
    """
    Модель для управления категориями товаров в Qt/QML приложении.

    Использует Repository Pattern для работы с данными.
    Предоставляет интерфейс для отображения и редактирования категорий через QML.

    Attributes:
        repository: CategoriesRepository для работы с базой данных
        _categories: Список категорий для отображения

    Roles:
        IdRole: ID категории
        NameRole: Название категории
        PrefixRole: Префикс SKU
        DigitsRole: Количество цифр в SKU
    """

    # Роли данных для QML
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    PrefixRole = Qt.UserRole + 3
    DigitsRole = Qt.UserRole + 4

    # Сигналы
    errorOccurred = Signal(str)
    categoriesLoaded = Signal(int)  # Новый сигнал - количество загруженных категорий

    def __init__(self, categories_repository: CategoriesRepository, parent=None):
        """
        Инициализирует модель категорий.

        Args:
            categories_repository: Репозиторий для работы с категориями.
            parent: Родительский объект Qt (опционально).
        """
        super().__init__(parent)

        self.repository = categories_repository
        self._categories = []

        logger.debug("CategoriesModel initialized")
        self.loadCategories()

    def roleNames(self):
        """
        Возвращает сопоставление ролей и их строковых имён для QML.

        Returns:
            dict: Словарь ролей и их имен в байтовом формате.
        """
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.PrefixRole: b"sku_prefix",
            self.DigitsRole: b"sku_digits"
        }

    def rowCount(self, parent=QModelIndex()):
        """
        Возвращает количество категорий в модели.

        Args:
            parent: Родительский индекс модели.

        Returns:
            int: Количество категорий.
        """
        return len(self._categories)

    def data(self, index, role=Qt.DisplayRole):
        """
        Возвращает данные для указанного индекса и роли.

        Args:
            index: Индекс запрашиваемого элемента.
            role: Роль данных.

        Returns:
            Значение данных или None.
        """
        if not index.isValid() or not (0 <= index.row() < len(self._categories)):
            return None

        category = self._categories[index.row()]

        if role == self.IdRole:
            return category.id
        elif role == self.NameRole:
            return category.name
        elif role == self.PrefixRole:
            return category.sku_prefix
        elif role == self.DigitsRole:
            return category.sku_digits

        return None

    # ==================== Data Loading ====================

    def loadCategories(self):
        """
        Загружает категории из репозитория и обновляет модель.

        Испускает сигнал categoriesLoaded при успешной загрузке.
        """
        logger.info("Loading categories...")

        try:
            self.beginResetModel()
            self._categories = self.repository.get_all()
            self.endResetModel()

            logger.success(f"✅ Loaded {len(self._categories)} categories")
            self.categoriesLoaded.emit(len(self._categories))

        except Exception as e:
            logger.exception("❌ Failed to load categories")
            self.errorOccurred.emit(f"Ошибка загрузки категорий: {str(e)}")

    @Slot()
    def refresh(self):
        """
        Принудительно обновляет данные модели.
        """
        logger.info("Manual refresh triggered")
        self.loadCategories()

    # ==================== CRUD Operations ====================

    @Slot(str, str, int)
    def addCategory(self, name: str, sku_prefix: str, sku_digits: int):
        """
        Добавляет новую категорию в базу данных.

        Args:
            name: Название новой категории.
            sku_prefix: Префикс SKU для категории.
            sku_digits: Количество цифр в генерируемом SKU.
        """
        try:
            logger.info(
                f"Adding category: name='{name}', "
                f"prefix='{sku_prefix}', digits={sku_digits}"
            )

            # Валидация
            if not name or not name.strip():
                error_msg = "Название категории не может быть пустым"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            if not sku_prefix or not sku_prefix.strip():
                error_msg = "Префикс SKU не может быть пустым"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            if sku_digits < 1 or sku_digits > 10:
                error_msg = "Количество цифр должно быть от 1 до 10"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            # Создаем DTO объект
            category = Category(
                id=None,
                name=name.strip(),
                sku_prefix=sku_prefix.strip().upper(),
                sku_digits=sku_digits
            )

            # Добавляем через репозиторий
            category_id = self.repository.add(category)

            logger.success(f"✅ Category added: '{name}' (ID: {category_id})")

            # Обновляем модель
            self.loadCategories()

        except Exception as e:
            error_msg = f"Ошибка добавления категории: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(int, str, str, int)
    def updateCategory(
            self,
            category_id: int,
            new_name: str,
            sku_prefix: str,
            sku_digits: int
    ):
        """
        Обновляет существующую категорию в базе данных.

        Args:
            category_id: Идентификатор обновляемой категории.
            new_name: Новое название категории.
            sku_prefix: Новый префикс SKU.
            sku_digits: Новое количество цифр в SKU.
        """
        try:
            logger.info(
                f"Updating category {category_id}: name='{new_name}', "
                f"prefix='{sku_prefix}', digits={sku_digits}"
            )

            # Валидация
            if not new_name or not new_name.strip():
                error_msg = "Название категории не может быть пустым"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            if not sku_prefix or not sku_prefix.strip():
                error_msg = "Префикс SKU не может быть пустым"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            if sku_digits < 1 or sku_digits > 10:
                error_msg = "Количество цифр должно быть от 1 до 10"
                logger.warning(f"⚠️ Validation failed: {error_msg}")
                self.errorOccurred.emit(error_msg)
                return

            # Создаем DTO объект
            category = Category(
                id=category_id,
                name=new_name.strip(),
                sku_prefix=sku_prefix.strip().upper(),
                sku_digits=sku_digits
            )

            # Обновляем через репозиторий
            self.repository.update(category_id, category)

            logger.success(f"✅ Category {category_id} updated: '{new_name}'")

            # Обновляем модель
            self.loadCategories()

        except Exception as e:
            error_msg = f"Ошибка обновления категории: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    @Slot(int)
    def deleteCategory(self, category_id: int):
        """
        Удаляет категорию из базы данных по её идентификатору.

        Args:
            category_id: Идентификатор удаляемой категории.
        """
        try:
            logger.info(f"Deleting category: {category_id}")

            # Удаляем через репозиторий
            self.repository.delete(category_id)

            logger.success(f"✅ Category {category_id} deleted")

            # Обновляем модель
            self.loadCategories()

        except Exception as e:
            error_msg = f"Ошибка удаления категории: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)

    # ==================== Utility Methods ====================

    @Slot(int, result="QVariant")
    def get(self, idx: int):
        """
        Возвращает объект категории по индексу для использования в QML.

        Args:
            idx: Индекс категории в модели.

        Returns:
            dict: Словарь с данными категории или пустой словарь.
        """
        if 0 <= idx < len(self._categories):
            category = self._categories[idx]

            result = {
                'id': category.id,
                'name': category.name,
                'sku_prefix': category.sku_prefix,
                'sku_digits': category.sku_digits
            }

            logger.trace(f"Retrieved category data for index {idx}: {category.name}")
            return result

        logger.warning(f"⚠️ Invalid category index: {idx}")
        return {'id': -1, 'name': '', 'sku_prefix': '', 'sku_digits': 4}

    @Slot(str, result=int)
    def indexOfName(self, name: str) -> int:
        """
        Возвращает индекс категории по её названию.

        Args:
            name: Название категории.

        Returns:
            int: Индекс категории или -1, если не найдена.
        """
        for i, category in enumerate(self._categories):
            if category.name == name:
                logger.trace(f"Found category '{name}' at index {i}")
                return i

        logger.debug(f"Category '{name}' not found")
        return -1

    @Slot(str, result=int)
    def getCategoryIdByName(self, name: str) -> int:
        """
        Возвращает идентификатор категории по её названию.

        Args:
            name: Название категории.

        Returns:
            int: Идентификатор категории или -1, если не найдена.
        """
        for category in self._categories:
            if category.name == name:
                logger.trace(f"Found category '{name}' with ID {category.id}")
                return category.id

        logger.debug(f"Category '{name}' not found")
        return -1

    @Slot(int, result=str)
    def generateSkuForCategory(self, category_id: int) -> str:
        """
        Генерирует следующий уникальный SKU для указанной категории.

        Args:
            category_id: Идентификатор категории.

        Returns:
            str: Сгенерированный SKU или пустая строка при ошибке.
        """
        try:
            logger.debug(f"Generating SKU for category {category_id}")

            sku = self.repository.generate_next_sku(category_id)

            if sku:
                logger.info(f"🔢 Generated SKU: {sku} for category {category_id}")
                return sku
            else:
                logger.warning(f"⚠️ Failed to generate SKU for category {category_id}")
                return ""

        except Exception as e:
            logger.error(f"❌ Error generating SKU: {e}")
            return ""

    @Slot(int, result="QVariant")
    def getCategoryById(self, category_id: int):
        """
        Возвращает категорию по её ID.

        Args:
            category_id: Идентификатор категории.

        Returns:
            dict: Словарь с данными категории или пустой словарь.
        """
        for category in self._categories:
            if category.id == category_id:
                logger.trace(f"Found category with ID {category_id}: {category.name}")
                return {
                    'id': category.id,
                    'name': category.name,
                    'sku_prefix': category.sku_prefix,
                    'sku_digits': category.sku_digits
                }

        logger.warning(f"⚠️ Category with ID {category_id} not found")
        return {'id': -1, 'name': '', 'sku_prefix': '', 'sku_digits': 4}

    @Slot(result=int)
    def count(self) -> int:
        """
        Возвращает количество категорий.

        Returns:
            int: Количество категорий в модели.
        """
        return len(self._categories)

    @Slot(str, result=bool)
    def exists(self, name: str) -> bool:
        """
        Проверяет существование категории по имени.

        Args:
            name: Название категории.

        Returns:
            bool: True если категория существует, иначе False.
        """
        exists = any(category.name == name for category in self._categories)
        logger.trace(f"Category '{name}' exists: {exists}")
        return exists

    @Slot(result=list)
    def getAllNames(self):
        """
        Возвращает список всех названий категорий.

        Returns:
            list: Список названий категорий.
        """
        names = [category.name for category in self._categories]
        logger.trace(f"Retrieved {len(names)} category names")
        return names

    @Slot(result=list)
    def getAllPrefixes(self):
        """
        Возвращает список всех префиксов SKU.

        Returns:
            list: Список префиксов SKU.
        """
        prefixes = [category.sku_prefix for category in self._categories]
        logger.trace(f"Retrieved {len(prefixes)} SKU prefixes")
        return prefixes