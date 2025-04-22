@tool
extends EditorPlugin

const VPKImporter = preload("vpk_importer.gd")
const VMDLImporter = preload("vmdl_importer.gd")
const VTEXImporter = preload("vtex_importer.gd")

var importers = []

func _enter_tree():
    # Регистрация всех импортеров
    importers.append(VPKImporter.new())
    importers.append(VMDLImporter.new())
    importers.append(VTEXImporter.new())
    
    for importer in importers:
        add_import_plugin(importer)
    
    print("CS:GO Importer успешно активирован")

func _exit_tree():
    for importer in importers:
        remove_import_plugin(importer)
    importers.clear()
    print("CS:GO Importer выгружен")
