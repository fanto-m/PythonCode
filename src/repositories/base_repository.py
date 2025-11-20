"""Базовый репозиторий для всех доменных сущностей"""

from abc import ABC, abstractmethod
from typing import List, Optional, Any
import sqlite3
from contextlib import contextmanager
from loguru import logger


class BaseRepository(ABC):
    """
    Абстрактный базовый класс для всех репозиториев.

    Предоставляет общую функциональность для работы с SQLite:
    - Управление соединениями через context manager
    - Обработка ошибок с логированием
    - Автоматический commit/rollback

    Attributes:
        db_path (str): Путь к файлу базы данных SQLite.
    """

    def __init__(self, db_path: str):
        """
        Инициализирует репозиторий.

        Args:
            db_path: Путь к файлу базы данных SQLite.
        """
        self.db_path = db_path
        logger.debug(f"{self.__class__.__name__} initialized with db_path: {db_path}")

    @contextmanager
    def get_connection(self):
        """
        Context manager для безопасной работы с соединением БД.

        Автоматически:
        - Открывает соединение
        - Коммитит транзакцию при успехе
        - Откатывает транзакцию при ошибке
        - Закрывает соединение

        Yields:
            sqlite3.Connection: Соединение с базой данных.

        Raises:
            Exception: Любая ошибка при работе с БД.

        Example:
            >>> with self.get_connection() as conn:
            >>>     cursor = conn.cursor()
            >>>     cursor.execute("SELECT * FROM items")
        """
        conn = None
        try:
            conn = sqlite3.connect(self.db_path)
            logger.trace(f"Database connection opened: {self.db_path}")
            yield conn
            conn.commit()
            logger.trace("Transaction committed")
        except Exception as e:
            if conn:
                conn.rollback()
                logger.warning("Transaction rolled back due to error")
            logger.error(f"Database error in {self.__class__.__name__}: {e}")
            raise
        finally:
            if conn:
                conn.close()
                logger.trace("Database connection closed")

    @abstractmethod
    def create_table(self):
        """
        Создает таблицу в БД (если не существует).

        Должен быть реализован в каждом конкретном репозитории.
        """
        pass