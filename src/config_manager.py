# config_manager.py - ОБНОВЛЕННАЯ ВЕРСИЯ с настройками файловой структуры
import json
import os
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property


class ConfigManager(QObject):
    """Менеджер конфигурации приложения.

    Сохраняет настройки в JSON-файл и предоставляет привязки к свойствам Qt для QML.
    Поддерживает реактивное обновление интерфейса при изменении настроек.

    НОВОЕ: Управляет структурой каталогов для хранения файлов.

    Сигналы:
        vatIncludedChanged(bool): Изменилось включение НДС в цены.
        defaultCurrencyChanged(str): Изменилась валюта по умолчанию.
        vatRateChanged(float): Изменилась ставка НДС (в процентах).
    """

    # Signals for property changes
    vatIncludedChanged = Signal(bool)
    defaultCurrencyChanged = Signal(str)
    vatRateChanged = Signal(float)

    def __init__(self, config_path="config.json", parent=None):
        """Инициализирует менеджер конфигурации.

        Загружает настройки из файла или создаёт файл с настройками по умолчанию.

        Args:
            config_path (str, optional): Путь к файлу конфигурации. По умолчанию "config.json".
            parent (QObject, optional): Родительский объект Qt. По умолчанию None.
        """
        super().__init__(parent)
        self._config_path = config_path
        self._config = self._load_default_config()
        self._load_config()

    def _load_default_config(self):
        """Возвращает словарь настроек по умолчанию.

        Returns:
            dict: Словарь с ключами:
                - "vat_included" (bool)
                - "vat_rate" (float)
                - "default_currency" (str)
                - "decimal_places" (int)
                - "theme" (str)
                - "file_storage" (dict): Настройки структуры хранения файлов
        """
        return {
            "vat_included": True,
            "vat_rate": 20.0,
            "default_currency": "RUB",
            "decimal_places": 2,
            "theme": "light",

            # ИЗМЕНЕНО: Минимальная структура - детали берутся из config.json
            "file_storage": {
                "root_directory": "files",
                "images": {
                    "directory": "images",
                    "subdirectories": {}  # Пустой словарь - будет заполнен из config.json
                },
                "documents": {
                    "directory": "documents",
                    "subdirectories": {}  # Пустой словарь - будет заполнен из config.json
                }
            }
        }

    def _load_config(self):
        """Загружает конфигурацию из файла или создаёт файл с настройками по умолчанию.

        Если файл существует — читает его и объединяет с настройками по умолчанию
        (для поддержки новых параметров при обновлении приложения).
        Если файл отсутствует — создаёт его.
        """
        if os.path.exists(self._config_path):
            try:
                with open(self._config_path, 'r', encoding='utf-8') as f:
                    loaded_config = json.load(f)

                # Deep merge with defaults to handle new settings
                self._deep_merge(self._config, loaded_config)

                # СПЕЦИАЛЬНАЯ ОБРАБОТКА: subdirectories берём ТОЛЬКО из config.json
                # (не мержим с defaults, а заменяем полностью)
                if "file_storage" in loaded_config:
                    fs_loaded = loaded_config["file_storage"]

                    # Для images subdirectories
                    if "images" in fs_loaded and "subdirectories" in fs_loaded["images"]:
                        self._config["file_storage"]["images"]["subdirectories"] = fs_loaded["images"]["subdirectories"]
                        print(
                            f"DEBUG: Loaded {len(fs_loaded['images']['subdirectories'])} image subdirectories from config")

                    # Для documents subdirectories
                    if "documents" in fs_loaded and "subdirectories" in fs_loaded["documents"]:
                        self._config["file_storage"]["documents"]["subdirectories"] = fs_loaded["documents"][
                            "subdirectories"]
                        print(
                            f"DEBUG: Loaded {len(fs_loaded['documents']['subdirectories'])} document subdirectories from config")

                print(f"DEBUG: Config loaded from {self._config_path}")

            except Exception as e:
                print(f"ERROR: Failed to load config: {e}")
                print("DEBUG: Using default configuration")
        else:
            print(f"DEBUG: Config file not found, creating with defaults")
            self._save_config()

    def _deep_merge(self, default, loaded):
        """Глубокое слияние двух словарей (рекурсивное).

        Args:
            default (dict): Словарь с настройками по умолчанию.
            loaded (dict): Загруженный словарь.
        """
        for key, value in loaded.items():
            if key in default and isinstance(default[key], dict) and isinstance(value, dict):
                self._deep_merge(default[key], value)
            else:
                default[key] = value

    def _save_config(self):
        """Сохраняет текущую конфигурацию в JSON-файл.

        Использует читаемый формат (indent=4, ensure_ascii=False).
        """
        try:
            with open(self._config_path, 'w', encoding='utf-8') as f:
                json.dump(self._config, f, indent=4, ensure_ascii=False)
            print(f"DEBUG: Config saved to {self._config_path}")
        except Exception as e:
            print(f"ERROR: Failed to save config: {e}")

    # VAT Included Property
    def _get_vat_included(self):
        """Возвращает флаг включения НДС в цены.

        Returns:
            bool: True, если НДС включён в отображаемые цены.
        """
        return self._config.get("vat_included", True)

    def _set_vat_included(self, value: object) -> None:
        """Устанавливает флаг включения НДС и сохраняет конфигурацию.

        Args:
            value (bool): Новое значение флага.
        """
        if self._config.get("vat_included") != value:
            self._config["vat_included"] = value
            self._save_config()
            self.vatIncludedChanged.emit(value)
            print(f"DEBUG: VAT included set to {value}")

    vatIncluded = Property(bool, _get_vat_included, _set_vat_included, notify=vatIncludedChanged)
    """Флаг, включён ли НДС в отображаемые цены (True) или нет (False)."""

    # VAT Rate Property
    def _get_vat_rate(self):
        """Возвращает текущую ставку НДС.

        Returns:
            float: Ставка НДС в процентах (например, 20.0).
        """
        return self._config.get("vat_rate", 20.0)

    def _set_vat_rate(self, value):
        """Устанавливает новую ставку НДС и сохраняет конфигурацию.

        Args:
            value (float): Новая ставка НДС в процентах.
        """
        if self._config.get("vat_rate") != value:
            self._config["vat_rate"] = value
            self._save_config()
            self.vatRateChanged.emit(value)
            print(f"DEBUG: VAT rate set to {value}%")

    vatRate = Property(float, _get_vat_rate, _set_vat_rate, notify=vatRateChanged)
    """Текущая ставка НДС в процентах (например, 20.0)."""

    # Default Currency Property
    def _get_default_currency(self):
        """Возвращает валюту по умолчанию.

        Returns:
            str: Код валюты (например, "RUB", "USD", "EUR").
        """
        return self._config.get("default_currency", "RUB")

    def _set_default_currency(self, value):
        """Устанавливает валюту по умолчанию и сохраняет конфигурацию.

        Args:
            value (str): Новый код валюты.
        """
        if self._config.get("default_currency") != value:
            self._config["default_currency"] = value
            self._save_config()
            self.defaultCurrencyChanged.emit(value)
            print(f"DEBUG: Default currency set to {value}")

    defaultCurrency = Property(str, _get_default_currency, _set_default_currency,
                               notify=defaultCurrencyChanged)
    """Валюта по умолчанию (например, "RUB", "USD")."""

    # НОВЫЕ МЕТОДЫ: Работа с файловой структурой

    @Slot(result=str)
    def getFilesRootDirectory(self):
        """Возвращает корневую директорию для хранения файлов.

        Returns:
            str: Имя корневой директории (например, "files").
        """
        return self._config.get("file_storage", {}).get("root_directory", "files")

    @Slot(result=str)
    def getImagesDirectory(self):
        """Возвращает имя директории для изображений.

        Returns:
            str: Имя директории изображений (например, "images").
        """
        return self._config.get("file_storage", {}).get("images", {}).get("directory", "images")

    @Slot(result=str)
    def getDocumentsDirectory(self):
        """Возвращает имя директории для документов.

        Returns:
            str: Имя директории документов (например, "documents").
        """
        return self._config.get("file_storage", {}).get("documents", {}).get("directory", "documents")

    @Slot(result="QVariantList")
    def getImageSubdirectories(self):
        """Возвращает список поддиректорий для изображений.

        Returns:
            list: Список словарей с ключами 'name' и 'display_name'.
        """
        subdirs = self._config.get("file_storage", {}).get("images", {}).get("subdirectories", {})
        result = []
        for key, value in subdirs.items():
            result.append({
                "id": key,
                "name": value.get("name", key),
                "display_name": value.get("display_name", key.capitalize())
            })
        return result

    @Slot(result="QVariantList")
    def getDocumentSubdirectories(self):
        """Возвращает список поддиректорий для документов.

        Returns:
            list: Список словарей с ключами 'name' и 'display_name'.
        """
        subdirs = self._config.get("file_storage", {}).get("documents", {}).get("subdirectories", {})
        result = []
        for key, value in subdirs.items():
            result.append({
                "id": key,
                "name": value.get("name", key),
                "display_name": value.get("display_name", key.capitalize())
            })
        return result

    @Slot(str, result=str)
    def getImageSubdirectoryDisplayName(self, subdir_id):
        """Возвращает отображаемое имя поддиректории изображений.

        Args:
            subdir_id (str): ID поддиректории.

        Returns:
            str: Отображаемое имя или сам ID, если не найдено.
        """
        subdirs = self._config.get("file_storage", {}).get("images", {}).get("subdirectories", {})
        return subdirs.get(subdir_id, {}).get("display_name", subdir_id.capitalize())

    @Slot(str, result=str)
    def getDocumentSubdirectoryDisplayName(self, subdir_id):
        """Возвращает отображаемое имя поддиректории документов.

        Args:
            subdir_id (str): ID поддиректории.

        Returns:
            str: Отображаемое имя или сам ID, если не найдено.
        """
        subdirs = self._config.get("file_storage", {}).get("documents", {}).get("subdirectories", {})
        return subdirs.get(subdir_id, {}).get("display_name", subdir_id.capitalize())

    def get_file_storage_config(self):
        """Возвращает всю конфигурацию файлового хранилища (для FileManager).

        Returns:
            dict: Словарь с настройками файлового хранилища.
        """
        return self._config.get("file_storage", {})

    # Существующие Slot методы для QML
    @Slot(str, result="QVariant")
    def getSetting(self, key):
        """Возвращает значение настройки по ключу.

        Args:
            key (str): Имя параметра конфигурации.

        Returns:
            Любое: Значение параметра или None, если ключ не найден.
        """
        return self._config.get(key)

    @Slot(str, "QVariant")
    def setSetting(self, key, value):
        """Устанавливает значение настройки по ключу и сохраняет конфигурацию.

        Args:
            key (str): Имя параметра.
            value (Any): Новое значение параметра.
        """
        if self._config.get(key) != value:
            self._config[key] = value
            self._save_config()
            print(f"DEBUG: Setting '{key}' set to {value}")

    @Slot(float, result=float)
    def calculatePriceWithoutVAT(self, price_with_vat):
        """Рассчитывает цену без НДС по цене с НДС.

        Args:
            price_with_vat (float): Цена с НДС.

        Returns:
            float: Цена без НДС, округлённая до 2 знаков.
        """
        vat_rate = self._get_vat_rate()
        result = round(price_with_vat / (1 + vat_rate / 100), 2)
        print(f"DEBUG: Calculate price without VAT: {price_with_vat} -> {result} (rate: {vat_rate}%)")
        return result

    @Slot(float, result=float)
    def calculatePriceWithVAT(self, price_without_vat):
        """Рассчитывает цену с НДС по цене без НДС.

        Args:
            price_without_vat (float): Цена без НДС.

        Returns:
            float: Цена с НДС, округлённая до 2 знаков.
        """
        vat_rate = self._get_vat_rate()
        return round(price_without_vat * (1 + vat_rate / 100), 2)

    @Slot()
    def resetToDefaults(self):
        """Сбрасывает все настройки к значениям по умолчанию.

        Перезаписывает конфигурацию и испускает все сигналы изменения.
        """
        self._config = self._load_default_config()
        self._save_config()
        # Emit all change signals
        self.vatIncludedChanged.emit(self._config["vat_included"])
        self.vatRateChanged.emit(self._config["vat_rate"])
        self.defaultCurrencyChanged.emit(self._config["default_currency"])
        print("DEBUG: Configuration reset to defaults")

    @Slot()
    def reloadConfig(self):
        """Перезагружает конфигурацию из файла"""
        try:
            print("=== ConfigManager: Reloading config from file ===")

            if os.path.exists(self._config_path):
                with open(self._config_path, 'r', encoding='utf-8') as f:
                    loaded_config = json.load(f)

                # Сбрасываем на defaults, затем применяем загруженные настройки
                self._config = self._load_default_config()
                self._deep_merge(self._config, loaded_config)

                print("Config reloaded successfully")

                # Выводим количество подкатегорий
                img_subdirs = self.getImageSubdirectories()
                doc_subdirs = self.getDocumentSubdirectories()
                print(f"Images subdirectories: {len(img_subdirs)}")
                print(f"Documents subdirectories: {len(doc_subdirs)}")

                # Испускаем сигналы об изменениях
                self.vatIncludedChanged.emit(self._config["vat_included"])
                self.vatRateChanged.emit(self._config["vat_rate"])
                self.defaultCurrencyChanged.emit(self._config["default_currency"])

            else:
                print(f"ERROR: Config file not found: {self._config_path}")

        except Exception as e:
            print(f"ERROR: Failed to reload config: {e}")
            import traceback
            traceback.print_exc()