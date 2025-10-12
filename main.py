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
from specification_items_table_model import SpecificationItemsTableModel  # NEW IMPORT
from config_manager import ConfigManager


class Backend(QObject):
    def __init__(self, db_manager, parent=None):
        super().__init__(parent)
        self.db = db_manager

    @Slot(str, result="QVariantList")
    def getSuppliersForItem(self, article):
        suppliers = self.db.get_suppliers_for_item(article)
        # Преобразуем кортежи в словари
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
    @Slot(str)
    def log(self, message):
        print(f"QML Debug: {message}")


if __name__ == "__main__":
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "FluentWinUI3"
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    # Получаем путь к директории приложения
    current_dir = QDir.currentPath()
    engine.rootContext().setContextProperty("applicationDirPath", current_dir)

    # ========================================
    # 1. INITIALIZE DATABASE FIRST
    # ========================================
    db_manager = DatabaseManager("items.db")
    print("DEBUG: DatabaseManager initialized")

    # ========================================
    # 2. INITIALIZE MODELS
    # ========================================

    # Items model
    itemsModel = ItemsModel()
    proxyModel = FilterProxyModel()
    proxyModel.setSourceModel(itemsModel)

    # Categories model
    categoriesModel = CategoriesModel()

    # Suppliers models
    suppliersModel = SuppliersModel()
    suppliersTableModel = SuppliersTableModel()

    # Item suppliers model
    item_suppliers_model = ItemSuppliersModel()

    # ========================================
    # 3. INITIALIZE SPECIFICATION MODELS
    # ========================================
    # Original list-based model (keep for compatibility if needed)
    specification_items_model = SpecificationItemsModel(db_manager)

    # NEW: Table-based model for improved performance
    specification_items_table_model = SpecificationItemsTableModel()

    specifications_model = SpecificationsModel(db_manager, specification_items_table_model)
    print("DEBUG: Specification models initialized")

    # ========================================
    # 4. INITIALIZE CONFIG MANAGER
    # ========================================
    config_manager = ConfigManager("config.json")
    print("DEBUG: Config manager initialized")

    # ========================================
    # 5. INITIALIZE BACKEND
    # ========================================
    backend = Backend(db_manager)
    consoleHandler = QMLConsoleHandler()

    # ========================================
    # 6. REGISTER WITH QML
    # ========================================

    # Register config manager FIRST (before other context properties)
    engine.rootContext().setContextProperty("configManager", config_manager)
    print("DEBUG: Config manager registered with QML context")

    # Register models as context properties
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("itemsModel", proxyModel)
    engine.rootContext().setContextProperty("sourceModel", itemsModel)
    engine.rootContext().setContextProperty("categoryModel", categoriesModel)
    engine.rootContext().setContextProperty("suppliersModel", suppliersModel)
    engine.rootContext().setContextProperty("suppliersTableModel", suppliersTableModel)
    engine.rootContext().setContextProperty("itemSuppliersModel", item_suppliers_model)
    engine.rootContext().setContextProperty("consoleHandler", consoleHandler)

    # Register specification models
    # Keep both for backward compatibility
    engine.rootContext().setContextProperty("specificationItemsModel", specification_items_table_model)
    engine.rootContext().setContextProperty("specificationsModel", specifications_model)

    print("DEBUG: All models registered with QML context")

    # Register types for QML
    qmlRegisterType(ItemSuppliersModel, "Models", 1, 0, "ItemSuppliersModel")

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

    # ========================================
    # 7. SETUP WARNING HANDLER
    # ========================================
    def handle_qml_warnings(warnings):
        for warning in warnings:
            print(f"QML Warning/Error: {warning.toString()}")


    engine.warnings.connect(handle_qml_warnings)
    engine.setOutputWarningsToStandardError(True)
    print("QML debugging is enabled. Only use this in a safe environment.")

    # ========================================
    # 8. LOAD QML
    # ========================================
    qml_file = os.path.join(os.path.dirname(__file__), "main.qml")
    engine.load(qml_file)

    if not engine.rootObjects():
        print("DEBUG: Failed to load QML file")
        sys.exit(-1)

    print("DEBUG: Application started successfully")
    sys.exit(app.exec())