extends BaseData
class_name MapObjectData

const scenes = [
	preload("res://scenes/tile_objects/grand/faction_base.tscn"),
	preload("res://scenes/tile_objects/grand/flag_pole.tscn"),
	preload("res://scenes/tile_objects/grand/forest_1.tscn"),
	preload("res://scenes/tile_objects/grand/forest_2.tscn")
]

var id :Vector2
var pos :Vector3

# store only index not scene path
# get index from const scenes
var scene_idx :int

# categorize if this object block tile navigation
# or not, for example : grass & tree
var is_blocking :bool

func from_dictionary(_data : Dictionary):
	id = _data["id"]
	pos = _data["pos"]
	scene_idx = _data["scene_idx"]
	is_blocking = _data["is_blocking"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["id"] = id
	_data["pos"] = pos
	_data["scene_idx"] = scene_idx
	_data["is_blocking"] = is_blocking
	return _data
