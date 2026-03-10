extends BaseProjectile

var grenade_collision = preload("res://scenes/entities/projectiles/grenade/grenade_collision.tres")

onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D

func launch():
	.launch()
	
	animation_player.play("launch")
	
	
func on_stop():
	set_process(false)
	
	animation_player.play("explode")
	audio_stream_player_3d.play()
	
	if not is_master:
		return
		
	var shape = PhysicsShapeQueryParameters.new()
	shape.collision_mask = 1
	shape.collide_with_areas = true
	shape.collide_with_bodies = false
	shape.set_shape(grenade_collision)
	shape.transform = global_transform

	var results :Array = get_world().direct_space_state.intersect_shape(shape)
	if results.empty():
		return
		
	for result in results:
		if result["collider"] is HitRegister:
			var hr :HitRegister = result["collider"]
			hr.take_damage(damage)
	
func _exlploded():
	.on_stop()
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
