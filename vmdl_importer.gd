@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vmdl"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vmdl_c"])

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var file = FileAccess.open(source_file, FileAccess.READ)
    var data = file.get_buffer(file.get_length())
    
    var converter = preload("vmdl_converter.gd").new()
    var result = converter.convert_vmdl(data)
    
    var mesh: ArrayMesh = result[0]
    var skeleton: Skeleton3D = result[1]
    
    # Сохранение ресурсов
    ResourceSaver.save(mesh, "%s.mesh" % save_path)
    ResourceSaver.save(skeleton, "%s_skeleton.res" % save_path)
    
    return OK
