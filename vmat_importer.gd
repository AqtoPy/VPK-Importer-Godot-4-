@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vmat"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vmat_c"])

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var file = FileAccess.open(source_file, FileAccess.READ)
    var shader_code = file.get_as_text()
    
    # Конвертация шейдера Source 2 в Godot
    var godot_shader = _convert_shader(shader_code)
    
    var material = ShaderMaterial.new()
    material.shader = Shader.new()
    material.shader.set_code(godot_shader)
    
    return ResourceSaver.save(material, "%s.tres" % save_path)

func _convert_shader(source_code: String) -> String:
    # Базовая конвертация параметров
    var converted = source_code.replace("Texture2D", "uniform sampler2D")
    converted = converted.replace("float4", "vec4")
    converted = converted.replace("float3", "vec3")
    converted = converted.replace("float2", "vec2")
    return converted
