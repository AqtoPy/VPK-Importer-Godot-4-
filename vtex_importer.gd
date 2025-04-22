@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vtex"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vtex_c"])

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var file = FileAccess.open(source_file, FileAccess.READ)
    var data = file.get_buffer(file.get_length())
    
    var converter = preload("vtex_converter.gd").new()
    var image = converter.convert_to_image(data)
    
    var texture = ImageTexture.create_from_image(image)
return ResourceSaver.save(texture, "%s.png" % save_path)
