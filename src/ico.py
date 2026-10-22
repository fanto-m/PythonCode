from PIL import Image


def make_ico(input_image_path: str, output_ico_path: str):
    # Открываем изображение и переводим в RGBA
    img = Image.open(input_image_path).convert("RGBA")

    # Делаем белый фон прозрачным
    datas = img.getdata()
    new_data = []
    for item in datas:
        # Если пиксель белый или почти белый (светлее порога 240)
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            new_data.append((255, 255, 255, 0))  # прозрачный
        else:
            new_data.append(item)
    img.putdata(new_data)

    # Обрезаем прозрачные края вокруг склада
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)

    # Делаем изображение квадратным для правильных пропорций иконки
    w, h = img.size
    max_dim = max(w, h)
    square_img = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
    offset = ((max_dim - w) // 2, (max_dim - h) // 2)
    square_img.paste(img, offset)

    # Стандартный набор слоев Windows
    icon_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]

    # Сохраняем в .ico
    square_img.save(
        output_ico_path,
        format='ICO',
        sizes=icon_sizes
    )
    print(f"Иконка успешно создана: {output_ico_path}")


if __name__ == "__main__":
    # Укажите путь к вашей картинке и куда сохранить иконку
    make_ico("warehouse_raw.png", "src/app_icon.ico")