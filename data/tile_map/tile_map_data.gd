extends BaseData
class_name TileMapData

var id :Vector2
var pos :Vector3

# tile_type for grand map = 1:ground, 2:water
# tile_type for battle map = 1:grass, 2:mud, 3:sand, 4:water
var tile_type :int


func from_dictionary(_data : Dictionary):
	id = _data["id"]
	pos = _data["pos"]
	tile_type = _data["tile_type"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["id"] = id
	_data["pos"] = pos
	_data["tile_type"] = tile_type
	return _data
