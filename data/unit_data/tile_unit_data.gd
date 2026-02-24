extends BaseData
class_name TileUnitData

export var player_network_id :int
export var player_id :String
export var unit_name :String
export var team :int
export var current_tile :Vector2
export var speed :float
export var position :Vector3
export var scene_index :int
export var color :Color

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	player_network_id = _data["a"]
	player_id = _data["b"]
	unit_name = _data["c"]
	team = _data["d"]
	current_tile = _data["e"]
	speed = _data["f"]
	position = _data["g"]
	scene_index = _data["h"]
	color = _data["i"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = player_network_id
	_data["b"] = player_id
	_data["c"] = unit_name
	_data["d"] = team
	_data["e"] = current_tile
	_data["f"] = speed
	_data["g"] = position
	_data["h"] = scene_index
	_data["i"] = color
	return _data
	
func spawn(player_data :PlayerData, parent_path:NodePath, overlay_ui_path:NodePath, cam_path:NodePath):
	return null
