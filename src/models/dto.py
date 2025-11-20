#dto.py
"""Data Transfer Objects для типизации данных

Эти классы представляют структуру данных из базы данных
и используются для передачи данных между слоями приложения.
"""

from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class Category:
    """Модель категории товаров."""
    id: Optional[int]
    name: str
    sku_prefix: str = 'ITEM'
    sku_digits: int = 4


@dataclass
class Supplier:
    """Модель поставщика."""
    id: Optional[int]
    name: str
    company: str
    email: Optional[str] = None
    phone: Optional[str] = None
    website: Optional[str] = None


@dataclass
class Item:
    """Модель товара."""
    article: str
    name: str
    description: str
    image_path: str
    category_id: Optional[int]
    price: float = 0.0
    stock: int = 0
    status: str = 'в наличии'
    unit: str = 'шт.'
    manufacturer: Optional[str] = None
    document: Optional[str] = None
    created_date: Optional[str] = None


@dataclass
class Specification:
    """Модель спецификации."""
    id: Optional[int]
    name: str
    description: str
    status: str = 'черновик'
    labor_cost: float = 0.0
    overhead_percentage: float = 0.0
    final_price: float = 0.0
    created_date: Optional[str] = None
    modified_date: Optional[str] = None


@dataclass
class SpecificationItem:
    """Модель позиции спецификации."""
    id: Optional[int]
    specification_id: int
    article: str
    quantity: int
    notes: Optional[str] = None


@dataclass
class Document:
    """Модель документа товара."""
    id: Optional[int]
    item_article: str
    document_path: str
    document_name: Optional[str] = None
    added_date: Optional[str] = None