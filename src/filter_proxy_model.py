# filter_proxy_model.py
from PySide6.QtCore import QSortFilterProxyModel, Slot, QSettings, Property, Qt
from items_model import ItemsModel

class FilterProxyModel(QSortFilterProxyModel):
    """Прокси-модель для фильтрации и сортировки данных из ItemsModel.

    Эта модель расширяет QSortFilterProxyModel, предоставляя функциональность
    для фильтрации данных по указанному полю и строке фильтра, а также
    для сортировки данных. Поддерживает сохранение и загрузку настроек
    фильтрации через QSettings. Также предоставляет методы для добавления,
    обновления и удаления элементов, перенаправляя их в исходную модель.
    """

    def __init__(self, parent=None):
        """Инициализация прокси-модели.

        Args:
            parent: Родительский объект (по умолчанию None).
        """
        super().__init__(parent)
        self._filter_field = "name"  # Поле для фильтрации по умолчанию
        self._filter_string = ""     # Строка фильтра по умолчанию
        self._settings = QSettings("ООО ОЗТМ", "Склад-0.1")  # Настройки приложения
        self._loadSettings()  # Загрузка сохраненных настроек
        self.setDynamicSortFilter(True)  # Включение динамической сортировки
        print(f"DEBUG: FilterProxyModel initialized with filterField: {self._filter_field}")

    def get_filter_string(self):
        """Получение текущей строки фильтра.

        Returns:
            str: Текущая строка фильтра.
        """
        return self._filter_string

    def get_filter_field(self):
        """Получение текущего поля фильтрации.

        Returns:
            str: Текущее поле фильтрации.
        """
        return self._filter_field

    filterString = Property(str, get_filter_string, notify=None)
    filterField = Property(str, get_filter_field, notify=None)

    def _loadSettings(self):
        """Загрузка настроек фильтрации из QSettings.

        Загружает сохраненные значения поля фильтрации и строки фильтра.
        Если настройки отсутствуют, используются значения по умолчанию.
        """
        saved_field = self._settings.value("filterField", "name")
        saved_string = self._settings.value("filterString", "")
        self._filter_field = saved_field
        self._filter_string = saved_string.lower()
        print(f"DEBUG: Loaded filter settings: field={self._filter_field}, string='{self._filter_string}'")

    def _saveSettings(self):
        """Сохранение настроек фильтрации в QSettings.

        Сохраняет текущее поле фильтрации и строку фильтра.
        """
        self._settings.setValue("filterField", self._filter_field)
        self._settings.setValue("filterString", self._filter_string)
        print(f"DEBUG: Saved filter settings: field={self._filter_field}, string='{self._filter_string}'")

    @Slot(str)
    def setFilterString(self, filterString):
        """Установка строки фильтра.

        Args:
            filterString (str): Новая строка фильтра.

        Обновляет строку фильтра, вызывает инвалидацию фильтра и сохраняет настройки.
        """
        self._filter_string = filterString.lower()
        self.invalidateFilter()
        self._saveSettings()
        print(f"DEBUG: setFilterString called with: {self._filter_string}")

    @Slot(str)
    def setFilterField(self, field):
        """Установка поля фильтрации.

        Args:
            field (str): Новое поле для фильтрации.

        Обновляет поле фильтрации, вызывает инвалидацию фильтра и сохраняет настройки.
        """
        self._filter_field = field
        self.invalidateFilter()
        self._saveSettings()
        print(f"DEBUG: setFilterField called with: {self._filter_field}")

    @Slot(str, str)
    def setSort(self, role_name, order="ascending"):
        """Установка сортировки данных.

        Args:
            role_name (str): Имя роли (поля) для сортировки.
            order (str): Порядок сортировки ("ascending" или "descending").

        Устанавливает роль сортировки и порядок, затем сортирует данные.
        Выводит отладочную информацию о значениях в отсортированных строках.
        """
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
        self.sort(0, order)
        print(f"DEBUG: Sorting set on role {role_name}, order: {order}")
        for row in range(self.rowCount()):
            index = self.index(row, 0)
            source_index = self.mapToSource(index)
            value = self.sourceModel().data(source_index, role) if source_index.isValid() else None
            print(f"DEBUG: Row {row} (source row {source_index.row() if source_index.isValid() else -1}): {value}")

    def filterAcceptsRow(self, sourceRow, sourceParent):
        """Проверка, проходит ли строка фильтр.

        Args:
            sourceRow (int): Индекс строки в исходной модели.
            sourceParent: Родительский индекс в исходной модели.

        Returns:
            bool: True, если строка проходит фильтр, иначе False.

        Проверяет, содержит ли значение в указанном поле фильтрации подстроку
        из строки фильтра. Выводит отладочную информацию о результате.
        """
        if not self.sourceModel():
            return False
        index = self.sourceModel().index(sourceRow, 0, sourceParent)
        if not index.isValid():
            return False
        if not self._filter_string:
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
        #print(f"DEBUG: Row {sourceRow}, field {self._filter_field}, value: {value_str}")
        result = self._filter_string in value_str
        #print(f"DEBUG: Filter result for row {sourceRow}: {result}")
        return result

    @Slot(str, str, str, str, int, float, int, str, str, str, str)
    def addItem(self, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document):
        """Добавление нового элемента в исходную модель.

        Args:
            article (str): Артикул элемента.
            name (str): Название элемента.
            description (str): Описание элемента.
            image_path (str): Путь к изображению.
            category_id (int): Идентификатор категории.
            price (float): Цена элемента.
            stock (int): Количество на складе.
            status (str): Статус элемента.
            unit (str): Единица измерения.
            manufacturer (str): Производитель.
            document (str): Документ, связанный с элементом.

        Returns:
            Результат выполнения метода addItem исходной модели или сообщение об ошибке.

        Выполняет безопасное преобразование типов и вызывает метод добавления
        в исходной модели. Выводит отладочную информацию.
        """
        print(f"DEBUG: FilterProxyModel.addItem called with category_id={category_id}")
        print(
            f"addItem called with: article={article}, name={name}, description={description}, image_path={image_path}, category_id={category_id}, price={price}, stock={stock}, status={status}, unit={unit}, manufacturer={manufacturer}, document={document}")
        try:
            price = float(price) if price else 0.0
            stock = int(stock) if stock else 0
            result = self.sourceModel().addItem(
                article, name, description, image_path, category_id,
                price, stock, status, unit, manufacturer, document
            )
            print(f"DEBUG: FilterProxyModel.addItem completed with result: {result}")
            return result
        except Exception as e:
            print(f"DEBUG: Error in addItem: Ошибка добавления товара: {str(e)}")
            return f"Ошибка добавления товара: {str(e)}"

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str)
    def updateItem(self, proxy_row, article, name, description, image_path, category_id, price, stock, status, unit, manufacturer, document):
        """Обновление существующего элемента в исходной модели.

        Args:
            proxy_row (int): Индекс строки в прокси-модели.
            article (str): Артикул элемента.
            name (str): Название элемента.
            description (str): Описание элемента.
            image_path (str): Путь к изображению.
            category_id (int): Идентификатор категории.
            price (float): Цена элемента.
            stock (int): Количество на складе.
            status (str): Статус элемента.
            unit (str): Единица измерения.
            manufacturer (str): Производитель.
            document (str): Документ, связанный с элементом.

        Выполняет преобразование индекса из прокси-модели в исходную,
        проверяет валидность индексов и вызывает метод обновления
        в исходной модели. Выводит отладочную информацию.
        """
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
            self.sourceModel().updateItem(
                source_row, article, name, description, image_path,
                category_id, price, stock, status, unit, manufacturer, document
            )
            print("DEBUG: FilterProxyModel.updateItem completed")
        except Exception as e:
            print(f"DEBUG: Error in FilterProxyModel.updateItem: {str(e)}")

    @Slot(int)
    def deleteItem(self, proxy_row):
        """Удаление элемента из исходной модели.

        Args:
            proxy_row (int): Индекс строки в прокси-модели.

        Выполняет преобразование индекса из прокси-модели в исходную,
        проверяет валидность индексов и вызывает метод удаления
        в исходной модели. Выводит отладочную информацию.
        """
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

    @Slot(str, result=bool)
    def deleteItemByArticle(self, article):
        """Удаляет товар по артикулу (proxy версия)"""
        try:
            print(f"=== FilterProxyModel.deleteItemByArticle called ===")
            print(f"article: {article}")

            source_model = self.sourceModel()
            if source_model:
                # Делегируем source model
                return source_model.deleteItemByArticle(article)

            print("ERROR: No source model")
            return False

        except Exception as e:
            print(f"ERROR: {e}")
            import traceback
            traceback.print_exc()
            return False