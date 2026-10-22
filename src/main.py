"""Точка входа приложения PythonCode - Inventory Management System

Полная версия с Repository Pattern, Loguru, авторизацией и всеми компонентами
"""

import sys
import os
import ctypes
from pathlib import Path

# ДОБАВЛЯЕМ src/ в PYTHONPATH
src_path = Path(__file__).parent
if str(src_path) not in sys.path:
    sys.path.insert(0, str(src_path))

from PySide6.QtCore import QObject, Slot, QDir
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

# Repository Pattern
from repositories.unit_of_work import UnitOfWork
from utils.logger_config import setup_logging, get_logger

# Модели (обновленные)
from items_model import ItemsModel
from categories_model import CategoriesModel
from suppliers_model import SuppliersModel

# Спецификации
from specifications_model import SpecificationsModel
from specification_items_table_model import SpecificationItemsTableModel

# Модели (старые)
from filter_proxy_model import FilterProxyModel
from item_suppliers_model import ItemSuppliersModel
from suppliers_table_model import SuppliersTableModel
from item_documents_model import ItemDocumentsModel

# Менеджеры
from config_manager import ConfigManager
from file_manager import FileManager
from auth_manager import AuthManager

# Настраиваем логирование
setup_logging(log_level="DEBUG")
logger = get_logger()


class Backend(QObject):
    """Класс для взаимодействия с бэкендом через репозитории."""

    def __init__(self, uow: UnitOfWork, parent=None):
        super().__init__(parent)
        self.uow = uow
        logger.debug("Backend initialized")

    @Slot(str, result="QVariantList")
    def getSuppliersForItem(self, article: str):
        """Получение поставщиков для товара."""
        try:
            logger.debug(f"Getting suppliers for item: {article}")
            suppliers = self.uow.suppliers.get_suppliers_for_item(article)

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

            logger.info(f"Found {len(result)} suppliers for item {article}")
            return result
        except Exception as e:
            logger.error(f"Error getting suppliers: {e}")
            return []


class QMLConsoleHandler(QObject):
    """Обработчик console.log из QML."""

    @Slot(str)
    def log(self, message: str):
        logger.debug(f"QML: {message}")


