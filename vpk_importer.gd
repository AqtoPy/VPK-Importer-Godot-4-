@tool
extends EditorImportPlugin

const VPKReader = preload("vpk_reader.gd")

func _get_importer_name() -> String:
    return "godot.vpk_importer"

func _get_visible_name() -> String:
    return "VPK Archive Importer"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vpk"])

func _get_save_extension() -> String:
    return "vpk_resource"

func _get_resource_type() -> String:
    return "Resource"

func _get_priority() -> float:
    return 1.0

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
    return [
        {
            "name": "extract_files",
            "default_value": false,
            "property_hint": PROPERTY_HINT_NONE,
            "hint_string": "If enabled, extracts files from VPK"
        },
        {
            "name": "file_patterns",
            "default_value": "*.txt,*.cfg,*.json,*.png,*.jpg,*.tres,*.res",
            "property_hint": PROPERTY_HINT_NONE,
            "hint_string": "Comma-separated file patterns to extract"
        }
    ]

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var vpk := VPKReader.new()
    var err := vpk.load(source_file)
    if err != OK:
        push_error("Failed to load VPK file: " + source_file)
        return err
    
    var result := Resource.new()
    result.set_meta("vpk_source", source_file)
    
    if options.get("extract_files", false):
        var patterns: PackedStringArray = PackedStringArray(options.get("file_patterns", "").split(","))
        var extracted_files := _extract_files_from_vpk(vpk, patterns, save_path, gen_files)
        result.set_meta("extracted_files", extracted_files)
    
    return ResourceSaver.save(result, "%s.%s" % [save_path, _get_save_extension()])

func _extract_files_from_vpk(vpk: VPKReader, patterns: PackedStringArray, base_path: String, gen_files: Array) -> Dictionary:
    var extracted := {}
    var files := vpk.get_files()
    
    for file in files:
        for pattern in patterns:
            if file.matchn(pattern.strip_edges()):
                var data := vpk.read_file(file)
                if data.size() > 0:
                    var output_path := base_path.get_base_dir().path_join(file)
                    DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
                    
                    var f := FileAccess.open(output_path, FileAccess.WRITE)
                    if f:
                        f.store_buffer(data)
                        f.close()
                        gen_files.append(output_path)
                        extracted[file] = output_path
    return extracted
