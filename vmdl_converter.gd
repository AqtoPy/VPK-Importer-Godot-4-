@tool
class_name VMDLConverter
extends RefCounted

# Пользовательский ресурс для хранения данных скелета
class SkeletonData extends Resource:
    var bone_names: PackedStringArray
    var bone_rests: Array[Transform3D]
    var bone_parents: PackedInt32Array

func convert_vmdl(data: PackedByteArray) -> Array:
    var mesh := ArrayMesh.new()
    var skeleton_data = SkeletonData.new()
    
    # Пример данных (замените реальным парсингом VMDL)
    var vertices = PackedVector3Array([
        Vector3(0, 0, 0),
        Vector3(1, 0, 0),
        Vector3(0, 1, 0)
    ])
    
    var indices = PackedInt32Array([0, 1, 2])
    
    # Заполнение данных меша
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    # Заполнение данных скелета (пример)
    skeleton_data.bone_names = PackedStringArray(["root", "bone1"])
    skeleton_data.bone_rests = [
        Transform3D.IDENTITY,
        Transform3D(Basis(), Vector3(1, 0, 0))
    ]
    skeleton_data.bone_parents = PackedInt32Array([-1, 0])
    
    return [mesh, skeleton_data]
