extends MeshInstance
class_name HealSpot

signal out_of_stock

export var player_id :String
export var usage_rate :int = 1
export var medical_supply :int = 400
export var max_medical_supply :int = 400

onready var collision_shape = $CollisionShape
onready var audio_stream_player_3d = $AudioStreamPlayer3D

var _out_of_stock :bool

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
	if _out_of_stock:
		return
		
	if medical_supply <= 0:
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
					
				_heal_squad(i.unit)
				audio_stream_player_3d.play()
				return
		
func _heal_squad(unit :Infantry):
	var squad :InfantrySquad = unit.squad
	squad.check_squad_size(unit.current_tile, unit.global_position)
	
	for i in squad.members:
		if medical_supply <= 0:
			return
			
		if is_instance_valid(i):
			if i.hp < i.max_hp:
				i.heal(usage_rate)
				medical_supply = int(clamp(medical_supply - usage_rate, 0, max_medical_supply))





