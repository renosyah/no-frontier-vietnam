extends Spatial
class_name Weapon

signal weapon_fired

export var damage :int = 1
export var ammo :int = 0
export var capacity :int = 0
export var reserve_ammo :int = 0
export var max_reserve_ammo :int = 0
export var dispersion :float = 0.3
export var is_master :bool

var unit_owner
var shot_at :Vector3

func _ready():
	connect("weapon_fired", self, "_on_weapon_fired")

func _on_weapon_fired():
	var to = random_point_around(shot_at, dispersion)
	
	if is_master:
		var pos = global_position
		var result :Dictionary = get_world().direct_space_state.intersect_ray(pos, to, [unit_owner], 1, false, true)
		if result.empty():
			return
			
		if result["collider"] is HitRegister:
			var hr :HitRegister = result["collider"]
			hr.unit.take_damage(damage)
			
	_on_fire_at(to)
	
func _on_fire_at(pos :Vector3):
	pass
	
func random_point_around(position: Vector3, radius: float) -> Vector3:
	var dir = Vector3(
		rand_range(-1.0, 1.0),
		rand_range(-1.0, 1.0),
		rand_range(-1.0, 1.0)
	).normalized()
	
	var distance = sqrt(randf()) * radius
	return position + dir * distance
	
func reload():
	var ammo_needed = capacity - ammo
	var ammo_to_load = min(ammo_needed, reserve_ammo)
	
	ammo += ammo_to_load
	reserve_ammo -= ammo_to_load
	
func fire_weapon():
	if is_master:
		ammo = clamp(ammo - 1, 0, capacity)
	
func firing() -> bool:
	return false
	
func has_ammo():
	return ammo > 0
	
func stop_firing():
	pass
