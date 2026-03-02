extends MeshInstance

signal on_listening(by_team)

onready var collision_shape = $CollisionShape

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
		emit_signal("on_listening", 0)
		return
		
	for result in results:
		if result["collider"] is HitRegister:
			var i :HitRegister = result["collider"]
			if i.unit is Infantry:
				emit_signal("on_listening", i.unit.team)
				return
