"""Unit of Work - координатор всех репозиториев

Предоставляет единую точку доступа ко всем репозиториям
и обеспечивает их согласованную инициализацию.
"""

from loguru import logger

from repositories.categories_repository import CategoriesRepository  # ← ПРАВИЛЬНО
from repositories.suppliers_repository import SuppliersRepository  # ← ПРАВИЛЬНО
from repositories.items_repository import ItemsRepository  # ← ПРАВИЛЬНО
from repositories.documents_repository import DocumentsRepository  # ← ПРАВИЛЬНО
from repositories.specifications_repository import SpecificationsRepository  # ← ПРАВИЛЬНО


class UnitOfWork:
    """
    Unit of Work - паттерн для управления несколькими репозиториями.

    Предоставляет:
    - Единую точку доступа ко всем репозиториям
    - Автоматическую инициализацию всех таблиц БД
    - Координацию работы между репозиториями

    Attributes:
        categories: Репозиторий категорий
        suppliers: Репозиторий поставщиков
        items: Репозиторий товаров
        documents: Репозиторий документов
        specifications: Репозиторий спецификаций

    Example:
        >>> uow = UnitOfWork("items.db")
        >>> categories = uow.categories.get_all()
        >>> uow.items.add(item)
    """

    def __init__(self, db_path: str = "items.db"):
        """
        Инициализирует Unit of Work и все репозитории.

        Args:
            db_path: Путь к файлу базы данных SQLite.
        """
        self.db_path = db_path

        logger.info("=" * 80)
        logger.info("🚀 Initializing Unit of Work")
        logger.info(f"📁 Database path: {db_path}")
        logger.info("=" * 80)

        # Создаем все репозитории
        self.categories = CategoriesRepository(db_path)
        self.suppliers = SuppliersRepository(db_path)
        self.items = ItemsRepository(db_path)
        self.documents = DocumentsRepository(db_path)
        self.specifications = SpecificationsRepository(db_path)

        logger.info("📦 All repositories initialized")

        # Инициализируем структуру БД
        self._init_database()

        logger.success("✅ Unit of Work ready")
        logger.info("=" * 80)

    def _init_database(self):
        """Инициализирует все таблицы в базе данных."""
        logger.info("🔧 Initializing database structure...")

        try:
            # Создаем таблицы в правильном порядке (с учетом зависимостей)
            self.categories.create_table()
            self.suppliers.create_table()
            self.items.create_table()
            self.documents.create_table()
            self.specifications.create_table()

            logger.success("✅ Database structure initialized")

        except Exception as e:
            logger.critical(f"💥 Critical error initializing database: {e}")
            raise

    def migrate_documents(self) -> int:
        """
        Выполняет миграцию документов из старой структуры в новую.

        Этот метод должен быть вызван один раз после обновления кода.

        Returns:
            int: Количество мигрированных документов.
        """
        logger.info("🔄 Starting document migration...")
        count = self.documents.migrate_from_items_table()
        logger.success(f"✅ Migration completed: {count} document(s)")
        return count

    def __repr__(self):
        """Строковое представление Unit of Work."""
        return f"UnitOfWork(db_path='{self.db_path}')"