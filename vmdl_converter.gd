@tool
class_name VMDLConverter
extends RefCounted

func convert_vmdl(data: PackedByteArray) -> Array:
    var mesh := ArrayMesh.new()
    var skeleton := Skeleton3D.new()
    
    # Пример: Создание тестового меша
    var vertices = PackedVector3Array([
        Vector3(0, 0, 0),
        Vector3(1, 0, 0),
        Vector3(0, 1, 0)
    ])
    
    var indices = PackedInt32Array([0, 1, 2])
    
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices
    
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    # Пример: Добавление тестовой кости
    skeleton.add_bone("root")
    skeleton.set_bone_rest(0, Transform3D.IDENTITY)
    
    return [mesh, skeleton]
