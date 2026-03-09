extends MeshInstance
class_name AmmoSpot

signal out_of_stock

export var player_id :String
export var usage_rate :int = 30
export var ammo_supply :int = 7500
export var max_ammo_supply :int = 7500

onready var collision_shape = $CollisionShape
onready var audio_stream_player_3d = $AudioStreamPlayer3D

var _out_of_stock :bool

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
	if _out_of_stock:
		return
		
	if ammo_supply <= 0:
		_out_of_stock = true
		Global.disconnect("on_global_tick", self, "_on_global_tick")
		emit_signal("out_of_stock")
		return
	
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(collision_shape.shape)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1
	query.transform = collision_shape.global_transform
	
	var results :Array = get_world().direct_space_state.intersect_shape(query, 1)
	if results.empty():
		return
		
	for result in results:
		if result["collider"] is HitRegister:
			var i :HitRegister = result["collider"]
			if i.unit is Infantry:
				if i.unit.player_id != player_id:
					return
					
				_resupply_squad(i.unit)
				audio_stream_player_3d.play()
				return
				
func _resupply_squad(unit :Infantry):
	var squad :InfantrySquad = unit.squad
	for i in squad.members:
		if ammo_supply <= 0:
			return
			
		if is_instance_valid(i):
			var infantry :Infantry = i
			var w :Weapon = infantry.get_weapon()
			if w.ammo < w.capacity:
				w.reload()
				
			if w.reserve_ammo >= w.max_reserve_ammo:
				continue
				
			w.reserve_ammo = int(clamp(w.reserve_ammo + usage_rate, 0, w.max_reserve_ammo))
			ammo_supply = int(clamp(ammo_supply - usage_rate, 0, max_ammo_supply))
			w.weapon_update()










