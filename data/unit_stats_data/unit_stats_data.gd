extends BaseData
class_name UnitStatsData

export var unit_name :String
export var unit_potrait_index :int
export var unit_weapon_image_index :int

# value from 1 to 0
export var speed :int
export var endurance :int
export var accuration :int
export var dicipline :int

func randomize_stats():
	speed = int(rand_range(1, 10))
	endurance = int(rand_range(1, 10))
	accuration = int(rand_range(1, 10))
	dicipline = int(rand_range(1, 10))
	
func from_dictionary(_data:Dictionary):
	.from_dictionary(_data)
	
	unit_name = _data["a"]
	unit_potrait_index = _data["b"]
	unit_weapon_image_index = _data["c"]
	speed = _data["d"]
	endurance = _data["e"]
	accuration = _data["f"]
	dicipline = _data["g"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = unit_name
	_data["b"] = unit_potrait_index
	_data["c"] = unit_weapon_image_index
	_data["d"] = speed
	_data["e"] = endurance
	_data["f"] = accuration
	_data["g"] = dicipline
	return _data
