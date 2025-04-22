@tool
class_name CSGOVPKReader
extends RefCounted

# Реализация чтения многотомных VPK архивов CS:GO
var chunk_files = {}
var file_index = {}

func load_vpk(vpk_path: String) -> Error:
    var dir_file = FileAccess.open(vpk_path, FileAccess.READ)
    if not dir_file:
        return ERR_FILE_CANT_OPEN
    
    # Чтение заголовка
    dir_file.seek(12)  # Пропуск CS:GO специфичного заголовка
    var tree_size = dir_file.get_32()
    
    # Построение индекса файлов
    while dir_file.get_position() < tree_size + 12:
        var ext = dir_file.get_string()
        var path = dir_file.get_string()
        var filename = dir_file.get_string()
        
        # Чтение метаданных файла
        dir_file.get_32()  # CRC32
        var preload_size = dir_file.get_16()
        var archive_index = dir_file.get_16()
        var offset = dir_file.get_32()
        var length = dir_file.get_32()
        
        var full_path = "%s/%s.%s" % [path, filename, ext]
        file_index[full_path.to_lower()] = {
            "archive": archive_index,
            "offset": offset,
            "length": length,
            "preload": dir_file.get_buffer(preload_size)
        }
        dir_file.get_16()  # Terminator
        
    # Загрузка chunk-файлов
    var base_path = vpk_path.get_basename().replace("_dir", "")
    for i in 1000:
        var chunk_path = "%s_%03d.vpk" % [base_path, i]
        if FileAccess.file_exists(chunk_path):
            chunk_files[i] = FileAccess.open(chunk_path, FileAccess.READ)
    
    return OK

func get_file(path: String) -> PackedByteArray:
    path = path.to_lower()
    if not file_index.has(path):
        return PackedByteArray()
    
    var entry = file_index[path]
    var data = entry["preload"]
    
    if entry["archive"] != 0x7FFF:
        var chunk = chunk_files.get(entry["archive"])
        if chunk:
            chunk.seek(entry["offset"])
            data += chunk.get_buffer(entry["length"])
    
    return data
