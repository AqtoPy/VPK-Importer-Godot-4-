@tool
extends EditorImportPlugin

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

func _get_priority() -> float:
    return 1.0

func _get_import_order() -> int:
    return 200

func _get_preset_count() -> int:
    return 1

func _get_preset_name(preset_index: int) -> String:
    return "Default"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
    return [{
        "name": "generate_mipmaps",
        "default_value": true
    }]

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
    image.fill(Color(1, 0, 1)) # Тестовая текстура
    return image.save_png("%s.%s" % [save_path, _get_save_extension()))
