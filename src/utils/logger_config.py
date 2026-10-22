# src/utils/logger_config.py
"""Централизованная настройка логирования с Loguru"""

import sys
from pathlib import Path
from loguru import logger


def setup_logging(
        log_level: str = "INFO",
        log_dir: str = "logs",
        rotation: str = "10 MB",
        retention: str = "1 week",
        compression: str = "zip"
):
    """
    Настраивает логирование для приложения.

    Args:
        log_level: Уровень логирования (TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL).
        log_dir: Директория для логов.
        rotation: Когда создавать новый файл (размер или время).
        retention: Как долго хранить старые логи.
        compression: Сжимать ли старые логи.
    """
    # Определяем базовую директорию:
    # В сборке PyInstaller — рядом с main.exe, в PyCharm — в корне проекта
    if getattr(sys, "frozen", False):
        base_dir = Path(sys.executable).resolve().parent
    else:
        # src/utils -> поднимаемся на уровень корня проекта
        base_dir = Path(__file__).resolve().parent.parent.parent

    # Создаем директорию для логов
    log_path = base_dir / log_dir
    log_path.mkdir(parents=True, exist_ok=True)

    # Удаляем стандартный handler
    logger.remove()

    # 1. Консольный вывод (только если консоль существует)
    if sys.stderr is not None:
        logger.add(
            sys.stderr,
            level=log_level,
            format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
            colorize=True
        )

    # 2. Основной файл логов (с ротацией)
    logger.add(
        log_path / "app.log",
        level="DEBUG",
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
        rotation=rotation,
        retention=retention,
        compression=compression,
        encoding="utf-8"
    )

    # 3. Файл только для ошибок
    logger.add(
        log_path / "errors.log",
        level="ERROR",
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
        rotation="1 day",
        retention="30 days",
        compression="zip",
        encoding="utf-8"
    )

    # 4. JSON логи (для машинного анализа)
    logger.add(
        log_path / "app_json.log",
        level="DEBUG",
        format="{message}",
        rotation="1 day",
        retention="7 days",
        compression="zip",
        serialize=True,
        encoding="utf-8"
    )

    logger.info("=" * 80)
    logger.info("🚀 Application logging initialized")
    logger.info(f"📁 Log directory: {log_path.absolute()}")
    logger.info(f"📊 Log level: {log_level}")
    logger.info("=" * 80)


def get_logger():
    """
    Возвращает настроенный логгер.

    Returns:
        loguru.Logger: Настроенный логгер.
    """
    return logger


# Декоратор для логирования вызовов функций
def log_function_call(func):
    """
    Декоратор для автоматического логирования входа/выхода из функции.

    Usage:
        @log_function_call
        def my_function(a, b):
            return a + b
    """
    from functools import wraps

    @wraps(func)
    def wrapper(*args, **kwargs):
        logger.debug(f"Entering {func.__name__}() with args={args}, kwargs={kwargs}")
        try:
            result = func(*args, **kwargs)
            logger.debug(f"Exiting {func.__name__}() with result={result}")
            return result
        except Exception as e:
            logger.exception(f"Exception in {func.__name__}(): {e}")
            raise

    return wrapper