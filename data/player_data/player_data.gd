extends BaseData
class_name PlayerData

var player_network_id :int
var player_id :String
var player_name :String
var player_rank :int # 0: 2nd LT, 1: 1st LT, 2: Captain
var player_team :int # 1 or 2


func from_dictionary(_data : Dictionary):
	player_network_id = _data["player_network_id"]
	player_id = _data["player_id"]
	player_name = _data["player_name"]
	player_rank = _data["player_rank"]
	player_team = _data["player_team"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["player_network_id"] = player_network_id
	_data["player_id"] = player_id
	_data["player_name"] = player_name
	_data["player_rank"] = player_rank
	_data["player_team"] = player_team
	return _data
