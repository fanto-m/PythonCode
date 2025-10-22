# main.py

Основной файл приложения для инициализации и запуска Qt/QML-приложения, управляющего данными товаров, поставщиков, категорий и спецификаций.

---

## Импорты

- `sys`: Модуль для работы с системными параметрами и функциями.
- `os`: Модуль для работы с операционной системой (например, для обработки путей к файлам).
- `json`: Модуль для работы с JSON-данными.
- `database.DatabaseManager`: Менеджер для взаимодействия с базой данных.
- `PySide6.QtCore`: Предоставляет базовые классы Qt (`QObject`, `Slot`, `QDir`).
- `PySide6.QtGui`: Предоставляет классы для работы с графическим интерфейсом (`QGuiApplication`).
- `PySide6.QtQml`: Предоставляет классы для работы с QML (`QQmlApplicationEngine`, `QQmlError`, `qmlRegisterType`).
- `items_model.ItemsModel`: Модель данных для товаров.
- `filter_proxy_model.FilterProxyModel`: Прокси-модель для фильтрации и сортировки товаров.
- `categories_model.CategoriesModel`: Модель данных для категорий.
- `suppliers_model.SuppliersModel`: Модель данных для списка поставщиков.
- `item_suppliers_model.ItemSuppliersModel`: Модель данных для поставщиков, связанных с товаром.
- `suppliers_table_model.SuppliersTableModel`: Табличная модель данных для поставщиков.
- `models.specification_models`: Модели для работы со спецификациями (`SpecificationItemsModel`, `SpecificationsModel`).
- `specification_items_table_model.SpecificationItemsTableModel`: Табличная модель для элементов спецификаций.
- `config_manager.ConfigManager`: Менеджер конфигурации приложения.

---

## Класс `Backend`

Класс для взаимодействия с бэкендом приложения. Предоставляет методы для работы с данными через менеджер базы данных, используемые в QML-интерфейсе.

### Методы

#### `__init__(self, db_manager, parent=None)`

Инициализирует объект бэкенда.

**Параметры:**  
- `db_manager (DatabaseManager)`: Экземпляр менеджера базы данных.
- `parent (QObject, optional)`: Родительский объект Qt. По умолчанию `None`.

---

#### `getSuppliersForItem(self, article)`

Получает список поставщиков для указанного артикула товара.

**Параметры:**  
- `article (str)`: Артикул товара.

**Возвращает:**  
- `list`: Список словарей с данными поставщиков (`id`, `name`, `company`, `email`, `phone`, `website`).

---

## Класс `QMLConsoleHandler`

Класс для обработки сообщений отладки из QML. Перенаправляет сообщения QML `console.log` в стандартный вывод Python.

### Методы

#### `log(self, message)`

Выводит отладочное сообщение из QML в консоль Python.

**Параметры:**  
- `message (str)`: Сообщение для вывода.