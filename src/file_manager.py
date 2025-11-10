#file_manager.py
"""
FileManager - Централизованный менеджер для работы с файлами (v2.1 - БЕЗ ДУБЛИКАТОВ).

ОБНОВЛЕНИЕ v2.1: Добавлена проверка на дубликаты по содержимому файла.
Если файл с таким же содержимым уже существует в директории, возвращается путь к существующему файлу.
"""

import os
import shutil
import hashlib
from pathlib import Path
from typing import Optional, Tuple
from PySide6.QtCore import QObject, Signal, Slot, Property, QUrl
import json

class FileManager(QObject):
    """Менеджер для работы с файлами и директориями приложения."""

    # Сигналы для уведомления об ошибках
    fileError = Signal(str)
    fileOperationSuccess = Signal(str)

    def __init__(self, config_manager, base_path: Optional[str] = None):
        """
        Инициализирует FileManager.

        Args:
            config_manager: Экземпляр ConfigManager для чтения настроек структуры.
            base_path: Базовый путь к папке src. Если None, использует текущую директорию.
        """
        super().__init__()

        self._config_manager = config_manager

        if base_path is None:
            self._base_path = Path(__file__).parent.resolve()
        else:
            self._base_path = Path(base_path).resolve()

        # Получаем настройки из ConfigManager
        self._load_structure_from_config()

        # Создаем структуру директорий
        self._ensure_directory_structure()

    def _load_structure_from_config(self):
        """Загружает настройки структуры каталогов из ConfigManager."""
        file_storage = self._config_manager.get_file_storage_config()

        self.FILES_ROOT = file_storage.get("root_directory", "files")
        self._files_root = self._base_path / self.FILES_ROOT

        images_config = file_storage.get("images", {})
        self.IMAGES_DIR = images_config.get("directory", "images")

        self.IMAGE_SUBDIRS = {}
        for key, value in images_config.get("subdirectories", {}).items():
            self.IMAGE_SUBDIRS[key] = value.get("name", key)

        documents_config = file_storage.get("documents", {})
        self.DOCUMENTS_DIR = documents_config.get("directory", "documents")

        self.DOCUMENT_SUBDIRS = {}
        for key, value in documents_config.get("subdirectories", {}).items():
            self.DOCUMENT_SUBDIRS[key] = value.get("name", key)

        print(f"DEBUG: FileManager loaded structure from config")
        print(f"  Root: {self.FILES_ROOT}")
        print(f"  Images: {self.IMAGES_DIR} with {len(self.IMAGE_SUBDIRS)} subdirs")
        print(f"  Documents: {self.DOCUMENTS_DIR} with {len(self.DOCUMENT_SUBDIRS)} subdirs")

    def _ensure_directory_structure(self):
        """Создает необходимую структуру директорий, если она не существует."""
        try:
            self._files_root.mkdir(exist_ok=True)

            images_path = self._files_root / self.IMAGES_DIR
            images_path.mkdir(exist_ok=True)
            for subdir in self.IMAGE_SUBDIRS.values():
                (images_path / subdir).mkdir(exist_ok=True)

            documents_path = self._files_root / self.DOCUMENTS_DIR
            documents_path.mkdir(exist_ok=True)
            for subdir in self.DOCUMENT_SUBDIRS.values():
                (documents_path / subdir).mkdir(exist_ok=True)

            print(f"DEBUG: Directory structure created at {self._files_root}")

        except Exception as e:
            error_msg = f"Error creating directory structure: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.fileError.emit(error_msg)

    def _calculate_file_hash(self, file_path: Path, chunk_size: int = 8192) -> str:
        """
        Вычисляет SHA-256 хеш файла для проверки на дубликаты.

        Args:
            file_path: Путь к файлу.
            chunk_size: Размер чанка для чтения (по умолчанию 8KB).

        Returns:
            Строка с хешем файла в hex формате.
        """
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(chunk_size), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()

    def _find_duplicate_file(self, source_path: Path, target_dir: Path) -> Optional[Path]:
        """
        Ищет файл с таким же содержимым в целевой директории.

        Args:
            source_path: Путь к исходному файлу.
            target_dir: Целевая директория для поиска.

        Returns:
            Path к найденному дубликату или None, если дубликат не найден.
        """
        try:
            # Вычисляем хеш исходного файла
            source_hash = self._calculate_file_hash(source_path)
            source_size = source_path.stat().st_size

            # Проверяем все файлы в целевой директории
            for existing_file in target_dir.iterdir():
                if existing_file.is_file():
                    # Быстрая проверка по размеру
                    if existing_file.stat().st_size == source_size:
                        # Если размер совпадает, проверяем хеш
                        existing_hash = self._calculate_file_hash(existing_file)
                        if existing_hash == source_hash:
                            print(f"DEBUG: Found duplicate file: {existing_file.name}")
                            return existing_file

            return None

        except Exception as e:
            print(f"DEBUG: Error checking for duplicates: {str(e)}")
            return None

    @Slot(str, str, result=str)
    def copy_image_to_storage(self, source_path: str, subdirectory: str = "other") -> str:
        """
        Копирует изображение в хранилище приложения.
        Если файл с таким же содержимым уже существует, возвращает путь к существующему файлу.

        Args:
            source_path: Полный путь к исходному файлу.
            subdirectory: ID поддиректории из конфига (modules, sensors, components, other).

        Returns:
            Относительный путь к файлу от папки src или пустую строку при ошибке.
        """
        try:
            source = Path(source_path)
            if not source.exists():
                raise FileNotFoundError(f"Source file not found: {source_path}")

            # Проверяем, что поддиректория валидна
            if subdirectory not in self.IMAGE_SUBDIRS:
                subdirectory = "other"

            # Формируем путь назначения
            subdir_name = self.IMAGE_SUBDIRS[subdirectory]
            dest_dir = self._files_root / self.IMAGES_DIR / subdir_name

            # НОВОЕ: Проверяем, нет ли уже такого же файла по содержимому
            duplicate = self._find_duplicate_file(source, dest_dir)
            if duplicate:
                # Файл уже существует - возвращаем путь к нему
                relative_path = duplicate.relative_to(self._base_path)
                relative_path_str = str(relative_path).replace("\\", "/")

                print(f"DEBUG: Image already exists (duplicate found): {relative_path_str}")
                self.fileOperationSuccess.emit(f"Image already exists: {duplicate.name}")

                return relative_path_str

            # Формируем имя файла
            dest_file = dest_dir / source.name

            # Если файл с таким именем существует (но содержимое другое), добавляем суффикс
            if dest_file.exists():
                base_name = source.stem
                extension = source.suffix
                counter = 1
                while dest_file.exists():
                    new_name = f"{base_name}_{counter}{extension}"
                    dest_file = dest_dir / new_name
                    counter += 1

            # Копируем файл
            shutil.copy2(source, dest_file)

            # Возвращаем относительный путь от папки src
            relative_path = dest_file.relative_to(self._base_path)
            relative_path_str = str(relative_path).replace("\\", "/")

            print(f"DEBUG: Image copied to {relative_path_str}")
            self.fileOperationSuccess.emit(f"Image saved: {dest_file.name}")

            return relative_path_str

        except Exception as e:
            error_msg = f"Error copying image: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.fileError.emit(error_msg)
            return ""

    @Slot(str, str, result=str)
    def copy_document_to_storage(self, source_path: str, subdirectory: str = "other") -> str:
        """
        Копирует документ в хранилище приложения.
        Если файл с таким же содержимым уже существует, возвращает путь к существующему файлу.

        Args:
            source_path: Полный путь к исходному файлу.
            subdirectory: ID поддиректории из конфига (datasheets, invoices, etc).

        Returns:
            Относительный путь к файлу от папки src или пустую строку при ошибке.
        """
        try:
            source = Path(source_path)
            if not source.exists():
                raise FileNotFoundError(f"Source file not found: {source_path}")

            # Проверяем, что поддиректория валидна
            if subdirectory not in self.DOCUMENT_SUBDIRS:
                subdirectory = "other"

            # Формируем путь назначения
            subdir_name = self.DOCUMENT_SUBDIRS[subdirectory]
            dest_dir = self._files_root / self.DOCUMENTS_DIR / subdir_name

            # НОВОЕ: Проверяем, нет ли уже такого же файла по содержимому
            duplicate = self._find_duplicate_file(source, dest_dir)
            if duplicate:
                # Файл уже существует - возвращаем путь к нему
                relative_path = duplicate.relative_to(self._base_path)
                relative_path_str = str(relative_path).replace("\\", "/")

                print(f"DEBUG: Document already exists (duplicate found): {relative_path_str}")
                self.fileOperationSuccess.emit(f"Document already exists: {duplicate.name}")

                return relative_path_str

            # Формируем имя файла
            dest_file = dest_dir / source.name

            # Если файл с таким именем существует (но содержимое другое), добавляем суффикс
            if dest_file.exists():
                base_name = source.stem
                extension = source.suffix
                counter = 1
                while dest_file.exists():
                    new_name = f"{base_name}_{counter}{extension}"
                    dest_file = dest_dir / new_name
                    counter += 1

            # Копируем файл
            shutil.copy2(source, dest_file)

            # Возвращаем относительный путь от папки src
            relative_path = dest_file.relative_to(self._base_path)
            relative_path_str = str(relative_path).replace("\\", "/")

            print(f"DEBUG: Document copied to {relative_path_str}")
            self.fileOperationSuccess.emit(f"Document saved: {dest_file.name}")

            return relative_path_str

        except Exception as e:
            error_msg = f"Error copying document: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.fileError.emit(error_msg)
            return ""

    @Slot(str, result=str)
    def get_absolute_path(self, relative_path: str) -> str:
        """Получает абсолютный путь к файлу из относительного пути."""
        if not relative_path:
            return ""
        abs_path = self._base_path / relative_path
        return str(abs_path).replace("\\", "/")

    @Slot(str, result=bool)
    def file_exists(self, relative_path: str) -> bool:
        """Проверяет существование файла по относительному пути."""
        if not relative_path:
            return False
        file_path = self._base_path / relative_path
        return file_path.exists()

    @Slot(str, result=bool)
    def delete_file(self, relative_path: str) -> bool:
        """Удаляет файл по относительному пути."""
        try:
            if not relative_path:
                return False
            file_path = self._base_path / relative_path
            if file_path.exists():
                file_path.unlink()
                print(f"DEBUG: File deleted: {relative_path}")
                self.fileOperationSuccess.emit(f"File deleted: {file_path.name}")
                return True
            return False
        except Exception as e:
            error_msg = f"Error deleting file: {str(e)}"
            print(f"DEBUG: {error_msg}")
            self.fileError.emit(error_msg)
            return False

    @Slot(str, result=str)
    def open_file_externally(self, relative_path: str) -> str:
        """Открывает файл в системном приложении."""
        try:
            if not relative_path:
                return "No file path provided"
            file_path = self._base_path / relative_path
            if not file_path.exists():
                return f"File not found: {relative_path}"
            from PySide6.QtGui import QDesktopServices
            url = QUrl.fromLocalFile(str(file_path))
            if QDesktopServices.openUrl(url):
                print(f"DEBUG: File opened: {relative_path}")
                return ""
            else:
                return "Failed to open file"
        except Exception as e:
            error_msg = f"Error opening file: {str(e)}"
            print(f"DEBUG: {error_msg}")
            return error_msg

    @Slot(str, result=str)
    def get_file_name(self, relative_path: str) -> str:
        """Извлекает имя файла из относительного пути."""
        if not relative_path:
            return ""
        return Path(relative_path).name

    @Slot(str, result=str)
    def get_file_subdirectory(self, relative_path: str) -> str:
        """Извлекает поддиректорию из относительного пути."""
        if not relative_path:
            return "other"
        path = Path(relative_path)
        parts = path.parts
        if len(parts) >= 3:
            return parts[2]
        return "other"

    @Slot(result=str)
    def get_images_root_path(self) -> str:
        """Возвращает абсолютный путь к корневой директории изображений."""
        return str(self._files_root / self.IMAGES_DIR)

    @Slot()
    def reloadConfig(self):
        """Перезагружает конфигурацию из файла (без merge с defaults)"""
        try:
            print("=== ConfigManager: Reloading config from file ===")

            if os.path.exists(self._config_path):
                with open(self._config_path, 'r', encoding='utf-8') as f:
                    loaded_config = json.load(f)

                # Сбрасываем на defaults, затем применяем загруженные настройки
                self._config = self._load_default_config()
                self._deep_merge(self._config, loaded_config)

                print("Config reloaded successfully")

                # Выводим количество подкатегорий
                img_subdirs = self.getImageSubdirectories()
                doc_subdirs = self.getDocumentSubdirectories()
                print(f"Images subdirectories: {len(img_subdirs)}")
                print(f"Documents subdirectories: {len(doc_subdirs)}")

                # Испускаем сигналы об изменениях
                self.vatIncludedChanged.emit(self._config["vat_included"])
                self.vatRateChanged.emit(self._config["vat_rate"])
                self.defaultCurrencyChanged.emit(self._config["default_currency"])

            else:
                print(f"ERROR: Config file not found: {self._config_path}")

        except Exception as e:
            print(f"ERROR: Failed to reload config: {e}")
            import traceback
            traceback.print_exc()

    @Slot(result=str)
    def get_documents_root_path(self) -> str:
        """Возвращает абсолютный путь к корневой директории документов."""
        return str(self._files_root / self.DOCUMENTS_DIR)

    def migrate_old_paths(self, db_manager) -> Tuple[int, int]:
        """Миграция старых путей в базе данных к новой структуре."""
        images_migrated = 0
        documents_migrated = 0

        try:
            items = db_manager.load_data()

            for item in items:
                article = item[0]
                old_image_path = item[3]
                old_document_path = item[11]
                needs_update = False
                new_image_path = old_image_path
                new_document_path = old_document_path

                if old_image_path and not old_image_path.startswith(f"{self.FILES_ROOT}/"):
                    old_img_full_path = self._base_path / "images" / Path(old_image_path).name
                    if old_img_full_path.exists():
                        new_image_path = self.copy_image_to_storage(str(old_img_full_path), "other")
                        if new_image_path:
                            needs_update = True
                            images_migrated += 1
                            print(f"DEBUG: Migrated image for {article}: {old_image_path} -> {new_image_path}")

                if old_document_path and not old_document_path.startswith(f"{self.FILES_ROOT}/"):
                    old_doc_full_path = self._base_path / "documents" / Path(old_document_path).name
                    if old_doc_full_path.exists():
                        new_document_path = self.copy_document_to_storage(str(old_doc_full_path), "other")
                        if new_document_path:
                            needs_update = True
                            documents_migrated += 1
                            print(f"DEBUG: Migrated document for {article}: {old_document_path} -> {new_document_path}")

                if needs_update:
                    db_manager.update_item(
                        old_article=article,
                        article=article,
                        name=item[1],
                        description=item[2],
                        image_path=new_image_path,
                        category_id=self._get_category_id_by_name(db_manager, item[4]),
                        price=item[5],
                        stock=item[6],
                        status=item[8],
                        unit=item[9],
                        manufacturer=item[10],
                        document=new_document_path
                    )

            print(f"DEBUG: Migration completed: {images_migrated} images, {documents_migrated} documents")
            return images_migrated, documents_migrated

        except Exception as e:
            print(f"DEBUG: Error during migration: {str(e)}")
            return images_migrated, documents_migrated

    def _get_category_id_by_name(self, db_manager, category_name: str) -> Optional[int]:
        """Вспомогательный метод для получения ID категории по имени."""
        try:
            categories = db_manager.load_categories()
            for cat in categories:
                if cat[1] == category_name:
                    return cat[0]
            return None
        except Exception as e:
            print(f"DEBUG: Error getting category ID: {str(e)}")
            return None

    @Property(str, constant=True)
    def basePath(self) -> str:
        """Qt Property: базовый путь приложения."""
        return str(self._base_path)

    @Property(str, constant=True)
    def filesRootPath(self) -> str:
        """Qt Property: корневой путь к директории files."""
        return str(self._files_root)