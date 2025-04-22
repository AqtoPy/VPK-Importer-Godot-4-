@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vmdl"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vmdl_c"])

# Добавляем метод указания расширения
func _get_save_extension() -> String:
    return "mesh"

# Добавляем тип ресурса
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
    var skeleton: Skeleton3D = result[1]
    
    # Сохранение меша
    var mesh_save_path = "%s.%s" % [save_path, _get_save_extension()]
    var err = ResourceSaver.save(mesh, mesh_save_path)
    if err != OK:
        return err
    
    # Сохранение скелета как отдельного ресурса
    if skeleton:
        var skeleton_save_path = "%s_skeleton.res" % save_path
        err = ResourceSaver.save(skeleton, skeleton_save_path)
        if err != OK:
            push_warning("Failed to save skeleton: " + str(err))
    
    return OK
