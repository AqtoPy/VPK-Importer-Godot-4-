@tool
extends EditorPlugin

const VPKImporter = preload("vpk_importer.gd")

var importer: EditorImportPlugin

func _enter_tree():
    importer = VPKImporter.new()
    add_import_plugin(importer)
    print("VPK Importer plugin loaded")

func _exit_tree():
    if importer:
        remove_import_plugin(importer)
        importer = null
    print("VPK Importer plugin unloaded")
