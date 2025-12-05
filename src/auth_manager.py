"""Менеджер авторизации с таймером неактивности

Расположение: src/auth_manager.py
"""

from datetime import datetime
from typing import Optional

from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

from loguru import logger

from repositories.users_repository import UsersRepository, UserDTO
from repositories.login_history_repository import LoginHistoryRepository


class AuthManager(QObject):
    """
    Менеджер авторизации.

    Отвечает за:
    - Вход/выход пользователей
    - Таймер неактивности (автовыход)
    - Логирование входов
    """

    # === Сигналы ===
    loginSuccessful = Signal(str, str)  # username, role
    loginFailed = Signal(str)           # причина
    loggedOut = Signal(str)             # причина ('manual', 'timeout', 'forced')
    inactivityWarning = Signal(int)     # секунд до автовыхода

    # Сигналы для QML property binding
    currentUserChanged = Signal()
    currentRoleChanged = Signal()
    isLoggedInChanged = Signal()

    # Константы
    INACTIVITY_TIMEOUT = 20 * 60  # 20 минут в секундах
    WARNING_TIME = 2 * 60         # Предупреждение за 2 минуты
    MAX_FAILED_ATTEMPTS = 5       # Блокировка после 5 попыток

    def __init__(self, db_path: str = "users.db", parent=None):
        """
        Инициализация менеджера.

        Args:
            db_path: Путь к базе данных пользователей.
            parent: Родительский QObject.
        """
        super().__init__(parent)

        # Репозитории
        self._users_repo = UsersRepository(db_path)
        self._history_repo = LoginHistoryRepository(db_path)

        # Состояние
        self._current_user: Optional[UserDTO] = None
        self._session_record_id: Optional[int] = None
        self._session_start_time: Optional[datetime] = None

        # Таймер неактивности
        self._inactivity_timer = QTimer(self)
        self._inactivity_timer.timeout.connect(self._on_inactivity_timeout)

        # Таймер предупреждения
        self._warning_timer = QTimer(self)
        self._warning_timer.timeout.connect(self._on_warning_timeout)
        self._warning_seconds_left = 0

        logger.info("AuthManager initialized")

    # === Properties для QML ===

    @Property(str, notify=currentUserChanged)
    def currentUser(self) -> str:
        """Имя текущего пользователя."""
        return self._current_user.username if self._current_user else ""

    @Property(str, notify=currentRoleChanged)
    def currentRole(self) -> str:
        """Роль текущего пользователя."""
        return self._current_user.role if self._current_user else ""

    @Property(bool, notify=isLoggedInChanged)
    def isLoggedIn(self) -> bool:
        """Авторизован ли пользователь."""
        return self._current_user is not None

    @Property(int, constant=True)
    def inactivityTimeout(self) -> int:
        """Таймаут неактивности в секундах."""
        return self.INACTIVITY_TIMEOUT

    # === Проверка прав доступа ===

    @Slot(result=bool)
    def canEdit(self) -> bool:
        """Может ли пользователь редактировать склад."""
        if not self._current_user:
            return False
        return self._current_user.role in ("admin", "manager")

    @Slot(result=bool)
    def canCreateSpecification(self) -> bool:
        """Может ли пользователь создавать спецификации."""
        if not self._current_user:
            return False
        return self._current_user.role in ("admin", "manager")

    @Slot(result=bool)
    def canManageUsers(self) -> bool:
        """Может ли пользователь управлять пользователями."""
        return self._is_admin()

    # === Методы авторизации ===

    @Slot(str, str, result=bool)
    def login(self, username: str, password: str) -> bool:
        """
        Вход в систему.

        Args:
            username: Имя пользователя.
            password: Пароль.

        Returns:
            True при успешном входе.
        """
        logger.info(f"🔐 Login attempt: {username}")

        # Проверка блокировки
        failed_count = self._history_repo.get_failed_attempts_count(username)
        if failed_count >= self.MAX_FAILED_ATTEMPTS:
            reason = "Аккаунт временно заблокирован. Попробуйте через 15 минут."
            logger.warning(f"⛔ Account locked: {username} ({failed_count} failed attempts)")
            self._history_repo.record_failed_login(username, "account_locked")
            self.loginFailed.emit(reason)
            return False

        # Поиск пользователя
        user = self._users_repo.get_by_username(username)

        if user is None:
            logger.warning(f"❌ User not found: {username}")
            self._history_repo.record_failed_login(username, "user_not_found")
            self.loginFailed.emit("Неверное имя пользователя или пароль")
            return False

        # Проверка активности
        if not user.is_active:
            logger.warning(f"❌ User inactive: {username}")
            self._history_repo.record_failed_login(username, "user_inactive")
            self.loginFailed.emit("Аккаунт деактивирован")
            return False

        # Проверка пароля
        if not self._users_repo.verify_password(password, user.password_hash, user.salt):
            self._users_repo.increment_failed_attempts(username)
            self._history_repo.record_failed_login(username, "invalid_password")
            logger.warning(f"❌ Invalid password: {username}")
            self.loginFailed.emit("Неверное имя пользователя или пароль")
            return False

        # Успешный вход
        self._current_user = user
        self._session_start_time = datetime.now()
        self._session_record_id = self._history_repo.record_login(user.id, user.username)

        # Сброс счётчика неудачных попыток
        self._users_repo.reset_failed_attempts(user.id)

        # Запуск таймера неактивности
        self._start_inactivity_timer()

        # Уведомления
        self.currentUserChanged.emit()
        self.currentRoleChanged.emit()
        self.isLoggedInChanged.emit()
        self.loginSuccessful.emit(user.username, user.role)

        logger.success(f"✅ Login successful: {username} (role={user.role})")
        return True

    @Slot()
    @Slot(str)
    def logout(self, reason: str = "manual"):
        """
        Выход из системы.

        Args:
            reason: Причина выхода ('manual', 'timeout', 'forced').
        """
        if self._current_user is None:
            return

        username = self._current_user.username

        # Запись выхода
        if self._session_record_id:
            self._history_repo.record_logout(self._session_record_id, reason)

        # Остановка таймеров
        self._inactivity_timer.stop()
        self._warning_timer.stop()

        # Сброс состояния
        self._current_user = None
        self._session_record_id = None
        self._session_start_time = None

        # Уведомления
        self.currentUserChanged.emit()
        self.currentRoleChanged.emit()
        self.isLoggedInChanged.emit()
        self.loggedOut.emit(reason)

        logger.info(f"📤 Logged out: {username} (reason={reason})")

    @Slot()
    def resetInactivityTimer(self):
        """Сброс таймера неактивности (вызывается при активности пользователя)."""
        if self._current_user is None:
            return

        # Остановка предупреждения если было
        if self._warning_timer.isActive():
            self._warning_timer.stop()
            logger.debug("Warning timer stopped - user activity detected")

        # Перезапуск основного таймера
        self._start_inactivity_timer()

    # === Управление пользователями (только для admin) ===

    @Slot(str, str, str, result=bool)
    def createUser(self, username: str, password: str, role: str = "user") -> bool:
        """
        Создание нового пользователя.

        Args:
            username: Имя пользователя.
            password: Пароль.
            role: Роль.
        """
        if not self._is_admin():
            logger.warning("❌ Only admin can create users")
            return False

        user_id = self._users_repo.create(username, password, role)
        return user_id is not None

    @Slot(int, str, result=bool)
    def changeUserPassword(self, user_id: int, new_password: str) -> bool:
        """Смена пароля пользователя (admin или свой)."""
        if self._current_user is None:
            return False

        # Можно менять свой пароль или admin может менять любой
        if self._current_user.id != user_id and not self._is_admin():
            logger.warning("❌ Permission denied for password change")
            return False

        return self._users_repo.change_password(user_id, new_password)

    @Slot(str, str, result=bool)
    def changeOwnPassword(self, old_password: str, new_password: str) -> bool:
        """Смена своего пароля с проверкой старого."""
        if self._current_user is None:
            return False

        # Проверка старого пароля
        if not self._users_repo.verify_password(
            old_password,
            self._current_user.password_hash,
            self._current_user.salt
        ):
            logger.warning("❌ Old password incorrect")
            return False

        return self._users_repo.change_password(self._current_user.id, new_password)

    @Slot(int, result=bool)
    def deactivateUser(self, user_id: int) -> bool:
        """Деактивация пользователя."""
        if not self._is_admin():
            return False

        # Принудительный выход
        self._history_repo.force_logout_user(user_id)

        return self._users_repo.delete(user_id)

    @Slot(int, result=bool)
    def deleteUserPermanently(self, user_id: int) -> bool:
        """
        Полное удаление пользователя вместе с историей входов.

        Args:
            user_id: ID пользователя.

        Returns:
            True если удален, False если ошибка.
        """
        if not self._is_admin():
            logger.warning("❌ Only admin can permanently delete users")
            return False

        # Получаем информацию о пользователе
        user = self._users_repo.get_by_id(user_id)
        if not user:
            logger.warning(f"❌ User {user_id} not found")
            return False

        # Принудительный выход если онлайн
        self._history_repo.force_logout_user(user_id)

        # Удаляем историю входов
        history_count = self._history_repo.delete_user_history(user_id)
        logger.info(f"🗑️ Deleted {history_count} history records for user {user.username}")

        # Удаляем пользователя
        if self._users_repo.hard_delete(user_id):
            logger.info(f"🗑️ User '{user.username}' permanently deleted with all history")
            return True

        return False

    @Slot(int, str, bool, result=bool)
    def updateUser(self, user_id: int, role: str, is_active: bool) -> bool:
        """
        Обновление данных пользователя.

        Args:
            user_id: ID пользователя.
            role: Новая роль.
            is_active: Активен ли пользователь.
        """
        if not self._is_admin():
            logger.warning("❌ Only admin can update users")
            return False

        try:
            result = self._users_repo.update(user_id, role=role, is_active=is_active)
            if result:
                logger.info(f"✅ User {user_id} updated: role={role}, is_active={is_active}")
            return result
        except Exception as e:
            logger.error(f"❌ Failed to update user {user_id}: {e}")
            return False

    @Slot(result="QVariantList")
    def getUsers(self) -> list:
        """Получение списка пользователей (для admin)."""
        if not self._is_admin():
            return []

        users = self._users_repo.get_all(include_inactive=True)
        return [
            {
                "id": u.id,
                "username": u.username,
                "role": u.role,
                "is_active": u.is_active,
                "created_at": u.created_at.strftime("%d.%m.%Y") if u.created_at else ""
            }
            for u in users
        ]

    @Slot(result="QVariantList")
    def getActiveUsers(self) -> list:
        """Получение списка активных пользователей (для формы логина)."""
        users = self._users_repo.get_all(include_inactive=False)
        return [
            {
                "id": u.id,
                "username": u.username,
                "role": u.role
            }
            for u in users
        ]

    @Slot(result="QVariantList")
    def getLoginHistory(self) -> list:
        """Получение истории входов (для admin)."""
        if not self._is_admin():
            return []

        history = self._history_repo.get_all_history(limit=100)
        return [
            {
                "id": h.id,
                "username": h.username,
                "login_time": h.login_time.strftime("%d.%m.%Y %H:%M") if h.login_time else "",
                "logout_time": h.logout_time.strftime("%d.%m.%Y %H:%M") if h.logout_time else "—",
                "logout_reason": self._format_logout_reason(h.logout_reason),
                "duration": self._format_duration(h.session_duration)
            }
            for h in history
        ]

    @Slot(result="QVariantList")
    def getActiveSessions(self) -> list:
        """Получение активных сессий (для admin)."""
        if not self._is_admin():
            return []

        sessions = self._history_repo.get_active_sessions()
        return [
            {
                "id": s.id,
                "user_id": s.user_id,
                "username": s.username,
                "login_time": s.login_time.strftime("%d.%m.%Y %H:%M") if s.login_time else "",
                "duration": self._format_duration(
                    int((datetime.now() - s.login_time).total_seconds()) if s.login_time else 0
                )
            }
            for s in sessions
        ]

    @Slot(int)
    def forceLogoutUser(self, user_id: int):
        """Принудительный выход пользователя."""
        if not self._is_admin():
            return

        self._history_repo.force_logout_user(user_id)

    # === Приватные методы ===

    def _is_admin(self) -> bool:
        """Проверка что текущий пользователь — admin."""
        return self._current_user is not None and self._current_user.role == "admin"

    def _start_inactivity_timer(self):
        """Запуск таймера неактивности."""
        # Таймер на время до предупреждения
        warning_delay = (self.INACTIVITY_TIMEOUT - self.WARNING_TIME) * 1000
        self._inactivity_timer.start(warning_delay)
        logger.trace(f"Inactivity timer started: {warning_delay/1000}s until warning")

    def _on_inactivity_timeout(self):
        """Обработчик таймаута — показ предупреждения."""
        self._inactivity_timer.stop()

        # Запуск таймера предупреждения (каждую секунду)
        self._warning_seconds_left = self.WARNING_TIME
        self._warning_timer.start(1000)

        # Первое предупреждение
        self.inactivityWarning.emit(self._warning_seconds_left)
        logger.info(f"⚠️ Inactivity warning: {self._warning_seconds_left}s left")

    def _on_warning_timeout(self):
        """Обработчик таймера предупреждения (каждую секунду)."""
        self._warning_seconds_left -= 1

        if self._warning_seconds_left <= 0:
            # Время вышло — автовыход
            self._warning_timer.stop()
            logger.info("⏰ Inactivity timeout - auto logout")
            self.logout("timeout")
        else:
            # Обновление счётчика
            self.inactivityWarning.emit(self._warning_seconds_left)

    @staticmethod
    def _format_logout_reason(reason: Optional[str]) -> str:
        """Форматирование причины выхода для отображения."""
        if reason is None:
            return "активен"

        mapping = {
            "manual": "вручную",
            "timeout": "таймаут",
            "forced": "принудительно"
        }

        if reason.startswith("failed:"):
            return f"ошибка: {reason[7:]}"

        return mapping.get(reason, reason)

    @staticmethod
    def _format_duration(seconds: Optional[int]) -> str:
        """Форматирование длительности сессии."""
        if seconds is None or seconds <= 0:
            return "—"

        hours = seconds // 3600
        minutes = (seconds % 3600) // 60

        if hours > 0:
            return f"{hours}ч {minutes}м"
        return f"{minutes}м"