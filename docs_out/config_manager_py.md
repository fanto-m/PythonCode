# Module `config_manager.py`


## Class `ConfigManager`


Manages application configuration settings.
Stores settings in a JSON file and provides Qt property bindings for QML.


### `ConfigManager.__init__(self, config_path, parent)`


_No docstring._


### `ConfigManager._load_default_config(self)`


Return default configuration values.


### `ConfigManager._load_config(self)`


Load configuration from file, or create with defaults if not exists.


### `ConfigManager._save_config(self)`


Save current configuration to file.


### `ConfigManager._get_vat_included(self)`


_No docstring._


### `ConfigManager._set_vat_included(self, value)`


_No docstring._


### `ConfigManager._get_vat_rate(self)`


_No docstring._


### `ConfigManager._set_vat_rate(self, value)`


_No docstring._


### `ConfigManager._get_default_currency(self)`


_No docstring._


### `ConfigManager._set_default_currency(self, value)`


_No docstring._


### `ConfigManager.getSetting(self, key)`


Get a configuration setting by key.


### `ConfigManager.setSetting(self, key, value)`


Set a configuration setting by key.


### `ConfigManager.calculatePriceWithoutVAT(self, price_with_vat)`


Calculate price without VAT from price with VAT.


### `ConfigManager.calculatePriceWithVAT(self, price_without_vat)`


Calculate price with VAT from price without VAT.


### `ConfigManager.resetToDefaults(self)`


Reset all settings to default values.

