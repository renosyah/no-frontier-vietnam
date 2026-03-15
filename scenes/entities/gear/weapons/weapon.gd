extends Spatial
class_name Weapon

signal weapon_fired
signal weapon_update
signal weapon_finish_firing

export var damage :int = 1
export var ammo :int = 0
export var capacity :int = 0
export var reserve_ammo :int = 0
export var max_reserve_ammo :int = 0
export var dispersion :float = 0.3
export var durability_damage_chance: float = 0.2
export var durability_decrease_rate: float = 3.6
export var durability: float = 100.0
export var max_durability: float = 100.0
export var is_master :bool
export var icon :StreamTexture # just holder

onready var _rng :RandomNumberGenerator = RandomNumberGenerator.new()

var shot_from :Vector3
var shot_at :Vector3

func _ready():
	_rng.randomize()

func random_point_around(position: Vector3, radius: float) -> Vector3:
	var dir = Vector3(
		_rng.randf_range(-1.0, 1.0),
		_rng.randf_range(-1.0, 1.0),
		_rng.randf_range(-1.0, 1.0)
	).normalized()
	
	var distance = sqrt(_rng.randf()) * radius
	return position + dir * distance
	
func check_hit(accuracy:int) -> bool:
	var soldier_factor = clamp(accuracy / 10.0, 0.0, 1.0)
	var weapon_factor = clamp(1.0 - dispersion, 0.0, 1.0)
	var hit_chance = soldier_factor * weapon_factor
	hit_chance = min(hit_chance, 0.75)
	return _rng.randf() <= hit_chance
	
# optional
#func is_target(enemy) -> bool:
#	var result :Dictionary = get_world().direct_space_state.intersect_ray(
#		shot_from, shot_at, [unit_owner], 1, false, true
#	)
#	if result.empty():
#		return false
#
#	if result["collider"] is HitRegister:
#		var hr :HitRegister = result["collider"]
#		if hr.unit == enemy:
#			return true
#
#	return false

func is_weapon_jammed() -> bool:
	var jam_chance = (max_durability - durability) / max_durability
	jam_chance = clamp(jam_chance, 0.1, 0.4)
	return _rng.randf() < jam_chance
	
func repair_weapon():
	durability = int(clamp(durability + durability_decrease_rate, 0 ,max_durability))
	
func reload():
	var ammo_needed = capacity - ammo
	var ammo_to_load = min(ammo_needed, reserve_ammo)
	
	ammo += ammo_to_load
	reserve_ammo -= ammo_to_load
	
func fire_weapon(count :int):
	if is_master:
		ammo = int(clamp(ammo - count, 0, capacity))
	
func firing() -> bool:
	return false
	
func has_ammo():
	return ammo > 0
	
func weapon_update():
	emit_signal("weapon_update")
	
func stop_firing():
	pass
	
func get_shot_sound() -> AudioStream:
	return null
