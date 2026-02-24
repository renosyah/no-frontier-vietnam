extends BaseData
class_name GrandMapFileMission

var bases :Array # [ Vector2 ]
var points :Array # [ Vector2 ]
var edited_battle_maps :Dictionary # { Vector2 : String }

func from_dictionary(_data : Dictionary):
	bases = _data["bases"].duplicate()
	points = _data["points"].duplicate()
	edited_battle_maps = _data["edited_battle_maps"].duplicate()
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["bases"] = bases.duplicate()
	_data["points"] = points.duplicate()
	_data["edited_battle_maps"] = edited_battle_maps.duplicate()
	return _data
