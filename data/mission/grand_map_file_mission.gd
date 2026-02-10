extends BaseData
class_name GrandMapFileMission

var bases :Array # [ Vector2 ]
var points :Array # [ Vector2 ]

func from_dictionary(_data : Dictionary):
	bases = _data["bases"].duplicate()
	points = _data["points"].duplicate()

func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["bases"] = bases.duplicate()
	_data["points"] = points.duplicate()
	return _data
