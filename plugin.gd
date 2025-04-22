@tool
extends EditorPlugin

const Importers = [
    preload("vpk_importer/vpk_importer.gd"),
    preload("importers/vmdl_importer.gd"),
    preload("importers/vtex_importer.gd"),
    preload("importers/vsnd_importer.gd"),
    preload("importers/vmat_importer.gd")
]

var importers = []

func _enter_tree():
    for importer_class in Importers:
        var importer = importer_class.new()
        add_import_plugin(importer)
        importers.append(importer)
    print("CS:GO Importer loaded")

func _exit_tree():
    for importer in importers:
        remove_import_plugin(importer)
    importers.clear()
    print("CS:GO Importer unloaded")
