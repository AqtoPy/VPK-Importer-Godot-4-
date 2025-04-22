@tool
extends EditorImportPlugin

class VTEXConverter:
    static func convert(data: PackedByteArray) -> Image:
        var image = Image.new()
        
        # Проверка сигнатуры VTEX
        if data.size() < 16 or data.slice(0, 4).get_string_from_ascii() != "VTEX":
            push_error("Invalid VTEX format")
            return _create_fallback_image()
        
        # Чтение параметров изображения
        var width = data.decode_u32(8)
        var height = data.decode_u32(12)
        var format = data.decode_u32(16)
        
        # Простая реализация для DXT1/DXT5
        if format == 0x1A:  # DXT1
            image.set_data(width, height, false, Image.FORMAT_DXT1, data.slice(32))
        elif format == 0x1B:  # DXT5
            image.set_data(width, height, false, Image.FORMAT_DXT5, data.slice(32))
        else:
            push_error("Unsupported texture format: 0x%X" % format)
            return _create_fallback_image()
        
        return image
    
    static func _create_fallback_image() -> Image:
        var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
        image.fill(Color(1, 0, 1)) # Розовый цвет
        return image

func _get_importer_name() -> String:
    return "csgo.vtex"

func _get_visible_name() -> String:
    return "CS:GO Texture"

func _get_recognized_extensions() -> PackedStringArray:
    return ["vtex_c"]

func _get_save_extension() -> String:
    return "png"

func _get_resource_type() -> String:
    return "Texture2D"

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    # Чтение файла
    var file = FileAccess.open(source_file, FileAccess.READ)
    if file == null:
        return ERR_FILE_CANT_OPEN
    
    var data = file.get_buffer(file.get_length())
    
    # Конвертация в изображение
    var image = VTEXConverter.convert(data)
    if image == null:
        return ERR_PARSE_ERROR
    
    # Сохранение PNG
    return image.save_png("%s.%s" % [save_path, _get_save_extension()])
