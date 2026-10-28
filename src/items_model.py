"""Модель товаров для Qt/QML интерфейса с Repository Pattern"""

from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot, Signal, QUrl
import pyexcel
from loguru import logger

from repositories.items_repository import ItemsRepository
from models.dto import Item
from validators import validate_item


class ItemsModel(QAbstractListModel):
    """
    Модель для работы с данными товаров в интерфейсе Qt/QML.

    Использует Repository Pattern для работы с данными.
    Поддерживает загрузку, фильтрацию, добавление, обновление и удаление товаров.

    Attributes:
        repository: ItemsRepository для работы с базой данных
        items: Отфильтрованный список товаров для отображения
    """

    # Роли данных для QML
    ArticleRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    DescriptionRole = Qt.UserRole + 3
    ImagePathRole = Qt.UserRole + 4
    CategoryRole = Qt.UserRole + 5
    PriceRole = Qt.UserRole + 6
    StockRole = Qt.UserRole + 7
    CreatedDateRole = Qt.UserRole + 8
    StatusRole = Qt.UserRole + 9
    UnitRole = Qt.UserRole + 10
    ManufacturerRole = Qt.UserRole + 11
    DocumentCodeRole = Qt.UserRole + 12

    # Сигналы
    errorOccurred = Signal(str)
    itemsLoaded = Signal(int)  # Новый сигнал - количество загруженных товаров

    # Маппинг ролей на индексы в кортеже
    _ROLE_TO_INDEX = {
        ArticleRole: 0,
        NameRole: 1,
        DescriptionRole: 2,
        ImagePathRole: 3,
        CategoryRole: 4,
        PriceRole: 5,
        StockRole: 6,
        CreatedDateRole: 7,
        StatusRole: 8,
        UnitRole: 9,
        ManufacturerRole: 10,
        DocumentCodeRole: 11,
    }

    def __init__(self, items_repository: ItemsRepository):
        """
        Инициализирует модель товаров.

        Args:
            items_repository: Репозиторий для работы с товарами.
        """
        super().__init__()

        self.repository = items_repository
        self.items = []
        self._all_items = []  # Полный список для фильтрации
        self._filter_string = ""
        self._filter_field = "name"

        logger.debug("ItemsModel initialized")
        self.loadData()

    def loadData(self):
        """
        Загружает все данные товаров из репозитория.

        Применяет текущий фильтр к загруженным данным.
        """
        logger.info("Loading items data...")

        try:
            self._all_items = self.repository.get_all()
            self._applyFilter()

            logger.success(
                f"✅ Loaded {len(self._all_items)} items, "
                f"filtered to {len(self.items)}"
            )

            self.itemsLoaded.emit(len(self.items))

        except Exception as e:
            logger.exception("❌ Failed to load items")
            self.errorOccurred.emit(f"Ошибка загрузки: {str(e)}")

    def _applyFilter(self):
        """
        Применяет текущий фильтр к списку товаров.

        Фильтрует товары на основе строки фильтра и выбранного поля.
        """
        if not self._filter_string:
            self.items = self._all_items.copy()
            logger.debug("No filter applied, showing all items")
            return

        filter_lower = self._filter_string.lower()

        # Маппинг поля фильтра на индекс колонки
        field_map = {
            "article": 0,
            "name": 1,
            "description": 2,
            "category": 4,
            "manufacturer": 10,
        }

        field_index = field_map.get(self._filter_field, 1)  # По умолчанию name

        self.items = [
            item for item in self._all_items
            if filter_lower in str(item[field_index]).lower()
        ]

        logger.debug(
            f"🔍 Filter applied: '{self._filter_string}' in '{self._filter_field}' "
            f"-> {len(self.items)} results"
        )

    # ==================== Qt Model Methods ====================

    def rowCount(self, parent=QModelIndex()):
        """
        Возвращает количество строк в модели.

        Args:
            parent: Родительский индекс модели.

        Returns:
            int: Количество товаров в отфильтрованном списке.
        """
        return len(self.items)

    def data(self, index, role=Qt.DisplayRole):
        """
        Получает данные для указанного индекса и роли.

        Args:
            index: Индекс элемента в модели.
            role: Роль данных (ArticleRole, NameRole и т.д.).

        Returns:
            Значение для указанной роли или None.
        """
        if not index.isValid() or index.row() >= len(self.items):
            return None

        if role not in self._ROLE_TO_INDEX:
            return None

        item = self.items[index.row()]
        value = item[self._ROLE_TO_INDEX[role]]

        # Специальная обработка для DocumentCodeRole
        if role == self.DocumentCodeRole:
            return value if value is not None else ""

        return value

    def roleNames(self):
        """
        Возвращает словарь ролей данных для использования в QML.

        Returns:
            dict: Словарь ролей и их имен в байтовом формате.
        """
        return {
            self.ArticleRole: b"article",
            self.NameRole: b"name",
            self.DescriptionRole: b"description",
            self.ImagePathRole: b"image_path",
            self.CategoryRole: b"category",
            self.PriceRole: b"price",
            self.StockRole: b"stock",
            self.CreatedDateRole: b"created_date",
            self.StatusRole: b"status",
            self.UnitRole: b"unit",
            self.ManufacturerRole: b"manufacturer",
            self.DocumentCodeRole: b"document"
        }

    # ==================== CRUD Operations ====================

    @Slot(str, 'QVariantList', 'QVariantList', str, result=bool)
    @Slot(str, 'QVariantList', 'QVariantList', result=bool)
    def exportToExcel(
            self,
            file_url: str,
            selected_categories: list,
            active_columns: list,
            template_url: str = ""
    ) -> bool:
        """
        Формирует и экспортирует срез товаров в Excel (xlsx) по фильтру из ExportSettingsDialog.
        Поддерживает как прямую выгрузку через pyexcel, так и заполнение .xlsx шаблона.
        """
        try:
            logger.info("=" * 60)
            logger.info("📊 ЗАПУСК ЭКСПОРТА ТОВАРОВ В EXCEL")
            logger.debug(f"Входной URL файла: {file_url}")
            logger.debug(f"Шаблон URL: {template_url}")
            logger.debug(f"Выбранные категории (фильтр): {selected_categories}")
            logger.debug(f"Выбранные столбцы: {active_columns}")

            # 1. Нормализация путей
            file_path = QUrl(file_url).toLocalFile() if file_url.startswith("file:") else file_url
            template_path = QUrl(template_url).toLocalFile() if template_url.startswith("file:") else template_url
            template_path = template_path.strip()

            logger.info(f"Локальный путь сохранения: {file_path}")

            # 2. Получаем товары из модели или репозитория
            all_items = getattr(self, '_items', None) or getattr(self, 'items', None)
            if not all_items and hasattr(self, 'repository'):
                all_items = self.repository.get_all()

            all_items = all_items or []
            logger.info(f"Всего товаров получено из базы: {len(all_items)}")

            # Распаковка записи (поддерживает tuple/list, dict и DTO)
            def extract_item_fields(item):
                if isinstance(item, (tuple, list)):
                    return {
                        "article": item[0] if len(item) > 0 else "",
                        "name": item[1] if len(item) > 1 else "",
                        "category": item[4] if len(item) > 4 else "",
                        "price": float(item[5] or 0.0) if len(item) > 5 else 0.0,
                        "stock": item[6] if len(item) > 6 and item[6] is not None else 0,
                        "status": item[8] if len(item) > 8 else "",
                        "unit": item[9] if len(item) > 9 and item[9] else "шт.",
                        "manufacturer": item[10] if len(item) > 10 else "",
                    }
                elif isinstance(item, dict):
                    return {
                        "article": item.get("article", ""),
                        "name": item.get("name", ""),
                        "category": item.get("category", ""),
                        "price": float(item.get("price", 0.0) or 0.0),
                        "stock": item.get("stock", 0) or 0,
                        "status": item.get("status", ""),
                        "unit": item.get("unit", "шт.") or "шт.",
                        "manufacturer": item.get("manufacturer", ""),
                    }
                else:
                    return {
                        "article": getattr(item, "article", ""),
                        "name": getattr(item, "name", ""),
                        "category": getattr(item, "category", ""),
                        "price": float(getattr(item, "price", 0.0) or 0.0),
                        "stock": getattr(item, "stock", 0) or 0,
                        "status": getattr(item, "status", ""),
                        "unit": getattr(item, "unit", "шт.") or "шт.",
                        "manufacturer": getattr(item, "manufacturer", ""),
                    }

            # 3. Фильтрация по выбранным категориям
            clean_categories = [str(c).strip() for c in selected_categories if str(c).strip()]
            parsed_items = [extract_item_fields(it) for it in all_items]

            if clean_categories:
                items_to_export = [
                    it for it in parsed_items
                    if str(it["category"]).strip() in clean_categories
                ]
                logger.info(
                    f"Отфильтровано по категориям {clean_categories}: {len(items_to_export)} из {len(parsed_items)} записей")
            else:
                items_to_export = parsed_items
                logger.info(f"Категории не выбраны — выгружаем все записи: {len(items_to_export)} шт.")

            # Вспомогательная функция получения значения по ключу/названию столбца
            def get_column_value(index: int, it: dict, col_key: str):
                qty = float(it["stock"] or 0)
                price = float(it["price"] or 0.0)
                mapping = {
                    "№": index, "{{index}}": index,
                    "Название": it["name"], "{{name}}": it["name"],
                    "Артикул": it["article"], "{{article}}": it["article"],
                    "Производитель": it["manufacturer"], "{{manufacturer}}": it["manufacturer"],
                    "Кол-во": it["stock"], "{{stock}}": it["stock"],
                    "Ед.": it["unit"], "{{unit}}": it["unit"],
                    "Цена без НДС": round(price, 2), "{{price}}": round(price, 2),
                    "Сумма без НДС": round(qty * price, 2), "{{total}}": round(qty * price, 2),
                    "Примечание": it["status"], "{{status}}": it["status"],
                }
                return mapping.get(col_key, "")

            # =========================================================================
            # ВАРИАНТ А: ВЫГРУЗКА ПО ШАБЛОНУ EXCEL (если выбран файл шаблона)
            # =========================================================================
            if template_path:
                import os
                from copy import copy
                from datetime import datetime
                import openpyxl

                if not os.path.exists(template_path):
                    logger.error(f"❌ Файл шаблона не найден: {template_path}")
                    return False

                logger.info(f"📄 Используется шаблон Excel: {template_path}")
                wb = openpyxl.load_workbook(template_path)
                ws = wb.active

                # Подстановка одиночных тегов в шапке документа ({{date}}, {{categories}})
                now_str = datetime.now().strftime("%d.%m.%Y %H:%M")
                cats_str = ", ".join(clean_categories) if clean_categories else "Все категории"

                tag_row_idx = None
                tag_columns = {}  # {col_idx: tag_name}
                header_row_idx = None
                header_columns = {}  # {col_idx: header_name}

                known_tags = {"{{index}}", "{{name}}", "{{article}}", "{{manufacturer}}", "{{stock}}", "{{unit}}",
                              "{{price}}", "{{total}}", "{{status}}"}
                known_headers = {"№", "Название", "Артикул", "Производитель", "Кол-во", "Ед.", "Цена без НДС",
                                 "Сумма без НДС", "Примечание"}

                for r_idx in range(1, ws.max_row + 1):
                    for c_idx in range(1, ws.max_column + 1):
                        val = ws.cell(row=r_idx, column=c_idx).value
                        if isinstance(val, str):
                            # Замена общих мета-тегов в шапке
                            if "{{date}}" in val:
                                ws.cell(row=r_idx, column=c_idx).value = val.replace("{{date}}", now_str)
                            if "{{categories}}" in val:
                                ws.cell(row=r_idx, column=c_idx).value = val.replace("{{categories}}", cats_str)

                            clean_val = val.strip()
                            if clean_val in known_tags:
                                tag_row_idx = r_idx
                                tag_columns[c_idx] = clean_val
                            elif clean_val in known_headers:
                                header_row_idx = r_idx
                                header_columns[c_idx] = clean_val

                from openpyxl.styles import Font, Border, Side, Alignment, PatternFill

                # Определяем стартовую строку данных и карту колонок
                if tag_row_idx is not None:
                    start_row = tag_row_idx
                    col_map = tag_columns
                    # В режиме тегов берем стиль именно из строки с тегами {{...}}
                    style_source_row = tag_row_idx
                    logger.info(f"Найдена строка с тегами шаблона (строка {tag_row_idx}): {col_map}")
                elif header_row_idx is not None:
                    start_row = header_row_idx + 1
                    col_map = {
                        c_idx: h_name for c_idx, h_name in header_columns.items()
                        if not active_columns or h_name in active_columns
                    }
                    # ВАЖНО: Никогда не берем стиль из самой шапки (header_row_idx),
                    # чтобы цвет заливки и жирный шрифт заголовка не размножались на всю таблицу!
                    style_source_row = header_row_idx + 1
                    logger.info(f"Найдена строка заголовков шаблона (строка {header_row_idx}): {col_map}")
                else:
                    start_row = ws.max_row + 2
                    for c_idx, col_name in enumerate(active_columns, start=1):
                        ws.cell(row=start_row - 1, column=c_idx, value=col_name)
                    col_map = {c_idx: col_name for c_idx, col_name in enumerate(active_columns, start=1)}
                    style_source_row = start_row
                    logger.info(f"Маркеры в шаблоне не найдены, данные будут добавлены со строки {start_row}")

                # Базовый аккуратный стиль для строк данных (если строка под шапкой пустая)
                thin_side = Side(style='thin', color='D0D0D0')
                default_border = Border(left=thin_side, right=thin_side, top=thin_side, bottom=thin_side)
                default_font = Font(name='Calibri', size=11, bold=False)
                no_fill = PatternFill(fill_type=None)

                # Сохраняем образец стилей из первой строки данных (style_source_row)
                row_styles = {}
                template_row_height = ws.row_dimensions[style_source_row].height

                for c_idx in col_map.keys():
                    src_cell = ws.cell(row=style_source_row, column=c_idx)
                    # Проверяем, задал ли пользователь специальное оформление для строки данных
                    has_custom_border = src_cell.border and any([
                        src_cell.border.left.style, src_cell.border.right.style,
                        src_cell.border.top.style, src_cell.border.bottom.style
                    ])
                    has_custom_fill = src_cell.fill and src_cell.fill.fill_type is not None

                    if tag_row_idx is not None or has_custom_border or has_custom_fill:
                        row_styles[c_idx] = {
                            "font": copy(src_cell.font),
                            "fill": copy(src_cell.fill),
                            "border": copy(src_cell.border),
                            "alignment": copy(src_cell.alignment),
                            "number_format": src_cell.number_format,
                        }
                    else:
                        # Чистый стиль строки данных по умолчанию (без заливки шапки!)
                        row_styles[c_idx] = {
                            "font": default_font,
                            "fill": no_fill,
                            "border": default_border,
                            "alignment": Alignment(vertical="center", wrap_text=True),
                            "number_format": src_cell.number_format,
                        }

                # Если ниже стартовой строки в шаблоне есть подвал (например, "Итого" или подписи),
                # раздвигаем строки вниз, чтобы не затереть подвал
                if len(items_to_export) > 1 and ws.max_row > start_row:
                    ws.insert_rows(start_row + 1, amount=len(items_to_export) - 1)

                # Заполняем строки товарами
                for idx, it in enumerate(items_to_export, start=1):
                    curr_row = start_row + idx - 1
                    if template_row_height:
                        ws.row_dimensions[curr_row].height = template_row_height

                    # Применяем сохраненные стили строки шаблона
                    for c_idx, st in row_styles.items():
                        cell = ws.cell(row=curr_row, column=c_idx)
                        cell.font = copy(st["font"])
                        cell.fill = copy(st["fill"])
                        cell.border = copy(st["border"])
                        cell.alignment = copy(st["alignment"])
                        cell.number_format = st["number_format"]

                    # Записываем значения
                    for c_idx, key_name in col_map.items():
                        ws.cell(row=curr_row, column=c_idx, value=get_column_value(idx, it, key_name))

                # Если список товаров оказался пуст, очищаем теги в строке-образце
                if not items_to_export and tag_row_idx is not None:
                    for c_idx in col_map.keys():
                        ws.cell(row=tag_row_idx, column=c_idx, value="")

                wb.save(file_path)
                logger.success(f"✅ Экспорт по шаблону успешно завершен: {file_path}")
                logger.info("=" * 60)
                return True

            # =========================================================================
            # ВАРИАНТ Б: СТАНДАРТНАЯ ГЕНЕРАЦИЯ ЧЕРЕЗ PYEXCEL (без шаблона)
            # =========================================================================
            if not active_columns:
                logger.warning("⚠️ Не выбран ни один столбец для экспорта!")
                return False

            excel_data = [list(active_columns)]
            for index, it in enumerate(items_to_export, start=1):
                row = [get_column_value(index, it, col) for col in active_columns]
                excel_data.append(row)

            logger.info(f"Сформировано строк для записи в Excel (включая шапку): {len(excel_data)}")
            pyexcel.save_as(array=excel_data, dest_file_name=file_path)
            logger.success(f"✅ Экспорт в Excel успешно завершен: {file_path}")
            logger.info("=" * 60)
            return True

        except PermissionError:
            logger.error(
                f"❌ Нет доступа к файлу '{file_path}'. "
                f"Файл сейчас открыт в программе Excel! Закройте его и повторите попытку."
            )
            return False
        except Exception as e:
            logger.exception(f"❌ Критическая ошибка при экспорте в Excel: {e}")
            return False

    @Slot(str, str, str, str, int, float, int, str, str, str, str, result=str)
    def addItem(
            self,
            article: str,
            name: str,
            description: str,
            image_path: str,
            category_id: int,
            price: float,
            stock: int,
            status: str,
            unit: str,
            manufacturer: str,
            document: str
    ) -> str:
        """
        Добавляет новый товар в базу данных.

        Args:
            article: Артикул товара.
            name: Название товара.
            description: Описание товара.
            image_path: Путь к изображению товара.
            category_id: ID категории.
            price: Цена товара.
            stock: Количество на складе.
            status: Статус товара.
            unit: Единица измерения.
            manufacturer: Производитель.
            document: Связанный документ.

        Returns:
            str: Пустая строка при успехе, сообщение об ошибке при неудаче.
        """
        try:
            logger.info(
                f"Adding item: article={article}, name={name}, "
                f"category_id={category_id}, price={price}, stock={stock}"
            )

            # Валидация входных данных
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )

            if not is_valid:
                logger.warning(f"⚠️ Validation failed: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Создаем DTO объект
            item = Item(
                article=article,
                name=name,
                description=description,
                image_path=image_path,
                category_id=category_id,
                price=price,
                stock=stock,
                status=status or 'в наличии',
                unit=unit or 'шт.',
                manufacturer=manufacturer or '',
                document=document or ''
            )

            # Добавляем в базу данных через репозиторий
            self.repository.add(item)

            logger.success(f"✅ Item added: {article} - {name}")

            # Обновляем модель
            self.beginResetModel()
            self.loadData()
            self.endResetModel()

            logger.debug(f"Model refreshed. Total items: {len(self.items)}")
            return ""

        except Exception as e:
            error_message = f"Ошибка добавления товара: {str(e)}"
            logger.error(f"❌ {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int, str, str, str, str, int, float, int, str, str, str, str, result=str)
    def updateItem(
            self,
            row: int,
            article: str,
            name: str,
            description: str,
            image_path: str,
            category_id: int,
            price: float,
            stock: int,
            status: str,
            unit: str,
            manufacturer: str,
            document: str
    ) -> str:
        """
        Обновляет существующий товар в базе данных.

        Args:
            row: Индекс строки в отфильтрованном списке.
            article: Новый артикул товара.
            name: Новое название товара.
            description: Новое описание товара.
            image_path: Новый путь к изображению.
            category_id: Новый ID категории.
            price: Новая цена.
            stock: Новое количество на складе.
            status: Новый статус.
            unit: Новая единица измерения.
            manufacturer: Новый производитель.
            document: Новый документ.

        Returns:
            str: Пустая строка при успехе, сообщение об ошибке при неудаче.
        """
        try:
            # Проверка индекса строки
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                logger.warning(f"⚠️ {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Получаем старый артикул
            old_article = self.items[row][0]

            logger.info(
                f"Updating item: {old_article} -> {article}, "
                f"name={name}, price={price}"
            )

            # Валидация входных данных
            is_valid, error_message = validate_item(
                article, name, description, image_path,
                category_id, price, stock
            )

            if not is_valid:
                logger.warning(f"⚠️ Validation failed: {error_message}")
                self.errorOccurred.emit(error_message)
                return error_message

            # Создаем DTO объект с новыми данными
            item = Item(
                article=article,
                name=name,
                description=description,
                image_path=image_path,
                category_id=category_id,
                price=price,
                stock=stock,
                status=status,
                unit=unit,
                manufacturer=manufacturer,
                document=document
            )

            # Обновляем в базе данных через репозиторий
            self.repository.update(old_article, item)

            logger.success(f"✅ Item updated: {old_article} -> {article}")

            # Обновляем модель
            self.beginResetModel()
            self.loadData()
            self.endResetModel()

            logger.debug("Model refreshed after update")
            return ""

        except Exception as e:
            error_message = f"Ошибка обновления товара: {str(e)}"
            logger.error(f"❌ {error_message}")
            self.errorOccurred.emit(error_message)
            return error_message

    @Slot(int)
    def deleteItem(self, row: int):
        """
        Удаляет товар из базы данных по индексу строки.

        Args:
            row: Индекс строки в отфильтрованном списке.
        """
        try:
            # Проверка индекса строки
            if row < 0 or row >= len(self.items):
                error_message = f"Недопустимый индекс строки: {row}"
                logger.warning(f"⚠️ {error_message}")
                self.errorOccurred.emit(error_message)
                return

            article = self.items[row][0]
            logger.info(f"Deleting item: {article}")

            # Удаляем через репозиторий
            self.repository.delete(article)

            logger.success(f"✅ Item deleted: {article}")

            # Обновляем модель
            self.beginResetModel()
            self.loadData()
            self.endResetModel()

            logger.debug("Model refreshed after deletion")

        except Exception as e:
            error_message = f"Ошибка удаления товара: {str(e)}"
            logger.error(f"❌ {error_message}")
            self.errorOccurred.emit(error_message)

    @Slot(str, result=bool)
    def deleteItemByArticle(self, article: str) -> bool:
        """
        Удаляет товар по артикулу.

        Args:
            article: Артикул товара для удаления.

        Returns:
            bool: True при успехе, False при ошибке.
        """
        try:
            logger.info(f"Deleting item by article: {article}")

            # Ищем товар в текущем списке
            for i, item in enumerate(self.items):
                if item[0] == article:  # item[0] это article
                    logger.debug(f"Found item at index {i}")
                    self.deleteItem(i)
                    return True

            logger.warning(f"⚠️ Item not found: {article}")
            self.errorOccurred.emit(f"Товар с артикулом {article} не найден")
            return False

        except Exception as e:
            logger.exception(f"❌ Error deleting item by article: {e}")
            self.errorOccurred.emit(f"Ошибка удаления: {str(e)}")
            return False

    # ==================== Filter Methods ====================

    @Slot(str)
    def setFilterString(self, filter_string: str):
        """
        Устанавливает строку для фильтрации товаров.

        Args:
            filter_string: Строка для фильтрации.
        """
        if self._filter_string != filter_string:
            self._filter_string = filter_string
            logger.debug(f"Filter string set to: '{filter_string}'")

            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot(str)
    def setFilterField(self, field: str):
        """
        Устанавливает поле для фильтрации товаров.

        Args:
            field: Поле для фильтрации (article, name, description, category, manufacturer).
        """
        if self._filter_field != field:
            self._filter_field = field
            logger.debug(f"Filter field set to: '{field}'")

            self.beginResetModel()
            self._applyFilter()
            self.endResetModel()

    @Slot()
    def clearFilter(self):
        """
        Сбрасывает все фильтры, возвращая модель к полному списку товаров.
        """
        self._filter_string = ""
        self._filter_field = "name"
        logger.debug("Filters cleared")

        self.beginResetModel()
        self._applyFilter()
        self.endResetModel()

    # ==================== Utility Methods ====================

    @Slot(int, result='QVariantMap')
    def get(self, row: int):
        """
        Получает данные товара по индексу строки.

        Args:
            row: Индекс строки в отфильтрованном списке.

        Returns:
            dict: Словарь с данными товара или пустой словарь при ошибке.
        """
        if row < 0 or row >= len(self.items):
            logger.warning(f"⚠️ Invalid row index: {row}")
            return {}

        item = self.items[row]

        result = {
            "index": row,
            "article": item[0],
            "name": item[1],
            "description": item[2],
            "image_path": item[3],
            "category": item[4],
            "price": item[5],
            "stock": item[6],
            "created_date": item[7],
            "status": item[8] if len(item) > 8 else "в наличии",
            "unit": item[9] if len(item) > 9 else "шт.",
            "manufacturer": item[10] if len(item) > 10 else "",
            "document": item[11] if len(item) > 11 else ""
        }

        logger.trace(f"Retrieved item data for row {row}: {item[0]}")
        return result

    @Slot(str, str, result=list)
    def searchItems(self, query: str, field: str = "name"):
        """
        Поиск товаров по запросу в указанном поле.

        Args:
            query: Поисковый запрос.
            field: Поле для поиска (name, article, manufacturer, description).

        Returns:
            list: Список найденных товаров.
        """
        try:
            logger.info(f"Searching items: query='{query}', field='{field}'")

            results = self.repository.search(query, field)

            logger.info(f"🔍 Found {len(results)} results")
            return results

        except Exception as e:
            logger.error(f"❌ Search error: {e}")
            self.errorOccurred.emit(f"Ошибка поиска: {str(e)}")
            return []

    @Slot()
    def refresh(self):
        """
        Принудительно обновляет данные модели.
        """
        logger.info("Manual refresh triggered")

        self.beginResetModel()
        self.loadData()
        self.endResetModel()

        logger.debug("Model manually refreshed")

    @Slot(result=int)
    def getTotalCount(self) -> int:
        """
        Возвращает общее количество товаров (без фильтра).

        Returns:
            int: Общее количество товаров.
        """
        return len(self._all_items)

    @Slot(result=int)
    def getFilteredCount(self) -> int:
        """
        Возвращает количество отфильтрованных товаров.

        Returns:
            int: Количество товаров после применения фильтра.
        """
        return len(self.items)