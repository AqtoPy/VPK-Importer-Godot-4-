@tool
class_name VTEXConverter extends RefCounted

# Базовый конвертер VTEX_C в PNG
func convert_to_image(vtex_data: PackedByteArray) -> Image:
    var image = Image.new()
    
    # Парсинг заголовка VTEX
    var header = vtex_data.slice(0, 32)
    var format = header.decode_u32(16)
    var width = header.decode_u32(20)
    var height = header.decode_u32(24)
    
    # Извлечение данных изображения
    var img_data = vtex_data.slice(32)
    
    # Конвертация формата (упрощенная версия)
    match format:
        0x1A:  # DXT1
            image.set_data(width, height, false, Image.FORMAT_DXT1, img_data)
        0x1B:  # DXT5
            image.set_data(width, height, false, Image.FORMAT_DXT5, img_data)
        _:
            push_error("Unsupported texture format: 0x%X" % format)
    
    return image
