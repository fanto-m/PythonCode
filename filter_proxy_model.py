# filter_proxy_model.py (with sorting added)
from PySide6.QtCore import QSortFilterProxyModel, Slot, QSettings, Property, Qt  # Add Qt for sorting

from items_model import ItemsModel

class FilterProxyModel(QSortFilterProxyModel):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._filter_field = "name"
        self._filter_string = ""
        self._settings = QSettings("ООО ОЗТМ", "Склад-0.1")
        self._loadSettings()
        self.setDynamicSortFilter(True)  # Enable dynamic sorting
        print(f"DEBUG: FilterProxyModel initialized with filterField: {self._filter_field}")

    def get_filter_string(self):
        return self._filter_string

    def get_filter_field(self):
        return self._filter_field

    filterString = Property(str, get_filter_string, notify=None)
    filterField = Property(str, get_filter_field, notify=None)

    def _loadSettings(self):
        saved_field = self._settings.value("filterField", "name")
        saved_string = self._settings.value("filterString", "")
        self._filter_field = saved_field
        self._filter_string = saved_string.lower()
        print(f"DEBUG: Loaded filter settings: field={self._filter_field}, string='{self._filter_string}'")

    def _saveSettings(self):
        self._settings.setValue("filterField", self._filter_field)
        self._settings.setValue("filterString", self._filter_string)
        print(f"DEBUG: Saved filter settings: field={self._filter_field}, string='{self._filter_string}'")

    @Slot(str)
    def setFilterString(self, filterString):
        self._filter_string = filterString.lower()
        self.invalidateFilter()
        self._saveSettings()
        print(f"DEBUG: setFilterString called with: {self._filter_string}")

    @Slot(str)
    def setFilterField(self, field):
        self._filter_field = field
        self.invalidateFilter()
        self._saveSettings()
        print(f"DEBUG: setFilterField called with: {self._filter_field}")

    @Slot(str, str)
    def setSort(self, role_name, order="ascending"):
        role_map = {
            "article": ItemsModel.ArticleRole,
            "name": ItemsModel.NameRole,
            "description": ItemsModel.DescriptionRole,
            "category": ItemsModel.CategoryRole,
            "price": ItemsModel.PriceRole,
            "stock": ItemsModel.StockRole
        }
        role = role_map.get(role_name, ItemsModel.NameRole)
        order = Qt.AscendingOrder if order.lower() == "ascending" else Qt.DescendingOrder
        self.setSortRole(role)
        self.sort(0, order)  # Always column 0, as roles handle data
        print(f"DEBUG: Sorting set on role {role_name}, order: {order}")
        # Debug: Log visible rows after sorting
        for row in range(self.rowCount()):
            index = self.index(row, 0)
            source_index = self.mapToSource(index)
            value = self.sourceModel().data(source_index, role) if source_index.isValid() else None
            print(f"DEBUG: Row {row} (source row {source_index.row() if source_index.isValid() else -1}): {value}")
    def filterAcceptsRow(self, sourceRow, sourceParent):
        if not self.sourceModel():
            return False
        index = self.sourceModel().index(sourceRow, 0, sourceParent)
        if not index.isValid():
            return False
        #print(f"DEBUG: filterAcceptsRow called for row: {sourceRow}, filterField: {self._filter_field}, filterString: {self._filter_string}")
        if not self._filter_string:
            #print(f"DEBUG: Empty filter string, accepting row {sourceRow}")
            return True
        role_map = {
            "article": ItemsModel.ArticleRole,
            "name": ItemsModel.NameRole,
            "description": ItemsModel.DescriptionRole,
            "category": ItemsModel.CategoryRole,
            "price": ItemsModel.PriceRole,
            "stock": ItemsModel.StockRole
        }
        role = role_map.get(self._filter_field, ItemsModel.NameRole)
        value = self.sourceModel().data(index, role)
        value_str = "" if value is None else str(value).lower()
        print(f"DEBUG: Row {sourceRow}, field {self._filter_field}, value: {value_str}")
        result = self._filter_string in value_str
        print(f"DEBUG: Filter result for row {sourceRow}: {result}")
        return result

    @Slot(str, str, str, str, str, float, int, str)
    def addItem(self, article, name, description, image_path, category, price, stock,document=""):
        print("DEBUG: FilterProxyModel.addItem called, redirecting to sourceModel")
        try:
            price = float(price) if price is not None and str(price).strip() else 0.0
            stock = int(stock) if stock is not None and str(stock).strip() else 0
            self.sourceModel().addItem(article, name, description, image_path, category, price, stock, document)
            print("DEBUG: FilterProxyModel.addItem completed")
        except Exception as e:
            print(f"DEBUG: Error in FilterProxyModel.addItem: {str(e)}")

    @Slot(int, str, str, str, str, str, float, int, str, str, str, str)
    def updateItem(self, proxy_row, article, name, description, image_path, category, price, stock, status, unit, manufacturer, document):
        print(f"DEBUG: FilterProxyModel.updateItem called with proxy_row: {proxy_row}, redirecting to sourceModel")
        try:
            proxy_index = self.index(proxy_row, 0)
            if not proxy_index.isValid():
                raise ValueError(f"Invalid proxy index for row {proxy_row}")
            source_index = self.mapToSource(proxy_index)
            if not source_index.isValid():
                raise ValueError(f"Invalid source index for proxy row {proxy_row}")
            source_row = source_index.row()
            print(f"DEBUG: Mapped proxy_row {proxy_row} to source_row {source_row}")

            price = float(price) if price is not None and str(price).strip() else 0.0
            stock = int(stock) if stock is not None and str(stock).strip() else 0
            self.sourceModel().updateItem(source_row, article, name, description, image_path, category, price, stock, status, unit, manufacturer, document)
            print("DEBUG: FilterProxyModel.updateItem completed")
        except Exception as e:
            print(f"DEBUG: Error in FilterProxyModel.updateItem: {str(e)}")

    @Slot(int)
    def deleteItem(self, proxy_row):
        print(f"DEBUG: FilterProxyModel.deleteItem called with proxy_row: {proxy_row}, redirecting to sourceModel")
        try:
            proxy_index = self.index(proxy_row, 0)
            if not proxy_index.isValid():
                raise ValueError(f"Invalid proxy index for row {proxy_row}")
            source_index = self.mapToSource(proxy_index)
            if not source_index.isValid():
                raise ValueError(f"Invalid source index for proxy row {proxy_row}")
            source_row = source_index.row()
            print(f"DEBUG: Mapped proxy_row {proxy_row} to source_row {source_row}")

            self.sourceModel().deleteItem(source_row)
            print("DEBUG: FilterProxyModel.deleteItem completed")
        except Exception as e:
            print(f"DEBUG: Error in FilterProxyModel.deleteItem: {str(e)}")