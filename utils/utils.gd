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








