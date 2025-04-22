@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "csgo.vsnd"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["vsnd_c"])

func _import(source_file: String, save_path: String, options: Dictionary, 
           platform_variants: Array[String], gen_files: Array[String]) -> Error:
    var file = FileAccess.open(source_file, FileAccess.READ)
    var data = file.get_buffer(file.get_length())
    
    # Декодирование аудио (пример для PCM)
    var audio_stream = AudioStreamWAV.new()
    audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
    audio_stream.mix_rate = 44100
    audio_stream.stereo = true
    audio_stream.data = data.slice(32) # Пропуск заголовка
    
return ResourceSaver.save(audio_stream, "%s.wav" % save_path)
