@tool
extends EditorImportPlugin

const VPKReader = preload("csgo_vpk_reader.gd")

func _get_importer_name() -> String:
    return "csgo.vpk"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vpk"])

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
    return [{
        "name": "extract_resources",
        "default_value": true,
        "hint_string": "Automatically extract and convert game resources"
    }]

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var reader = VPKReader.new()
    var err = reader.load_vpk(source_file)
    if err != OK:
        return err
    
    # Сохранение ссылки на VPK для последующего использования
    var resource = Resource.new()
    resource.set_meta("vpk_data", reader)
    ResourceSaver.save(resource, "%s.vpk_res" % save_path)
    
    # Автоматическая обработка ресурсов
    if options.get("extract_resources", true):
        _process_vpk_contents(reader, save_path, gen_files)
    
    return OK

func _process_vpk_contents(reader: VPKReader, base_path: String, gen_files: Array):
    # Автоматический поиск и конвертация основных типов ресурсов
    var patterns = {
        "models": "*.vmdl_c",
        "materials": "*.vtex_c",
        "sounds": "*.vsnd_c",
        "maps": "*.vwrld_c"
    }
    
    for type in patterns:
        var files = reader.find_files(patterns[type])
        for file in files:
            var data = reader.get_file(file)
            var output_path = "%s/%s" % [base_path, file]
            _convert_resource(type, data, output_path, gen_files)

func _convert_resource(type: String, data: PackedByteArray, path: String, gen_files: Array):
    match type:
        "models":
            var converter = preload("converters/vmdl_converter.gd").new()
            var result = converter.convert(data)
            ResourceSaver.save(result, path.replace(".vmdl_c", ".mesh"))
        "materials":
            var converter = preload("converters/vtex_converter.gd").new()
            var image = converter.convert_to_image(data)
            image.save_png(path.replace(".vtex_c", ".png"))
        # Добавить обработчики для других типов
