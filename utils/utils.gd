extends Node
class_name Utils

static func military_alphabetic() -> Array:
	return [
		"Alpha",   # A
		"Bravo",   # B
		"Charlie", # C
		"Delta",   # D
		"Echo",    # E
		"Foxtrot", # F
		"Golf",    # G
		"Hotel",   # H
		"India",   # I
		"Juliett", # J (double 't' is correct)
		"Kilo",    # K
		"Lima",    # L
		"Mike",    # M
		"November",# N
		"Oscar",   # O
		"Papa",    # P
		"Quebec",  # Q
		"Romeo",   # R
		"Sierra",  # S
		"Tango",   # T
		"Uniform", # U
		"Victor",  # V
		"Whiskey", # W
		"X-ray",   # X
		"Yankee",  # Y
		"Zulu"    # Z
	]


static func get_all_resources(path: String, extensions := ["tres", "res", "tscn", "scn", "obj"]) -> PoolStringArray:
	var files := PoolStringArray()
	var dir := Directory.new()
	if dir.open(path) != OK:
		return files
	
	dir.list_dir_begin(true, true) # skip hidden, recursive
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path.plus_file(file_name)
		if not dir.current_is_dir():
			var ext = file_name.get_extension().to_lower()
			if ext in extensions:
				files.append(file_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return files
	
static func copy_file_to_user(source_path: String, target_path: String) -> Array:
	var logs :Array = []
	
	var source_file = File.new()
	if not source_file.file_exists(source_path):
		if logs != null:
			logs.append("Source file not found: %s" % source_path)
			return logs

	var err = source_file.open(source_path, File.READ)
	if err != OK:
		logs.append("Failed to open source file: %s" % source_path)
		return logs

	var data = source_file.get_buffer(source_file.get_len())
	source_file.close()

	var target_file = File.new()
	err = target_file.open(target_path, File.WRITE)
	if err != OK:
		logs.append("Failed to open target file: %s" % target_path)
		return logs

	target_file.store_buffer(data)
	target_file.close()

	return logs
	
static func screen_to_world(cam :Camera, screen_pos: Vector2, with_body :bool = true, collision_mask :int = 0b11) -> Vector3:
	var from = cam.project_ray_origin(screen_pos)
	var dir = cam.project_ray_normal(screen_pos)

	var result :Dictionary = cam.get_world().direct_space_state.intersect_ray(
		from, from + dir * 1000, [], collision_mask, with_body, not with_body
	)
	if not result.empty():
		return result["position"]
		
	return Vector3.ZERO
	

static func contains_substring(text: String, sub: String) -> bool:
	if sub.empty():
		return true
	return sub.to_lower() in text.to_lower()
	
	
static func generate_positions(count: int, spacing: float, z :float = 0) -> Array:
	var positions = []
	for i in range(count):
		if i == 0:
			positions.append(Vector3(0, 0, z))
			
		else:
			var step = int((i + 1.0) / 2.0)
			var direction = 1 if i % 2 == 1 else -1
			positions.append(Vector3(step * spacing * direction, 0, z))
	return positions

static func create_unique_id():
	var base = str(OS.get_ticks_usec())
	return base.sha256_text().substr(0, 8)

static func clone_spatial(original: Spatial) -> Spatial:
	var copy = original.duplicate()
	copy.global_transform = original.global_transform
	return copy
	
static func shuffle_array(rng :RandomNumberGenerator, array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		
		# swap array[i] and array[j]
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp
		
static func format_number(n :int):
	if n >= 1000000000:
		return str(round(n / 1000000000.0)) + "B"
	elif n >= 1000000:
		return str(round(n / 1000000.0)) + "M"
	elif n >= 1000:
		return str(round(n / 1000.0)) + "K"
	else:
		return str(n)
