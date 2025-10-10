# config_manager.py
import json
import os
from PySide6.QtCore import QObject, Signal, Slot, Property


class ConfigManager(QObject):
    """
    Manages application configuration settings.
    Stores settings in a JSON file and provides Qt property bindings for QML.
    """

    # Signals for property changes
    vatIncludedChanged = Signal(bool)
    defaultCurrencyChanged = Signal(str)
    vatRateChanged = Signal(float)

    def __init__(self, config_path="config.json", parent=None):
        super().__init__(parent)
        self._config_path = config_path
        self._config = self._load_default_config()
        self._load_config()

    def _load_default_config(self):
        """Return default configuration values."""
        return {
            "vat_included": True,
            "vat_rate": 20.0,  # Default VAT rate percentage
            "default_currency": "RUB",
            "decimal_places": 2,
            "theme": "light"
        }

    def _load_config(self):
        """Load configuration from file, or create with defaults if not exists."""
        if os.path.exists(self._config_path):
            try:
                with open(self._config_path, 'r', encoding='utf-8') as f:
                    loaded_config = json.load(f)
                    # Merge with defaults to handle new settings
                    self._config.update(loaded_config)
                    print(f"DEBUG: Config loaded from {self._config_path}")
            except Exception as e:
                print(f"ERROR: Failed to load config: {e}")
                print("DEBUG: Using default configuration")
        else:
            print(f"DEBUG: Config file not found, creating with defaults")
            self._save_config()

    def _save_config(self):
        """Save current configuration to file."""
        try:
            with open(self._config_path, 'w', encoding='utf-8') as f:
                json.dump(self._config, f, indent=4, ensure_ascii=False)
            print(f"DEBUG: Config saved to {self._config_path}")
        except Exception as e:
            print(f"ERROR: Failed to save config: {e}")

    # VAT Included Property
    def _get_vat_included(self):
        return self._config.get("vat_included", True)

    def _set_vat_included(self, value):
        if self._config.get("vat_included") != value:
            self._config["vat_included"] = value
            self._save_config()
            self.vatIncludedChanged.emit(value)
            print(f"DEBUG: VAT included set to {value}")

    vatIncluded = Property(bool, _get_vat_included, _set_vat_included, notify=vatIncludedChanged)

    # VAT Rate Property
    def _get_vat_rate(self):
        return self._config.get("vat_rate", 20.0)

    def _set_vat_rate(self, value):
        if self._config.get("vat_rate") != value:
            self._config["vat_rate"] = value
            self._save_config()
            self.vatRateChanged.emit(value)
            print(f"DEBUG: VAT rate set to {value}%")

    vatRate = Property(float, _get_vat_rate, _set_vat_rate, notify=vatRateChanged)

    # Default Currency Property
    def _get_default_currency(self):
        return self._config.get("default_currency", "RUB")

    def _set_default_currency(self, value):
        if self._config.get("default_currency") != value:
            self._config["default_currency"] = value
            self._save_config()
            self.defaultCurrencyChanged.emit(value)
            print(f"DEBUG: Default currency set to {value}")

    defaultCurrency = Property(str, _get_default_currency, _set_default_currency,
                               notify=defaultCurrencyChanged)

    # Slot methods for QML
    @Slot(str, result="QVariant")
    def getSetting(self, key):
        """Get a configuration setting by key."""
        return self._config.get(key)

    @Slot(str, "QVariant")
    def setSetting(self, key, value):
        """Set a configuration setting by key."""
        if self._config.get(key) != value:
            self._config[key] = value
            self._save_config()
            print(f"DEBUG: Setting '{key}' set to {value}")

    @Slot(float, result=float)
    def calculatePriceWithoutVAT(self, price_with_vat):
        """Calculate price without VAT from price with VAT."""
        vat_rate = self._get_vat_rate()
        result = price_with_vat / (1 + vat_rate / 100)
        print(f"DEBUG: Calculate price without VAT: {price_with_vat} -> {result} (rate: {vat_rate}%)")
        return result

    @Slot(float, result=float)
    def calculatePriceWithVAT(self, price_without_vat):
        """Calculate price with VAT from price without VAT."""
        vat_rate = self._get_vat_rate()
        return price_without_vat * (1 + vat_rate / 100)

    @Slot()
    def resetToDefaults(self):
        """Reset all settings to default values."""
        self._config = self._load_default_config()
        self._save_config()
        # Emit all change signals
        self.vatIncludedChanged.emit(self._config["vat_included"])
        self.vatRateChanged.emit(self._config["vat_rate"])
        self.defaultCurrencyChanged.emit(self._config["default_currency"])
        print("DEBUG: Configuration reset to defaults")