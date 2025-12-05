"""Репозиторий для истории входов

Расположение: src/repositories/login_history_repository.py
"""

from datetime import datetime, timedelta
from typing import Optional, List
from dataclasses import dataclass

from loguru import logger

from repositories.base_repository import BaseRepository


@dataclass
class LoginHistoryDTO:
    """Data Transfer Object для записи истории входа."""
    id: int
    user_id: int
    username: str  # Денормализовано для удобства
    login_time: datetime
    logout_time: Optional[datetime]
    logout_reason: Optional[str]  # 'manual', 'timeout', 'forced'
    session_duration: Optional[int]  # В секундах


class LoginHistoryRepository(BaseRepository):
    """Репозиторий для истории входов."""

    def __init__(self, db_path: str = "users.db"):
        """
        Инициализация репозитория.

        Args:
            db_path: Путь к базе данных.
        """
        super().__init__(db_path)
        self.create_table()

    def create_table(self):
        """Создание таблицы login_history если не существует."""
        with self.get_connection() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS login_history (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    username TEXT NOT NULL,
                    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    logout_time DATETIME,
                    logout_reason TEXT,
                    session_duration INTEGER,
                    FOREIGN KEY (user_id) REFERENCES users(id)
                )
            """)

            # Индекс для быстрого поиска по пользователю и времени
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_login_history_user 
                ON login_history(user_id, login_time DESC)
            """)

        logger.debug("Login history table ensured")

    def record_login(self, user_id: int, username: str) -> int:
        """
        Запись входа в систему.

        Args:
            user_id: ID пользователя.
            username: Имя пользователя.

        Returns:
            ID записи в истории.
        """
        with self.get_connection() as conn:
            cursor = conn.execute("""
                INSERT INTO login_history (user_id, username, login_time)
                VALUES (?, ?, ?)
            """, (user_id, username, datetime.now().isoformat()))
            record_id = cursor.lastrowid

        logger.info(f"📥 Login recorded: {username} (record_id={record_id})")
        return record_id

    def record_logout(self, record_id: int, reason: str = "manual") -> bool:
        """
        Запись выхода из системы.

        Args:
            record_id: ID записи входа.
            reason: Причина выхода ('manual', 'timeout', 'forced').
        """
        try:
            with self.get_connection() as conn:
                # Получаем время входа для расчёта длительности
                cursor = conn.execute(
                    "SELECT login_time FROM login_history WHERE id = ?",
                    (record_id,)
                )
                row = cursor.fetchone()

                if not row:
                    logger.warning(f"Login record {record_id} not found")
                    return False

                login_time = datetime.fromisoformat(row[0])
                logout_time = datetime.now()
                duration = int((logout_time - login_time).total_seconds())

                conn.execute("""
                    UPDATE login_history 
                    SET logout_time = ?, logout_reason = ?, session_duration = ?
                    WHERE id = ?
                """, (logout_time.isoformat(), reason, duration, record_id))

            logger.info(f"📤 Logout recorded: record_id={record_id}, reason={reason}, duration={duration}s")
            return True

        except Exception as e:
            logger.error(f"❌ Failed to record logout: {e}")
            return False

    def record_failed_login(self, username: str, reason: str = "invalid_password"):
        """
        Запись неудачной попытки входа.

        Args:
            username: Имя пользователя.
            reason: Причина ('invalid_password', 'user_not_found', 'account_locked').
        """
        with self.get_connection() as conn:
            conn.execute("""
                INSERT INTO login_history (user_id, username, login_time, logout_time, logout_reason)
                VALUES (0, ?, ?, ?, ?)
            """, (username, datetime.now().isoformat(), datetime.now().isoformat(), f"failed:{reason}"))

        logger.warning(f"⚠️ Failed login attempt: {username} ({reason})")

    def get_user_history(self, user_id: int, limit: int = 50) -> List[LoginHistoryDTO]:
        """
        Получение истории входов пользователя.

        Args:
            user_id: ID пользователя.
            limit: Максимальное количество записей.
        """
        with self.get_connection() as conn:
            cursor = conn.execute("""
                SELECT id, user_id, username, login_time, logout_time, logout_reason, session_duration
                FROM login_history
                WHERE user_id = ?
                ORDER BY login_time DESC
                LIMIT ?
            """, (user_id, limit))
            rows = cursor.fetchall()

        return [self._row_to_dto(row) for row in rows]

    def get_all_history(self, limit: int = 100, days: int = 30) -> List[LoginHistoryDTO]:
        """
        Получение всей истории входов за период.

        Args:
            limit: Максимальное количество записей.
            days: За сколько дней.
        """
        since = (datetime.now() - timedelta(days=days)).isoformat()

        with self.get_connection() as conn:
            cursor = conn.execute("""
                SELECT id, user_id, username, login_time, logout_time, logout_reason, session_duration
                FROM login_history
                WHERE login_time >= ?
                ORDER BY login_time DESC
                LIMIT ?
            """, (since, limit))
            rows = cursor.fetchall()

        return [self._row_to_dto(row) for row in rows]

    def get_active_sessions(self) -> List[LoginHistoryDTO]:
        """Получение активных сессий (без logout_time)."""
        with self.get_connection() as conn:
            cursor = conn.execute("""
                SELECT id, user_id, username, login_time, logout_time, logout_reason, session_duration
                FROM login_history
                WHERE logout_time IS NULL AND user_id > 0
                ORDER BY login_time DESC
            """)
            rows = cursor.fetchall()

        return [self._row_to_dto(row) for row in rows]

    def force_logout_user(self, user_id: int) -> int:
        """
        Принудительное завершение всех сессий пользователя.

        Args:
            user_id: ID пользователя.

        Returns:
            Количество завершённых сессий.
        """
        with self.get_connection() as conn:
            cursor = conn.execute("""
                SELECT id FROM login_history
                WHERE user_id = ? AND logout_time IS NULL
            """, (user_id,))
            active = cursor.fetchall()

        count = 0
        for row in active:
            if self.record_logout(row[0], reason="forced"):
                count += 1

        logger.info(f"🚫 Force logout user {user_id}: {count} sessions terminated")
        return count

    def get_failed_attempts_count(self, username: str, minutes: int = 15) -> int:
        """
        Подсчёт неудачных попыток входа за период.

        Args:
            username: Имя пользователя.
            minutes: За сколько минут считать.

        Returns:
            Количество неудачных попыток.
        """
        since = (datetime.now() - timedelta(minutes=minutes)).isoformat()

        with self.get_connection() as conn:
            cursor = conn.execute("""
                SELECT COUNT(*) FROM login_history
                WHERE username = ? AND login_time >= ? AND logout_reason LIKE 'failed:%'
            """, (username, since))
            row = cursor.fetchone()

        return row[0] if row else 0

    def cleanup_old_records(self, days: int = 90) -> int:
        """
        Удаление старых записей.

        Args:
            days: Удалять записи старше N дней.

        Returns:
            Количество удалённых записей.
        """
        cutoff = (datetime.now() - timedelta(days=days)).isoformat()

        with self.get_connection() as conn:
            cursor = conn.execute("""
                DELETE FROM login_history WHERE login_time < ?
            """, (cutoff,))
            count = cursor.rowcount

        logger.info(f"🗑️ Cleaned up {count} old login history records")
        return count

    def delete_user_history(self, user_id: int) -> int:
        """
        Удаление всей истории входов пользователя.

        Args:
            user_id: ID пользователя.

        Returns:
            Количество удалённых записей.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.execute(
                    "DELETE FROM login_history WHERE user_id = ?",
                    (user_id,)
                )
                count = cursor.rowcount

            logger.info(f"🗑️ Deleted {count} login history records for user {user_id}")
            return count
        except Exception as e:
            logger.error(f"❌ Failed to delete history for user {user_id}: {e}")
            return 0

    def _row_to_dto(self, row) -> LoginHistoryDTO:
        """Конвертация строки БД в DTO."""
        return LoginHistoryDTO(
            id=row[0],
            user_id=row[1],
            username=row[2],
            login_time=datetime.fromisoformat(row[3]) if row[3] else None,
            logout_time=datetime.fromisoformat(row[4]) if row[4] else None,
            logout_reason=row[5],
            session_duration=row[6]
        )