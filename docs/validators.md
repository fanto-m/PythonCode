# Module: validators.py

> Path: `PythonCod-master/validators.py`

## ⚙️ Functions

### def validate_article(article)
Проверяет артикул на пустоту и уникальность (проверка уникальности должна выполняться в DatabaseManager).
Args:
    article (str): Артикул изделия.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_name(name)
Проверяет название на пустоту и длину.
Args:
    name (str): Название изделия.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_description(description)
Проверяет описание на длину.
Args:
    description (str): Описание изделия.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_image_path(image_path)
Проверяет путь к изображению на длину и допустимые форматы.
Args:
    image_path (str): Путь к изображению.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_category(category)
Проверяет категорию на валидность.
Args:
    category (int): ID категории изделия.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_price(price)
Проверяет цену на корректность (число, не отрицательное).
Args:
    price (float or str): Цена изделия.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_stock(stock)
Проверяет остаток на корректность (целое число, не отрицательное).
Args:
    stock (int or str): Остаток на складе.
Returns:
    tuple: (is_valid: bool, error_message: str)

### def validate_item(article, name, description, image_path, category, price, stock)
Проверяет все поля изделия.
Args:
    article, name, description, image_path, category, price, stock: Поля изделия.
Returns:
    tuple: (is_valid: bool, error_message: str)

## 📝 Notes
This module was auto-documented.
