import sys
import os
import json
from database import DatabaseManager
from PySide6.QtCore import QObject, Slot, QDir
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QQmlError, qmlRegisterType
from items_model import ItemsModel
from filter_proxy_model import FilterProxyModel
from categories_model import CategoriesModel
from suppliers_model import SuppliersModel
from item_suppliers_model import ItemSuppliersModel
from suppliers_table_model import SuppliersTableModel
from models.specification_models import SpecificationItemsModel, SpecificationsModel
from specification_items_table_model import SpecificationItemsTableModel
from config_manager import ConfigManager
from file_manager import FileManager
from item_documents_model import ItemDocumentsModel

class Backend(QObject):
    """Класс для взаимодействия с бэкендом приложения.

    Предоставляет методы для работы с данными через менеджер базы данных.
    Используется в QML для получения данных, например, списка поставщиков для товара.
    """

    def __init__(self, db_manager, parent=None):
        """Инициализация объекта бэкенда.

        Args:
            db_manager (DatabaseManager): Экземпляр менеджера базы данных.
            parent (QObject, optional): Родительский объект Qt. По умолчанию None.
        """
        super().__init__(parent)
        self.db = db_manager

    @Slot(str, result="QVariantList")
    def getSuppliersForItem(self, article):
        """Получение списка поставщиков для указанного артикула товара.

        Args:
            article (str): Артикул товара.

        Returns:
            list: Список словарей с данными поставщиков (id, name, company, email, phone, website).
        """
        suppliers = self.db.get_suppliers_for_item(article)
        return [
            {
                "id": s[0],
                "name": s[1],
                "company": s[2],
                "email": s[3],
                "phone": s[4],
                "website": s[5]
            }
            for s in suppliers
        ]

class QMLConsoleHandler(QObject):
    """Класс для обработки сообщений отладки из QML.

    Перенаправляет сообщения, переданные через QML console.log, в стандартный вывод Python.
    """

    @Slot(str)
    def log(self, message):
        """Выводит отладочное сообщение из QML в консоль Python.

        Args:
            message (str): Сообщение для вывода.
        """
        print(f"QML Debug: {message}")

if __name__ == "__main__":
    """Точка входа приложения.

    Инициализирует приложение, модели данных, менеджер конфигурации и QML-движок.
    Настраивает обработку ошибок и запускает основной QML-интерфейс.
    """
    # Установка стиля для Qt Quick Controls
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "FluentWinUI3"

    # Инициализация приложения Qt
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()



    # Установка текущей директории приложения в контекст QML
    current_dir = QDir.currentPath()
    engine.rootContext().setContextProperty("applicationDirPath", current_dir)

    # Инициализация менеджера базы данных
    db_manager = DatabaseManager("items.db")
    print("DEBUG: DatabaseManager initialized")

    # Инициализация моделей данных
    itemsModel = ItemsModel()
    # Создаем модель документов
    item_documents_model = ItemDocumentsModel(db_manager)

    proxyModel = FilterProxyModel()
    proxyModel.setSourceModel(itemsModel)
    categoriesModel = CategoriesModel()
    suppliersModel = SuppliersModel()
    suppliersTableModel = SuppliersTableModel()
    item_suppliers_model = ItemSuppliersModel()
    specification_items_model = SpecificationItemsModel(db_manager)
    specification_items_table_model = SpecificationItemsTableModel()
    specifications_model = SpecificationsModel(db_manager, specification_items_table_model)
    print("DEBUG: Specification models initialized")

    # Инициализация менеджера конфигурации
    config_manager = ConfigManager("config.json")
    print("DEBUG: Config manager initialized")
    # Создаем FileManager
    file_manager = FileManager(config_manager)
    # Инициализация бэкенда и обработчика консоли
    backend = Backend(db_manager)
    consoleHandler = QMLConsoleHandler()

    # Добавьте эту строку к существующим setContextProperty
    engine.rootContext().setContextProperty("fileManager", file_manager)

    # Регистрация объектов в контексте QML
    engine.rootContext().setContextProperty("configManager", config_manager)
    print("DEBUG: Config manager registered with QML context")
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("itemsModel", proxyModel)
    engine.rootContext().setContextProperty("sourceModel", itemsModel)
    engine.rootContext().setContextProperty("categoryModel", categoriesModel)
    engine.rootContext().setContextProperty("suppliersModel", suppliersModel)
    engine.rootContext().setContextProperty("suppliersTableModel", suppliersTableModel)
    engine.rootContext().setContextProperty("itemSuppliersModel", item_suppliers_model)
    engine.rootContext().setContextProperty("consoleHandler", consoleHandler)
    engine.rootContext().setContextProperty("specificationItemsModel", specification_items_table_model)
    engine.rootContext().setContextProperty("specificationsModel", specifications_model)
    # Регистрируем в QML контексте
    engine.rootContext().setContextProperty("itemDocumentsModel", item_documents_model)
    print("DEBUG: All models registered with QML context")

    # Регистрация типов для использования в QML
    qmlRegisterType(ItemSuppliersModel, "Models", 1, 0, "ItemSuppliersModel")

    # Переопределение console.log в QML для использования QMLConsoleHandler
    engine.loadData(b"""
        import QtQuick
        QtObject {
            Component.onCompleted: {
                var customConsole = {
                    log: function(msg) { consoleHandler.log(msg) },
                }
                console = customConsole
            }
        }
    """)

    # Настройка обработки предупреждений QML
    def handle_qml_warnings(warnings):
        """Обработка предупреждений и ошибок QML.

        Args:
            warnings (list): Список объектов QQmlError.
        """
        for warning in warnings:
            print(f"QML Warning/Error: {warning.toString()}")

    engine.warnings.connect(handle_qml_warnings)
    engine.setOutputWarningsToStandardError(True)
    print("QML debugging is enabled. Only use this in a safe environment.")

    # Загрузка главного QML-файла
    qml_file = os.path.join(os.path.dirname(__file__), "main.qml")
    engine.load(qml_file)

    # Проверка успешной загрузки QML
    if not engine.rootObjects():
        print("DEBUG: Failed to load QML file")
        sys.exit(-1)

    print("DEBUG: Application started successfully")
    sys.exit(app.exec())