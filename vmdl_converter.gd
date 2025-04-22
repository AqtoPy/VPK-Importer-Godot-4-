@tool
class_name VMDLConverter
extends RefCounted

func convert_vmdl(data: PackedByteArray) -> Array:
    var mesh := ArrayMesh.new()
    var skeleton := Skeleton3D.new()
    
    # Парсинг бинарных данных VMDL (упрощенная версия)
    var header = data.slice(0, 64)
    var vertex_count = header.decode_u32(32)
    var index_count = header.decode_u32(36)
    
    # Извлечение вершин
    var vertices = []
    var vertex_offset = 128
    for i in vertex_count:
        var pos = Vector3(
            data.decode_float(vertex_offset),
            data.decode_float(vertex_offset + 4),
            data.decode_float(vertex_offset + 8)
        )
        vertices.append(pos)
        vertex_offset += 48
    
    # Извлечение индексов
    var indices = []
    for i in index_count:
        indices.append(data.decode_u16(vertex_offset))
        vertex_offset += 2
    
    # Создание поверхности меша
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices
    
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
      return [mesh, skeleton]
