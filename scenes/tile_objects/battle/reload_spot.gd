extends MeshInstance

onready var collision_shape = $CollisionShape
onready var audio_stream_player_3d = $AudioStreamPlayer3D

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
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
				_resupply_squad(i.unit)
				audio_stream_player_3d.play()
				return
				
func _resupply_squad(unit :Infantry):
	var squad :InfantrySquad = unit.squad
	for i in squad.members:
		if is_instance_valid(i):
			i.take_ammo()
