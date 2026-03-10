extends BaseProjectile

var grenade_collision = preload("res://scenes/entities/projectiles/grenade/grenade_collision.tres")

export var damage :int = 6
export var is_master :bool

var top_down_point :Vector3
onready var timer = $Timer
onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D

# override
func launch():
	#.launch()
	top_down_point = to + Vector3(0, max_range, 0)
	visible = true
	dir = global_position.direction_to(top_down_point)
	travel_distance = 0
	is_ready = false
	set_process(true)
	look_at(top_down_point, Vector3.UP)
	animation_player.play("rotate")
	
# override
func on_travel(delta):
	#.on_travel(delta)
	var dist = global_position.distance_to(to)
	if dist < 0.1:
		on_stop()
		return
	
	var vel = speed * delta
	
	if top_down_point.y > to.y:
		top_down_point += Vector3.DOWN * vel
	
	dir = global_position.direction_to(top_down_point)
	translation += dir * vel
	look_at(top_down_point, Vector3.UP)
	
# override
func on_stop():
	#.on_stop()
	animation_player.stop()
	set_process(false)
	timer.start()

func _on_Timer_timeout():
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

func _exploded():
	is_ready = true
	visible = false
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
