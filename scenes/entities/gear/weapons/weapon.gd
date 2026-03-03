extends Spatial
class_name Weapon

signal weapon_fired
signal weapon_update

export var damage :int = 1
export var ammo :int = 0
export var capacity :int = 0
export var reserve_ammo :int = 0
export var max_reserve_ammo :int = 0
export var dispersion :float = 0.3
export var is_master :bool
export var team :int

var unit_owner
var shot_from :Vector3
var shot_at :Vector3

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
