@tool
extends EditorImportPlugin

class VMDLParser:
    static func parse(data: PackedByteArray) -> ArrayMesh:
        var mesh = ArrayMesh.new()
        
        # Анализ заголовка VMDL (упрощенная версия)
        var magic = data.slice(0, 4).get_string_from_ascii()
        if magic != "VMDL":
            push_error("Invalid VMDL format")
            return mesh
        
        # Чтение версии формата
        var version = data.decode_u32(4)
        
        # Чтение информации о меше (примерные значения)
        var vertex_count = data.decode_u32(16)
        var index_count = data.decode_u32(20)
        
        # Создание тестового меша если данные не найдены
        if vertex_count == 0 or index_count == 0:
            return _create_fallback_mesh()
        
        # Чтение вершин (упрощенная реализация)
        var vertices = PackedVector3Array()
        var normals = PackedVector3Array()
        var uvs = PackedVector2Array()
        var vertex_offset = 128  # Смещение к данным вершин
        
        for i in vertex_count:
            var x = data.decode_float(vertex_offset)
            var y = data.decode_float(vertex_offset + 4)
            var z = data.decode_float(vertex_offset + 8)
            vertices.append(Vector3(x, y, z))
            
            # Нормали (если есть)
            if data.size() > vertex_offset + 32:
                var nx = data.decode_float(vertex_offset + 12)
                var ny = data.decode_float(vertex_offset + 16)
                var nz = data.decode_float(vertex_offset + 20)
                normals.append(Vector3(nx, ny, nz))
            
            # UV координаты (если есть)
            if data.size() > vertex_offset + 40:
                var u = data.decode_float(vertex_offset + 24)
                var v = data.decode_float(vertex_offset + 28)
                uvs.append(Vector2(u, v))
            
            vertex_offset += 48  # Размер одной вершины в байтах
        
        # Чтение индексов
        var indices = PackedInt32Array()
        for i in index_count:
            indices.append(data.decode_u16(vertex_offset))
            vertex_offset += 2
        
        # Создание массива поверхностей
        var arrays = []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = vertices
        arrays[Mesh.ARRAY_INDEX] = indices
        
        if normals.size() == vertices.size():
            arrays[Mesh.ARRAY_NORMAL] = normals
        if uvs.size() == vertices.size():
            arrays[Mesh.ARRAY_TEX_UV] = uvs
        
        mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        
        # Создание простого материала
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.8, 0.8, 0.8)
        mesh.surface_set_material(0, material)
        
        return mesh
    
    static func _create_fallback_mesh() -> ArrayMesh:
        var mesh = ArrayMesh.new()
        var vertices = PackedVector3Array([
            Vector3(-1, -1, 0),
            Vector3(1, -1, 0),
            Vector3(0, 1, 0)
        ])
        
        var arrays = []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = vertices
        arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2])
        
        mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        return mesh

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

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    # Чтение файла
    var file = FileAccess.open(source_file, FileAccess.READ)
    if file == null:
        return ERR_FILE_CANT_OPEN
    
    var data = file.get_buffer(file.get_length())
    
    # Парсинг VMDL
    var mesh = VMDLParser.parse(data)
    
    # Создание сцены
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.name = source_file.get_file().get_basename()
    mesh_instance.mesh = mesh
    
    # Создание коллизии
    if options.get("create_collision", true):
        mesh_instance.create_trimesh_collision()
    
    # Сохранение сцены
    var scene = PackedScene.new()
    if scene.pack(mesh_instance) != OK:
        return ERR_CANT_CREATE
    
    return ResourceSaver.save(scene, "%s.%s" % [save_path, _get_save_extension()])
