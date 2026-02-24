extends BaseData
class_name NavigationData

var id :Vector2
var navigation_id :int
var enable: bool
var neighbors: Array #  [ int ]

func from_dictionary(_data : Dictionary):
	navigation_id = _data["navigation_id"]
	id = _data["id"]
	enable = _data["enable"]
	neighbors = _data["neighbors"]
	
func to_dictionary() -> Dictionary :
	var data :Dictionary = {}
	data["navigation_id"] = navigation_id
	data["id"] = id
	data["enable"] = enable
	data["neighbors"] = neighbors
	return data
