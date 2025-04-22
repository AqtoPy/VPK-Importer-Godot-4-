@tool
class_name VPKReader
extends RefCounted

const VPK_SIGNATURE := 0x55aa1234

var files: Dictionary = {}

func load(path: String) -> Error:
    files.clear()
    
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return ERR_FILE_CANT_OPEN
    
    # Read header
    var signature: int = file.get_32()
    if signature != VPK_SIGNATURE:
        return ERR_FILE_UNRECOGNIZED
    
    var version: int = file.get_32()
    var tree_size: int = file.get_32()
    
    # Skip header fields based on version
    if version == 1:
        var _embedded_data_length: int = file.get_32() # Skip embedded data length
    elif version == 2:
        var _embedded_data_length: int = file.get_32() # Skip embedded data length
        var _archive_md5_length: int = file.get_32() # Skip archive MD5 length
    
    # Read file tree
    while file.get_position() < tree_size:
        var extension: String = file.get_string()
        var path_str: String = file.get_string()
        var filename: String = file.get_string()
        
        var crc: int = file.get_32()
        var preload_bytes: int = file.get_16()
        var archive_index: int = file.get_16()
        var entry_offset: int = file.get_32()
        var entry_length: int = file.get_32()
        var terminator: int = file.get_16()
        
        if terminator != 0xffff:
            break
        
        var full_path: String = path_str.path_join(filename + "." + extension)
        files[full_path] = {
            "archive_index": archive_index,
            "offset": entry_offset,
            "length": entry_length,
            "preload_data": file.get_buffer(preload_bytes) if preload_bytes > 0 else PackedByteArray()
        }
    
    return OK

func get_files() -> PackedStringArray:
    return PackedStringArray(files.keys())

func read_file(path: String) -> PackedByteArray:
    if not files.has(path):
        return PackedByteArray()
    
    var entry: Dictionary = files[path]
    var data: PackedByteArray = entry.get("preload_data", PackedByteArray())
    
    # TODO: Add support for reading from archive chunks
    # This would require handling the multi-part VPK files
    
    return data
