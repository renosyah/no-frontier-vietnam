extends BaseData
class_name TileMapFileData

var tile_ids :Dictionary # { Vector2: int }
var tiles : Array # [ TileMapData ]

var objects : Array # [ MapObjectData ]
var navigations : Array # [ NavigationData ]

func from_dictionary(_data : Dictionary):
	tile_ids = _data["tile_ids"].duplicate() # { Vector2: int }
	
	tiles = [] # [ TileMapData ]
	for i in _data["tiles"]:
		var x :TileMapData = TileMapData.new()
		x.from_dictionary(i)
		tiles.append(x)
		
	objects = [] # [ MapObjectData ]
	for i in _data["objects"]:
		var x :MapObjectData = MapObjectData.new()
		x.from_dictionary(i)
		objects.append(x)
		
	navigations = [] # [ NavigationData ]
	for i in _data["navigations"]:
		var x :NavigationData = NavigationData.new()
		x.from_dictionary(i)
		navigations.append(x)
		
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["tile_ids"] = tile_ids.duplicate() # { Vector2: int }
	
	_data["tiles"] = [] # [ TileMapData ]
	for i in tiles:
		var x :TileMapData = i
		_data["tiles"].append(x.to_dictionary())
		
	_data["objects"] = [] # [ MapObjectData ]
	for i in objects:
		var x :MapObjectData = i
		_data["objects"].append(x.to_dictionary())
		
	_data["navigations"] = [] # [ NavigationData ]
	for i in navigations:
		var x :NavigationData = i
		_data["navigations"].append(x.to_dictionary())
		
	return _data
