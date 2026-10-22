"""Репозиторий для управления спецификациями и их позициями"""

from typing import List, Tuple, Dict
from datetime import datetime
from loguru import logger

from repositories.base_repository import BaseRepository
from models.dto import Specification, SpecificationItem


class SpecificationsRepository(BaseRepository):
    """
    Репозиторий для управления спецификациями и их позициями.

    Предоставляет методы для:
    - Создания и загрузки спецификаций
    - Обновления и удаления спецификаций
    - Управления позициями в спецификациях
    - Расчета стоимости спецификаций
    """

    def copy_specification(self, original_spec_id: int) -> int:
        """
        Создает копию спецификации и всех ее позиций,
        используя штатные методы репозитория.
        """
        try:
            # 1. Получаем оригинальную спецификацию
            original = self.get_by_id(original_spec_id)
            if not original:
                return -1

            # 2. Создаем DTO для новой спецификации
            from models.dto import Specification, SpecificationItem
            new_spec = Specification(
                id=None,
                name=f"{original.name} (Копия)",
                description=original.description,
                status="черновик",  # С маленькой буквы, как в вашем фильтре QML
                labor_cost=original.labor_cost,
                overhead_percentage=original.overhead_percentage,
                final_price=original.final_price,
                created_date=None,
                modified_date=None
            )

            # Сохраняем шапку и получаем новый ID (этот метод у вас уже отлично работает!)
            new_spec_id = self.add(new_spec)

            # 3. Получаем позиции старой спецификации штатным методом
            items = self.get_specification_items(original_spec_id)

            # 4. Копируем каждую позицию штатным методом
            for item in items:
                # В вашем проекте get_specification_items возвращает кортеж (tuple) или объект DTO
                if isinstance(item, (tuple, list)):
                    # Судя по коду exportToPDF: индекс 2 - article, индекс 3 - quantity, индекс 10 - notes
                    article = item[2]
                    quantity = float(item[3] or 0)
                    notes = item[10] if len(item) > 10 else ""
                else:
                    # Если возвращает DTO SpecificationItem
                    article = item.article
                    quantity = float(item.quantity)
                    notes = getattr(item, 'notes', "") or ""

                new_item = SpecificationItem(
                    id=None,
                    specification_id=new_spec_id,
                    article=article,
                    quantity=quantity,
                    notes=notes
                )
                self.add_specification_item(new_item)

            return new_spec_id

        except Exception as e:
            raise Exception(f"Ошибка при копировании спецификации: {e}")

    def create_table(self):
        """Создает таблицы specifications и specification_items если не существуют."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Таблица спецификаций
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS specifications (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT NOT NULL,
                        description TEXT,
                        created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                        modified_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                        status TEXT DEFAULT 'черновик',
                        labor_cost REAL DEFAULT 0.0,
                        overhead_percentage REAL DEFAULT 0.0,
                        final_price REAL DEFAULT 0.0
                    )
                ''')

                # Таблица позиций спецификации
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS specification_items (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        specification_id INTEGER NOT NULL,
                        article TEXT NOT NULL,
                        quantity INTEGER NOT NULL,
                        notes TEXT,
                        FOREIGN KEY (specification_id) REFERENCES specifications(id) ON DELETE CASCADE,
                        FOREIGN KEY (article) REFERENCES items(article)
                    )
                ''')

            logger.success("✅ Specifications tables created/verified")

        except Exception as e:
            logger.error(f"❌ Error creating specifications tables: {e}")
            raise

    def get_all(self) -> List[Specification]:
        """
        Загружает все спецификации из базы данных.

        Returns:
            List[Specification]: Список объектов Specification.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT 
                        id, name, description, created_date, modified_date, 
                        status, labor_cost, overhead_percentage, final_price
                    FROM specifications
                    ORDER BY modified_date DESC
                """)
                rows = cursor.fetchall()

                # Преобразуем кортежи в DTO
                specs = [
                    Specification(
                        id=row[0],
                        name=row[1],
                        description=row[2],
                        created_date=row[3],
                        modified_date=row[4],
                        status=row[5],
                        labor_cost=row[6],
                        overhead_percentage=row[7],
                        final_price=row[8]
                    )
                    for row in rows
                ]

            logger.info(f"📋 Loaded {len(specs)} specification(s)")
            return specs

        except Exception as e:
            logger.error(f"❌ Error loading specifications: {e}")
            return []

    def get_by_id(self, spec_id: int) -> Specification | None:
        """
        Получает спецификацию по ID.

        Args:
            spec_id: ID спецификации.

        Returns:
            Specification: Объект спецификации или None, если не найдена.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT 
                        id, name, description, created_date, modified_date,
                        status, labor_cost, overhead_percentage, final_price
                    FROM specifications
                    WHERE id = ?
                """, (spec_id,))

                row = cursor.fetchone()

            if row:
                logger.debug(f"✅ Found specification: {spec_id}")
                return Specification(
                    id=row[0],
                    name=row[1],
                    description=row[2],
                    created_date=row[3],
                    modified_date=row[4],
                    status=row[5],
                    labor_cost=row[6],
                    overhead_percentage=row[7],
                    final_price=row[8]
                )
            else:
                logger.warning(f"⚠️ Specification not found: {spec_id}")
                return None

        except Exception as e:
            logger.error(f"❌ Error getting specification {spec_id}: {e}")
            return None

    def add(self, spec: Specification) -> int:
        """
        Создает новую спецификацию в базе данных.

        Args:
            spec: Объект спецификации для добавления.

        Returns:
            int: ID созданной спецификации.

        Raises:
            Exception: Если произошла ошибка при добавлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                cursor.execute("""
                    INSERT INTO specifications
                    (name, description, created_date, modified_date, status, 
                     labor_cost, overhead_percentage, final_price)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, (spec.name, spec.description, now, now, spec.status,
                      spec.labor_cost, spec.overhead_percentage, spec.final_price))

                spec_id = cursor.lastrowid

            logger.success(f"✅ Specification created: {spec.name} (ID: {spec_id})")
            return spec_id

        except Exception as e:
            logger.error(f"❌ Error adding specification '{spec.name}': {e}")
            raise

    def update(self, spec_id: int, spec: Specification) -> bool:
        """
        Обновляет существующую спецификацию.

        Args:
            spec_id: ID спецификации для обновления.
            spec: Объект спецификации с новыми данными.

        Returns:
            bool: True если обновление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                cursor.execute("""
                    UPDATE specifications
                    SET name=?, description=?, modified_date=?, status=?,
                        labor_cost=?, overhead_percentage=?, final_price=?
                    WHERE id = ?
                """, (spec.name, spec.description, now, spec.status,
                      spec.labor_cost, spec.overhead_percentage,
                      spec.final_price, spec_id))

            logger.success(f"✅ Specification {spec_id} updated: {spec.name}")
            return True

        except Exception as e:
            logger.error(f"❌ Error updating specification {spec_id}: {e}")
            return False

    def delete(self, spec_id: int) -> bool:
        """
        Удаляет спецификацию и связанные с ней позиции.

        Args:
            spec_id: ID спецификации для удаления.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()

                # Cascade удаление позиций происходит автоматически
                cursor.execute("DELETE FROM specifications WHERE id=?", (spec_id,))

            logger.warning(f"⚠️ Specification {spec_id} deleted")
            return True

        except Exception as e:
            logger.error(f"❌ Error deleting specification {spec_id}: {e}")
            return False

    # ===== Методы для работы с позициями спецификации =====

    def get_items(self, spec_id: int) -> List[Tuple]:
        """
        Загружает все позиции спецификации с данными о товарах.

        Args:
            spec_id: ID спецификации.

        Returns:
            List[Tuple]: Список кортежей с данными позиций и товаров.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT 
                        si.id,
                        si.specification_id,
                        si.article,
                        si.quantity,
                        si.notes,
                        i.name,
                        i.unit,
                        i.price,
                        i.image_path,
                        c.name as category,
                        i.status,
                        COALESCE(i.manufacturer, '') as manufacturer,
                        COALESCE(i.description, '') as description
                    FROM specification_items si
                    JOIN items i ON si.article = i.article
                    LEFT JOIN categories c ON i.category_id = c.id
                    WHERE si.specification_id = ?
                    ORDER BY si.id
                """, (spec_id,))

                items = cursor.fetchall()

            logger.debug(f"📦 Loaded {len(items)} item(s) for specification {spec_id}")
            return items

        except Exception as e:
            logger.error(f"❌ Error loading items for specification {spec_id}: {e}")
            return []

    def get_specification_items(self, spec_id: int) -> List[Tuple]:
        """
        Алиас для get_items (для совместимости).

        Args:
            spec_id: ID спецификации.

        Returns:
            List[Tuple]: Список кортежей с данными позиций.
        """
        return self.get_items(spec_id)

    def add_item(self, spec_item: SpecificationItem) -> int:
        """
        Добавляет новую позицию в спецификацию.

        Args:
            spec_item: Объект позиции спецификации.

        Returns:
            int: ID созданной позиции.

        Raises:
            Exception: Если произошла ошибка при добавлении.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO specification_items
                    (specification_id, article, quantity, notes)
                    VALUES (?, ?, ?, ?)
                """, (spec_item.specification_id, spec_item.article,
                      spec_item.quantity, spec_item.notes))

                item_id = cursor.lastrowid

            logger.success(
                f"✅ Item added to specification {spec_item.specification_id}: "
                f"{spec_item.article} (qty: {spec_item.quantity})"
            )
            return item_id

        except Exception as e:
            logger.error(f"❌ Error adding specification item: {e}")
            raise

    def add_specification_item(self, spec_item: SpecificationItem) -> int:
        """
        Алиас для add_item (для совместимости).

        Args:
            spec_item: Объект позиции спецификации.

        Returns:
            int: ID созданной позиции.
        """
        return self.add_item(spec_item)

    def update_item(self, item_id: int, quantity: int, notes: str = None) -> bool:
        """
        Обновляет позицию в спецификации.

        Args:
            item_id: ID позиции для обновления.
            quantity: Новое количество.
            notes: Новые примечания (опционально).

        Returns:
            bool: True если обновление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE specification_items
                    SET quantity=?, notes=?
                    WHERE id = ?
                """, (quantity, notes, item_id))

            logger.success(f"✅ Specification item {item_id} updated")
            return True

        except Exception as e:
            logger.error(f"❌ Error updating specification item {item_id}: {e}")
            return False

    def delete_item(self, item_id: int) -> bool:
        """
        Удаляет позицию из спецификации.

        Args:
            item_id: ID позиции для удаления.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM specification_items WHERE id=?", (item_id,))

            logger.warning(f"⚠️ Specification item {item_id} deleted")
            return True

        except Exception as e:
            logger.error(f"❌ Error deleting specification item {item_id}: {e}")
            return False

    def clear_items(self, spec_id: int) -> bool:
        """
        Удаляет все позиции указанной спецификации.

        Args:
            spec_id: ID спецификации.

        Returns:
            bool: True если удаление успешно, False в случае ошибки.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "DELETE FROM specification_items WHERE specification_id=?",
                    (spec_id,)
                )
                deleted_count = cursor.rowcount

            logger.info(f"🗑️ Cleared {deleted_count} item(s) from specification {spec_id}")
            return True

        except Exception as e:
            logger.error(f"❌ Error clearing specification items: {e}")
            return False

    def delete_specification_items(self, spec_id: int) -> bool:
        """
        Алиас для clear_items (для совместимости).

        Args:
            spec_id: ID спецификации.

        Returns:
            bool: True если удаление успешно.
        """
        return self.clear_items(spec_id)

    def save_with_items(
            self,
            spec_id: int | None,
            name: str,
            description: str,
            status: str,
            labor_cost: float,
            overhead_percentage: float,
            items: List[Dict]
    ) -> int:
        """
        Сохраняет спецификацию и её позиции транзакционно.

        Автоматически рассчитывает итоговую стоимость.

        Args:
            spec_id: ID спецификации (None для новой).
            name: Название спецификации.
            description: Описание спецификации.
            status: Статус спецификации.
            labor_cost: Стоимость работы.
            overhead_percentage: Процент накладных расходов.
            items: Список словарей с данными позиций [{article, quantity, notes}, ...].

        Returns:
            int: ID спецификации.

        Raises:
            Exception: Если произошла ошибка при сохранении.
        """
        logger.info(f"💾 Saving specification with {len(items)} items...")

        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                # Рассчитываем стоимость материалов
                materials_cost = 0
                for item in items:
                    cursor.execute(
                        "SELECT price FROM items WHERE article = ?",
                        (item['article'],)
                    )
                    result = cursor.fetchone()
                    if result:
                        materials_cost += result[0] * item['quantity']

                # Рассчитываем накладные и итоговую стоимость
                overhead_cost = materials_cost * (overhead_percentage / 100)
                final_price = materials_cost + labor_cost + overhead_cost

                logger.debug(
                    f"💰 Costs: materials={materials_cost}, "
                    f"labor={labor_cost}, overhead={overhead_cost}, "
                    f"total={final_price}"
                )

                # Создаем или обновляем спецификацию
                if spec_id is None or spec_id <= 0:
                    cursor.execute("""
                        INSERT INTO specifications
                        (name, description, created_date, modified_date, status,
                         labor_cost, overhead_percentage, final_price)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """, (name, description, now, now, status,
                          labor_cost, overhead_percentage, final_price))
                    spec_id = cursor.lastrowid
                    logger.info(f"🆕 Created new specification with ID: {spec_id}")
                else:
                    cursor.execute("""
                        UPDATE specifications
                        SET name=?, description=?, modified_date=?, status=?,
                            labor_cost=?, overhead_percentage=?, final_price=?
                        WHERE id = ?
                    """, (name, description, now, status,
                          labor_cost, overhead_percentage, final_price, spec_id))
                    logger.info(f"📝 Updated existing specification: {spec_id}")

                # Удаляем старые позиции и добавляем новые
                cursor.execute(
                    "DELETE FROM specification_items WHERE specification_id=?",
                    (spec_id,)
                )

                for item in items:
                    cursor.execute("""
                        INSERT INTO specification_items
                        (specification_id, article, quantity, notes)
                        VALUES (?, ?, ?, ?)
                    """, (spec_id, item['article'], item['quantity'],
                          item.get('notes', '')))

            logger.success(
                f"✅ Specification {spec_id} saved successfully "
                f"with {len(items)} item(s), total: {final_price:.2f}"
            )
            return spec_id

        except Exception as e:
            logger.error(f"❌ Error saving specification with items: {e}")
            raise