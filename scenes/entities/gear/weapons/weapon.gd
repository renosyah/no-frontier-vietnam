extends Spatial
class_name Weapon

signal weapon_fired

export var ammo :int = 0
export var capacity :int = 0
export var reserve_ammo :int = 0
export var max_reserve_ammo :int = 0

export var is_master :bool


func fire_weapon():
	pass
	
func stop_firing():
	pass
