@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vpk"

func _get_visible_name() -> String:
    return "VPK Archive"

func _get_recognized_extensions() -> PackedStringArray:
    return ["vpk"]

func _get_save_extension() -> String:
    return "vpkres"

func _get_resource_type() -> String:
    return "Resource"

func _get_priority() -> float:
    return 1.0

func _get_import_order() -> int:
    return 0

func _get_preset_count() -> int:
    return 1

func _get_preset_name(preset_index: int) -> String:
    return "Default"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
    return []

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var resource = Resource.new()
    resource.resource_name = source_file.get_file()
    return ResourceSaver.save(resource, "%s.%s" % [save_path, _get_save_extension())
