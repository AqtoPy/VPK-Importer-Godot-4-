@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vmdl"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vmdl_c"])

func _get_save_extension() -> String:
    return "mesh"

func _get_resource_type() -> String:
    return "ArrayMesh"

func _get_priority() -> float:
    return 1.0

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var file = FileAccess.open(source_file, FileAccess.READ)
    if file == null:
        return ERR_FILE_CANT_OPEN
        
    var data = file.get_buffer(file.get_length())
    var converter = preload("vmdl_converter.gd").new()
    var result = converter.convert_vmdl(data)
    
    if result.size() < 2:
        return ERR_PARSE_ERROR
    
    var mesh: ArrayMesh = result[0]
    var skeleton_data: Resource = result[1]  # Используем Resource вместо Skeleton3D
    
    # Сохранение меша
    var mesh_save_path = "%s.%s" % [save_path, _get_save_extension()]
    var err = ResourceSaver.save(mesh, mesh_save_path)
    if err != OK:
        return err
    
    # Сохранение данных скелета
    if skeleton_data:
        var skeleton_save_path = "%s_skeleton.tres" % save_path
        err = ResourceSaver.save(skeleton_data, skeleton_save_path)
        if err != OK:
            push_warning("Failed to save skeleton data: " + str(err))
    
    return OK
