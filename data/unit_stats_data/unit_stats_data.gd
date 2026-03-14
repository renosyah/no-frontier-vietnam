extends BaseData
class_name UnitStatsData

export var soldier_name :String
export var soldier_potrait_index :int

# value from 1 to 0
export var speed :int
export var endurance :int
export var accuracy :int
export var discipline :int

func randomize_stats(bonus :int = 0):
	speed = _add(int(rand_range(1, 10)), bonus)
	endurance = _add(int(rand_range(1, 10)), bonus)
	accuracy = _add(int(rand_range(1, 10)), bonus)
	discipline = _add(int(rand_range(1, 10)), bonus)
	
func _add(base :int, bonus :int) -> int:
	return int(clamp(base + bonus, 1, 10))
	
# stats modifier
func get_speed_multiplier() -> float:
	var s = clamp(speed, 1, 10)
	var t = float(s - 1) / 9.0
	return lerp(0.8, 1.2, t)
	
func get_max_hp(base_hp: float) -> float:
	var e = clamp(endurance, 1, 10)
	var multiplier = 1.0 + (e * 0.1)
	var _hp = base_hp * multiplier
	return _hp if _hp > 0 else 1
	
func from_dictionary(_data:Dictionary):
	.from_dictionary(_data)
	
	soldier_name = _data["a"]
	soldier_potrait_index = _data["b"]
	speed = _data["d"]
	endurance = _data["e"]
	accuracy = _data["f"]
	discipline = _data["g"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = soldier_name
	_data["b"] = soldier_potrait_index
	_data["d"] = speed
	_data["e"] = endurance
	_data["f"] = accuracy
	_data["g"] = discipline
	return _data
