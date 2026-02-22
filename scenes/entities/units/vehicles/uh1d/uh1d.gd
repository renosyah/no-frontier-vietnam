extends Vehicle

const selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")

var engine_run :bool = true

export var main_rotor_speed = 900
export var tail_rotor_speed = 1800

onready var _main_rotor_speed = main_rotor_speed
onready var _tail_rotor_speed = tail_rotor_speed

onready var _current_main_rotor_speed = main_rotor_speed
onready var _current_rotor_speed = tail_rotor_speed

onready var main_rotor = $pivot/main_rotor
onready var back_rotor = $pivot/back_rotor
onready var input_detection = $input_detection
onready var circle = $circle
onready var area = $Area
onready var animation_player = $AnimationPlayer
onready var pivot = $pivot
onready var audio_stream_player_3d = $AudioStreamPlayer3D

puppet var _puppet_rotation_x :float # foward tilt sync

func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_rotation_x", pivot.global_rotation.x)
		
func _ready():
	area.connect("input_event", self, "_on_Area_input_event")
	circle.set_surface_material(0, Global.spatial_team_colors[team])

func set_selected(v :bool):
	.set_selected(v)
	
	if not is_selectable:
		return
		
	circle.set_surface_material(0, selected_area_material if _is_selected else Global.spatial_team_colors[team])
	
func move_to(tile_id :Vector2):
	.move_to(tile_id)
	
	if fuel == 0 or _on_task:
		return
		
	_main_rotor_speed = main_rotor_speed
	_tail_rotor_speed = tail_rotor_speed
	_altitude = altitude
	
	animation_player.play("foward")

func _on_uh1d_on_finish_travel(unit, last_id, current_id):
	animation_player.play_backwards("foward")
	
func drop_passenger():
	if _on_task:
		return
		
	if not tile_map.is_nav_enable(current_tile):
		return
		
	_on_task = true
	_altitude = 0
	animation_player.play("landing")
	animation_player.play("door_open")
	yield(get_tree().create_timer(3),"timeout")
	_altitude = altitude
	
	.drop_passenger()
	animation_player.play("door_close")
	_on_task = false
	
func prepare_take_passenger():
	.prepare_take_passenger()
	
	if _on_task:
		return
		
	_on_task = true
	_altitude = 0
	animation_player.play("landing")
	animation_player.play("door_open")
	
func take_passenger(_members :Array):
	.take_passenger(_members)
	
	animation_player.play("door_close")
	_altitude = altitude
	_on_task = false
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if engine_run:
		_current_main_rotor_speed = lerp(_current_main_rotor_speed, _main_rotor_speed, 1 * delta)
		_current_rotor_speed = lerp(_current_rotor_speed, _tail_rotor_speed, 2 * delta)
		
	main_rotor.rotate_y(deg2rad(_current_main_rotor_speed) * delta)
	back_rotor.rotate_x(deg2rad(_current_rotor_speed) * delta)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		pivot.global_rotation.x = lerp_angle(pivot.global_rotation.x, _puppet_rotation_x, 25 * delta)
		
func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		set_selected(not _is_selected)
		emit_signal("on_unit_selected", self, _is_selected)
	
func _on_Area_input_event(_camera, event, _position, _normal, _shape_idx):
	if is_selectable:
		input_detection.check_input(event)
		