def main():
    """Главная функция приложения."""

    logger.info("=" * 80)
    logger.info("🚀 Starting PythonCode Inventory Management System")
    logger.info("=" * 80)

    try:
        # Настройка стиля
        os.environ["QT_QUICK_CONTROLS_STYLE"] = "FluentWinUI3"

        # Идентификатор приложения Windows (чтобы иконка корректно отображалась на панели задач)
        try:
            myappid = "mycompany.warehouse.inventory.1.0"
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
        except Exception as e:
            logger.debug(f"Could not set AppUserModelID: {e}")

        # Инициализация Qt (ЕДИНСТВЕННЫЙ экземпляр)
        app = QGuiApplication(sys.argv)

        # Определение пути к ресурсам (в исходниках это папка src/, а в PyInstaller — _internal)
        if getattr(sys, "frozen", False):
            base_dir = Path(sys._MEIPASS)
        else:
            base_dir = Path(__file__).resolve().parent

        # Установка иконки приложения
        icon_path = base_dir / "files" / "warehouse_app_icon.ico"
        if icon_path.exists():
            app.setWindowIcon(QIcon(str(icon_path)))
            logger.success(f"✅ App icon loaded from: {icon_path}")
        else:
            logger.warning(f"⚠️ App icon not found at: {icon_path}")

        engine = QQmlApplicationEngine()
        logger.success("✅ Qt initialized")

        # Указываем папку приложения
        engine.rootContext().setContextProperty("applicationDirPath", str(base_dir))

        # === ФОРМИРУЕМ ПОЛНЫЕ ПУТИ К БАЗАМ И КОНФИГУ ===
        items_db_path = str(base_dir / "items.db")
        users_db_path = str(base_dir / "users.db")
        config_path = str(base_dir / "config.json")

        # Unit of Work (основная БД)
        uow = UnitOfWork(items_db_path)
        logger.success(f"✅ Unit of Work created (DB: {items_db_path})")

        # === АВТОРИЗАЦИЯ ===
        auth_manager = AuthManager(users_db_path)
        engine.rootContext().setContextProperty("authManager", auth_manager)
        logger.success(f"✅ AuthManager created (DB: {users_db_path})")

        # Менеджеры
        config_manager = ConfigManager(config_path)
        file_manager = FileManager(config_manager)
        logger.success("✅ Managers created")

        # Обновленные модели
        itemsModel = ItemsModel(uow.items)
        categoriesModel = CategoriesModel(uow.categories)
        suppliersModel = SuppliersModel(uow.suppliers)
        logger.success("✅ Main models created")

        # Модели спецификаций
        specificationItemsModel = SpecificationItemsTableModel()
        specificationsModel = SpecificationsModel(uow.specifications, specificationItemsModel)
        logger.success("✅ Specification models created")

        # Старые модели
        proxyModel = FilterProxyModel()
        proxyModel.setSourceModel(itemsModel)

        suppliersTableModel = SuppliersTableModel(uow.suppliers)
        logger.success("✅ SuppliersTableModel created")

        item_suppliers_model = ItemSuppliersModel(uow.suppliers)
        logger.success("✅ ItemSuppliersModel created")

        itemDocumentsModel = ItemDocumentsModel(uow.documents)
        logger.success("✅ ItemDocumentsModel created")

        logger.success("✅ Legacy models created")

        # Backend
        backend = Backend(uow)
        consoleHandler = QMLConsoleHandler()

        # Регистрация в QML
        engine.rootContext().setContextProperty("configManager", config_manager)
        engine.rootContext().setContextProperty("fileManager", file_manager)
        engine.rootContext().setContextProperty("backend", backend)
        engine.rootContext().setContextProperty("consoleHandler", consoleHandler)

        engine.rootContext().setContextProperty("sourceModel", itemsModel)
        engine.rootContext().setContextProperty("itemsModel", proxyModel)
        engine.rootContext().setContextProperty("categoryModel", categoriesModel)
        engine.rootContext().setContextProperty("suppliersModel", suppliersModel)
        engine.rootContext().setContextProperty("specificationsModel", specificationsModel)
        engine.rootContext().setContextProperty("specificationItemsModel", specificationItemsModel)

        engine.rootContext().setContextProperty("suppliersTableModel", suppliersTableModel)
        engine.rootContext().setContextProperty("itemSuppliersModel", item_suppliers_model)
        engine.rootContext().setContextProperty("itemDocumentsModel", itemDocumentsModel)
        logger.success("✅ All objects registered")

        # Регистрация типов QML
        qmlRegisterType(ItemSuppliersModel, "Models", 1, 0, "ItemSuppliersModel")

        # Console handler
        engine.loadData(b"""
        import QtQuick
        QtObject {
            function qmlLog(msg) {
                consoleHandler.log(msg)
            }
        }
        """)

        # Обработчик предупреждений
        def handle_qml_warnings(warnings):
            for warning in warnings:
                logger.warning(f"QML: {warning.toString()}")

        engine.warnings.connect(handle_qml_warnings)
        engine.setOutputWarningsToStandardError(True)

        # Загрузка QML
        qml_file = os.path.join(os.path.dirname(__file__), "qml", "main.qml")
        engine.load(qml_file)

        if not engine.rootObjects():
            logger.critical("❌ Failed to load QML!")
            return -1

        logger.success("🎉 Application started successfully!")
        return app.exec()

    except Exception as e:
        logger.exception("💥 Fatal error")
        return -1


if __name__ == "__main__":
    exit_code = main()
    logger.info(f"Application exited with code: {exit_code}")
    sys.exit(exit_code)