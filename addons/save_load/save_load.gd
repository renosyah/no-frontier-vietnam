extends Node
class_name SaveLoad

const prefix = "user://"

static func save(_filename: String, _data, use_prefix = true):
	var file = File.new()
	var path = prefix + _filename if use_prefix else _filename
	if file.open(path, File.WRITE) != OK:
		print("Failed to open file for writing")
		return
		
	file.store_var(_data, true)
	file.flush()
	file.close()

static func load_save(_filename : String, use_prefix = true):
	var file = File.new()
	var path = prefix + _filename if use_prefix else _filename
	if file.file_exists(path):
		file.open(path, File.READ)
		var _data = file.get_var(true)
		file.close()
		return _data
	return null
	
static func ensure_dir(path: String) -> void:
	var dir = Directory.new()
	
	if not dir.dir_exists(path):
		var err = dir.make_dir_recursive(path)
		if err != OK:
			push_error("Failed to create directory: " + path)

static func delete_save(_filename : String, use_prefix = true):
	var dir = Directory.new()
	dir.remove(prefix + _filename if use_prefix else _filename)
