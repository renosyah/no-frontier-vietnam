extends Node
class_name SaveLoadImproved

signal save_done(success)
signal load_done(success, data)

const PREFIX = "user://"

var _thread : Thread = null

func file_exists(path :String, use_prefix = true):
	var p = "%s%s" % [PREFIX, path] if use_prefix else path
	var file = File.new()
	return file.file_exists(p)
	
# ---- ASYNC SAVE ----
func save_data_async(path: String, data, use_prefix = true):
	if OS.has_feature("HTML5"):
		SaveLoad.save(path, data, use_prefix)
		yield(get_tree(),"idle_frame")
		emit_signal("save_done", true)
		return
		
	if _thread != null:
		print("Save already in progress")
		return
		
	var p = "%s%s" % [PREFIX, path] if use_prefix else path
	_thread = Thread.new()
	_thread.start(self, "_thread_save", [p, data])

func _thread_save(args):
	var path = args[0]
	var data = args[1]
	var file = File.new()
	var b64 = Marshalls.variant_to_base64(data)
	var bytes = Marshalls.base64_to_raw(b64)
	bytes = bytes.compress(File.COMPRESSION_DEFLATE)
	var success = file.open(path, File.WRITE) == OK
	if success:
		file.store_buffer(bytes)
		file.flush()
		file.close()
	call_deferred("_thread_finished", "save_done", success)

# ---- ASYNC LOAD ----
func load_data_async(path: String, use_prefix = true):
	if OS.has_feature("HTML5"):
		var data = SaveLoad.load_save(path, use_prefix)
		yield(get_tree(),"idle_frame")
		emit_signal("load_done", data != null, data)
		return
		
	if _thread != null:
		print("Load already in progress")
		return
		
	var p = "%s%s" % [PREFIX, path] if use_prefix else path
	_thread = Thread.new()
	_thread.start(self, "_thread_load", [p])

func _thread_load(args):
	var path = args[0]
	var file = File.new()
	if not file.file_exists(path):
		call_deferred("_thread_finished", "load_done", false, null)
		return
	var success = file.open(path, File.READ) == OK
	var data = null
	if success:
		var bytes = file.get_buffer(file.get_len())
		bytes = bytes.decompress(1048576, File.COMPRESSION_DEFLATE)
		var b64 = Marshalls.raw_to_base64(bytes)
		data = Marshalls.base64_to_variant(b64)
		file.close()
		
	call_deferred("_thread_finished", "load_done", success, data)

# ---- THREAD CLEANUP ----
func _thread_finished(signal_name: String, arg1, arg2 = null):
	if _thread != null:
		_thread.wait_to_finish()
		_thread = null
	if arg2 == null:
		emit_signal(signal_name, arg1)
	else:
		emit_signal(signal_name, arg1, arg2)
