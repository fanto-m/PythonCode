def validate_article(article):
    """Проверяет артикул на пустоту и уникальность (проверка уникальности должна выполняться в DatabaseManager).
    Args:
        article (str): Артикул изделия.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    if not article or not article.strip():
        return False, "Артикул не может быть пустым"
    if len(article) > 50:
        return False, "Артикул не может быть длиннее 50 символов"
    return True, ""

def validate_name(name):
    """Проверяет название на пустоту и длину.
    Args:
        name (str): Название изделия.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    if not name or not name.strip():
        return False, "Название не может быть пустым"
    if len(name) > 100:
        return False, "Название не может быть длиннее 100 символов"
    return True, ""

def validate_description(description):
    """Проверяет описание на длину.
    Args:
        description (str): Описание изделия.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    if description and len(description) > 500:
        return False, "Описание не может быть длиннее 500 символов"
    return True, ""

def validate_image_path(image_path):
    """Проверяет путь к изображению на длину и допустимые форматы.
    Args:
        image_path (str): Путь к изображению.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    if image_path and len(image_path) > 255:
        return False, "Путь к изображению не может быть длиннее 255 символов"
    if image_path:
        valid_extensions = (".jpg", ".jpeg", ".png", ".bmp")
        if not any(image_path.lower().endswith(ext) for ext in valid_extensions):
            return False, "Недопустимый формат изображения. Допустимые форматы: .jpg, .jpeg, .png, .bmp"
    return True, ""

def validate_category(category):
    """Проверяет категорию на валидность.
    Args:
        category (int): ID категории изделия.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    if not isinstance(category, int) or category <= 0:
        return False, "Категория должна быть положительным числом"
    return True, ""

def validate_price(price):
    """Проверяет цену на корректность (число, не отрицательное).
    Args:
        price (float or str): Цена изделия.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    try:
        price = float(price) if price is not None and str(price).strip() else 0.0
        if price < 0:
            return False, "Цена не может быть отрицательной"
        return True, ""
    except (ValueError, TypeError):
        return False, "Цена должна быть числом"

def validate_stock(stock):
    """Проверяет остаток на корректность (целое число, не отрицательное).
    Args:
        stock (int or str): Остаток на складе.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    try:
        stock = int(stock) if stock is not None and str(stock).strip() else 0
        if stock < 0:
            return False, "Остаток не может быть отрицательным"
        return True, ""
    except (ValueError, TypeError):
        return False, "Остаток должен быть целым числом"

def validate_item(article, name, description, image_path, category, price, stock):
    """Проверяет все поля изделия.
    Args:
        article, name, description, image_path, category, price, stock: Поля изделия.
    Returns:
        tuple: (is_valid: bool, error_message: str)
    """
    validators = [
        validate_article(article),
        validate_name(name),
        validate_description(description),
        validate_image_path(image_path),
        validate_category(category),
        validate_price(price),
        validate_stock(stock)
    ]
    for is_valid, error_message in validators:
        if not is_valid:
            return False, error_message
    return True, ""