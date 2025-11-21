"""
ValidationService - сервис валидации для интеграции с QML.
Предоставляет методы валидации, доступные из QML через Qt Slots.
"""
from PySide6.QtCore import QObject, Slot, Signal
from loguru import logger
from typing import Dict, Any

from validators import ItemValidator


class ValidationService(QObject):
    """
    Сервис валидации для QML.
    Предоставляет слоты для проверки отдельных полей и всей формы.
    """

    # Сигналы для уведомления QML об ошибках
    validationError = Signal(str, str)  # (fieldName, errorMessage)
    validationSuccess = Signal(str)  # (fieldName)
    formValidationComplete = Signal(bool, str)  # (isValid, firstErrorMessage)

    def __init__(self, parent=None):
        super().__init__(parent)
        logger.debug("ValidationService initialized")

    @Slot(str, result=str)
    def validateArticle(self, article: str) -> str:
        """
        Валидация артикула.

        Args:
            article: Артикул для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_article(article)

        if result.is_valid:
            self.validationSuccess.emit("article")
            return ""
        else:
            self.validationError.emit("article", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateName(self, name: str) -> str:
        """
        Валидация названия.

        Args:
            name: Название для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_name(name)

        if result.is_valid:
            self.validationSuccess.emit("name")
            return ""
        else:
            self.validationError.emit("name", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateDescription(self, description: str) -> str:
        """
        Валидация описания.

        Args:
            description: Описание для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_description(description)

        if result.is_valid:
            self.validationSuccess.emit("description")
            return ""
        else:
            self.validationError.emit("description", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validatePrice(self, price: str) -> str:
        """
        Валидация цены.

        Args:
            price: Цена для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_price(price)

        if result.is_valid:
            self.validationSuccess.emit("price")
            return ""
        else:
            self.validationError.emit("price", result.error_message)
            return result.error_message

    @Slot(int, result=str)
    def validateStock(self, stock: int) -> str:
        """
        Валидация остатка.

        Args:
            stock: Остаток для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_stock(stock)

        if result.is_valid:
            self.validationSuccess.emit("stock")
            return ""
        else:
            self.validationError.emit("stock", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateManufacturer(self, manufacturer: str) -> str:
        """
        Валидация производителя.

        Args:
            manufacturer: Производитель для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_manufacturer(manufacturer)

        if result.is_valid:
            self.validationSuccess.emit("manufacturer")
            return ""
        else:
            self.validationError.emit("manufacturer", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateUnit(self, unit: str) -> str:
        """
        Валидация единицы измерения.

        Args:
            unit: Единица измерения для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_unit(unit)

        if result.is_valid:
            self.validationSuccess.emit("unit")
            return ""
        else:
            self.validationError.emit("unit", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateStatus(self, status: str) -> str:
        """
        Валидация статуса.

        Args:
            status: Статус для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_status(status)

        if result.is_valid:
            self.validationSuccess.emit("status")
            return ""
        else:
            self.validationError.emit("status", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateImagePath(self, image_path: str) -> str:
        """
        Валидация пути к изображению.

        Args:
            image_path: Путь к изображению для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_image_path(image_path)

        if result.is_valid:
            self.validationSuccess.emit("imagePath")
            return ""
        else:
            self.validationError.emit("imagePath", result.error_message)
            return result.error_message

    @Slot(str, result=str)
    def validateDocumentPath(self, document_path: str) -> str:
        """
        Валидация пути к документу.

        Args:
            document_path: Путь к документу для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_document_path(document_path)

        if result.is_valid:
            self.validationSuccess.emit("documentPath")
            return ""
        else:
            self.validationError.emit("documentPath", result.error_message)
            return result.error_message

    @Slot(int, result=str)
    def validateCategory(self, category_id: int) -> str:
        """
        Валидация категории.

        Args:
            category_id: ID категории для проверки

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        result = ItemValidator.validate_category(category_id)

        if result.is_valid:
            self.validationSuccess.emit("category")
            return ""
        else:
            self.validationError.emit("category", result.error_message)
            return result.error_message

    @Slot('QVariantMap', result=bool)
    def validateForm(self, form_data: Dict[str, Any]) -> bool:
        """
        Валидация всей формы товара.

        Args:
            form_data: Словарь с данными формы
                {
                    "article": str,
                    "name": str,
                    "description": str,
                    "image_path": str,
                    "category_id": int,
                    "price": float,
                    "stock": int,
                    "manufacturer": str,
                    "unit": str,
                    "status": str,
                    "document_path": str
                }

        Returns:
            bool: True если все поля валидны, False если есть ошибки
        """
        logger.info("🔍 Validating form...")
        logger.debug(f"Form data: {form_data}")

        # Извлекаем данные из словаря с безопасными значениями по умолчанию
        article = form_data.get("article", "")
        name = form_data.get("name", "")
        description = form_data.get("description", "")
        image_path = form_data.get("image_path", "")
        category_id = form_data.get("category_id", 0)
        price = form_data.get("price", 0.0)
        stock = form_data.get("stock", 0)
        manufacturer = form_data.get("manufacturer", "")
        unit = form_data.get("unit", "")
        status = form_data.get("status", "")
        document_path = form_data.get("document_path", "")

        # Валидируем все поля
        is_valid, error_message = ItemValidator.validate_item(
            article=article,
            name=name,
            description=description,
            image_path=image_path,
            category_id=category_id,
            price=price,
            stock=stock,
            manufacturer=manufacturer,
            unit=unit,
            status=status,
            document_path=document_path
        )

        # Отправляем сигнал о завершении валидации
        self.formValidationComplete.emit(is_valid, error_message)

        if is_valid:
            logger.success("✅ Form validation passed")
        else:
            logger.warning(f"❌ Form validation failed: {error_message}")

        return is_valid

    @Slot(str, str, result=str)
    def validateField(self, field_name: str, value: str) -> str:
        """
        Универсальный метод валидации поля по имени.

        Args:
            field_name: Имя поля для валидации
            value: Значение поля

        Returns:
            str: Сообщение об ошибке или пустая строка при успехе
        """
        validators_map = {
            "article": self.validateArticle,
            "name": self.validateName,
            "description": self.validateDescription,
            "price": self.validatePrice,
            "manufacturer": self.validateManufacturer,
            "unit": self.validateUnit,
            "status": self.validateStatus,
            "imagePath": self.validateImagePath,
            "documentPath": self.validateDocumentPath,
        }

        validator = validators_map.get(field_name)

        if validator:
            return validator(value)
        else:
            logger.warning(f"⚠️ Unknown field name for validation: {field_name}")
            return ""