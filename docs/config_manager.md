# File: `config_manager.py`

### Imports
PySide6.QtCore, json, os

## Class `ConfigManager`
Manages application configuration settings.
Stores settings in a JSON file and provides Qt property bindings for QML.

### Method `__init__(self, config_path = 'config.json', parent = None)`
_No docstring._

### Method `_load_default_config(self)`
Return default configuration values.

### Method `_load_config(self)`
Load configuration from file, or create with defaults if not exists.

### Method `_save_config(self)`
Save current configuration to file.

### Method `_get_vat_included(self)`
_No docstring._

### Method `_set_vat_included(self, value)`
_No docstring._

### Method `_get_vat_rate(self)`
_No docstring._

### Method `_set_vat_rate(self, value)`
_No docstring._

### Method `_get_default_currency(self)`
_No docstring._

### Method `_set_default_currency(self, value)`
_No docstring._

### Method `getSetting(self, key)`
Get a configuration setting by key.

### Method `setSetting(self, key, value)`
Set a configuration setting by key.

### Method `calculatePriceWithoutVAT(self, price_with_vat)`
Calculate price without VAT from price with VAT.

### Method `calculatePriceWithVAT(self, price_without_vat)`
Calculate price with VAT from price without VAT.

### Method `resetToDefaults(self)`
Reset all settings to default values.
