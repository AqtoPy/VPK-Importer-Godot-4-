@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vmdl"

func _get_visible_name() -> String:
    return "CS:GO Model"

func _get_recognized_extensions() -> PackedStringArray:
    return ["vmdl_c"]

func _get_save_extension() -> String:
    return "scn"

func _get_resource_type() -> String:
    return "PackedScene"

func _get_priority() -> float:
    return 1.0

func _get_import_order() -> int:
    return 100

func _get_preset_count() -> int:
    return 1

func _get_preset_name(preset_index: int) -> String:
    return "Default"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
    return []

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var scene = PackedScene.new()
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = "CSGO_Model"
    scene.pack(mesh_instance)
    return ResourceSaver.save(scene, "%s.%s" % [save_path, _get_save_extension()))
