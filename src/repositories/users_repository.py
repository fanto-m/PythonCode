"""Репозиторий для управления пользователями

Расположение: src/repositories/users_repository.py
"""

import hashlib
import secrets
from datetime import datetime
from typing import Optional, List
from dataclasses import dataclass

from loguru import logger

from repositories.base_repository import BaseRepository


@dataclass
class UserDTO:
    """Data Transfer Object для пользователя."""
    id: int
    username: str
    password_hash: str
    salt: str
    role: str
    is_active: bool
    created_at: datetime
    failed_attempts: int = 0


class UsersRepository(BaseRepository):
    """Репозиторий для управления пользователями."""

    def __init__(self, db_path: str = "users.db"):
        """
        Инициализация репозитория.

        Args:
            db_path: Путь к базе данных пользователей.
        """
        super().__init__(db_path)
        self.create_table()
        self._ensure_admin_exists()

    def create_table(self):
        """Создание таблицы users если не существует."""
        with self.get_connection() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL,
                    salt TEXT NOT NULL,
                    role TEXT DEFAULT 'user',
                    is_active INTEGER DEFAULT 1,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    failed_attempts INTEGER DEFAULT 0
                )
            """)
        logger.debug("Users table ensured")

    def _ensure_admin_exists(self):
        """Создание admin при первом запуске."""
        admin = self.get_by_username("admin")
        if admin is None:
            # Дефолтный пароль admin123 — требует смены при первом входе
            self.create("admin", "admin123", role="admin")
            logger.warning("⚠️ Default admin created with password 'admin123' - CHANGE IT!")

    @staticmethod
    def _hash_password(password: str, salt: str = None) -> tuple[str, str]:
        """
        Хэширование пароля с солью.

        Args:
            password: Пароль в открытом виде.
            salt: Соль (если None — генерируется новая).

        Returns:
            Кортеж (hash, salt).
        """
        if salt is None:
            salt = secrets.token_hex(32)

        password_hash = hashlib.pbkdf2_hmac(
            'sha256',
            password.encode('utf-8'),
            salt.encode('utf-8'),
            100000  # Количество итераций
        ).hex()

        return password_hash, salt

    def verify_password(self, password: str, password_hash: str, salt: str) -> bool:
        """
        Проверка пароля.

        Args:
            password: Пароль для проверки.
            password_hash: Хэш из базы.
            salt: Соль из базы.

        Returns:
            True если пароль верный.
        """
        computed_hash, _ = self._hash_password(password, salt)
        return computed_hash == password_hash

    def create(self, username: str, password: str, role: str = "user") -> Optional[int]:
        """
        Создание нового пользователя.

        Args:
            username: Имя пользователя.
            password: Пароль.
            role: Роль ('admin', 'manager', 'user').

        Returns:
            ID созданного пользователя или None при ошибке.
        """
        try:
            password_hash, salt = self._hash_password(password)

            with self.get_connection() as conn:
                cursor = conn.execute("""
                    INSERT INTO users (username, password_hash, salt, role)
                    VALUES (?, ?, ?, ?)
                """, (username, password_hash, salt, role))
                user_id = cursor.lastrowid

            logger.info(f"✅ User created: {username} (id={user_id}, role={role})")
            return user_id

        except Exception as e:
            logger.error(f"❌ Failed to create user {username}: {e}")
            return None

    def get_by_id(self, user_id: int) -> Optional[UserDTO]:
        """Получение пользователя по ID."""
        with self.get_connection() as conn:
            cursor = conn.execute(
                "SELECT * FROM users WHERE id = ?",
                (user_id,)
            )
            row = cursor.fetchone()
        return self._row_to_dto(row) if row else None

    def get_by_username(self, username: str) -> Optional[UserDTO]:
        """Получение пользователя по имени."""
        with self.get_connection() as conn:
            cursor = conn.execute(
                "SELECT * FROM users WHERE username = ?",
                (username,)
            )
            row = cursor.fetchone()
        return self._row_to_dto(row) if row else None

    def get_all(self, include_inactive: bool = False) -> List[UserDTO]:
        """
        Получение списка всех пользователей.

        Args:
            include_inactive: Включать неактивных пользователей.
        """
        with self.get_connection() as conn:
            if include_inactive:
                cursor = conn.execute("SELECT * FROM users ORDER BY username")
            else:
                cursor = conn.execute(
                    "SELECT * FROM users WHERE is_active = 1 ORDER BY username"
                )
            rows = cursor.fetchall()
        return [self._row_to_dto(row) for row in rows]

    def update(self, user_id: int, **kwargs) -> bool:
        """
        Обновление данных пользователя.

        Args:
            user_id: ID пользователя.
            **kwargs: Поля для обновления (username, role, is_active).
        """
        allowed_fields = {'username', 'role', 'is_active'}
        fields = {k: v for k, v in kwargs.items() if k in allowed_fields}

        if not fields:
            return False

        set_clause = ", ".join(f"{k} = ?" for k in fields.keys())
        values = list(fields.values()) + [user_id]

        try:
            with self.get_connection() as conn:
                conn.execute(
                    f"UPDATE users SET {set_clause} WHERE id = ?",
                    values
                )
            logger.info(f"✅ User {user_id} updated: {fields}")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to update user {user_id}: {e}")
            return False

    def change_password(self, user_id: int, new_password: str) -> bool:
        """
        Смена пароля пользователя.

        Args:
            user_id: ID пользователя.
            new_password: Новый пароль.
        """
        try:
            password_hash, salt = self._hash_password(new_password)

            with self.get_connection() as conn:
                conn.execute("""
                    UPDATE users 
                    SET password_hash = ?, salt = ?, failed_attempts = 0
                    WHERE id = ?
                """, (password_hash, salt, user_id))

            logger.info(f"✅ Password changed for user {user_id}")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to change password for user {user_id}: {e}")
            return False

    def increment_failed_attempts(self, username: str) -> int:
        """
        Увеличение счётчика неудачных попыток.

        Returns:
            Новое значение счётчика.
        """
        with self.get_connection() as conn:
            conn.execute("""
                UPDATE users 
                SET failed_attempts = failed_attempts + 1
                WHERE username = ?
            """, (username,))

            cursor = conn.execute(
                "SELECT failed_attempts FROM users WHERE username = ?",
                (username,)
            )
            row = cursor.fetchone()
        return row[0] if row else 0

    def reset_failed_attempts(self, user_id: int):
        """Сброс счётчика неудачных попыток."""
        with self.get_connection() as conn:
            conn.execute(
                "UPDATE users SET failed_attempts = 0 WHERE id = ?",
                (user_id,)
            )

    def delete(self, user_id: int) -> bool:
        """
        Удаление пользователя (мягкое — деактивация).

        Args:
            user_id: ID пользователя.
        """
        # Нельзя удалить последнего admin
        with self.get_connection() as conn:
            cursor = conn.execute(
                "SELECT id FROM users WHERE role = 'admin' AND is_active = 1"
            )
            admins = cursor.fetchall()

        user = self.get_by_id(user_id)
        if user and user.role == 'admin' and len(admins) <= 1:
            logger.warning("❌ Cannot delete last admin!")
            return False

        return self.update(user_id, is_active=False)

    def hard_delete(self, user_id: int) -> bool:
        """
        Полное удаление пользователя из базы данных.

        Args:
            user_id: ID пользователя.

        Returns:
            True если удален, False если ошибка или это последний admin.
        """
        # Нельзя удалить последнего admin
        with self.get_connection() as conn:
            cursor = conn.execute(
                "SELECT id FROM users WHERE role = 'admin'"
            )
            admins = cursor.fetchall()

        user = self.get_by_id(user_id)
        if user and user.role == 'admin' and len(admins) <= 1:
            logger.warning("❌ Cannot permanently delete last admin!")
            return False

        try:
            with self.get_connection() as conn:
                conn.execute("DELETE FROM users WHERE id = ?", (user_id,))
            logger.info(f"🗑️ User {user_id} permanently deleted")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to permanently delete user {user_id}: {e}")
            return False

    def _row_to_dto(self, row) -> UserDTO:
        """Конвертация строки БД в DTO."""
        return UserDTO(
            id=row[0],
            username=row[1],
            password_hash=row[2],
            salt=row[3],
            role=row[4],
            is_active=bool(row[5]),
            created_at=datetime.fromisoformat(row[6]) if row[6] else datetime.now(),
            failed_attempts=row[7] if len(row) > 7 else 0
        )