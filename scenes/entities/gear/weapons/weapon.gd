extends Spatial
class_name Weapon

signal weapon_fired

export var ammo :int = 0
export var capacity :int = 0
export var reserve_ammo :int = 0
export var max_reserve_ammo :int = 0

export var is_master :bool

func reload():
	var ammo_needed = capacity - ammo
	var ammo_to_load = min(ammo_needed, reserve_ammo)
	
	ammo += ammo_to_load
	reserve_ammo -= ammo_to_load
	
func fire_weapon():
	if is_master:
		ammo = clamp(ammo - 1, 0, capacity)
	
func has_ammo():
	return ammo > 0
	
func stop_firing():
	pass
