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
	
	if fuel == 0:
		_main_rotor_speed = 0
		_tail_rotor_speed = 0
		_altitude = 0
		return
		
	_main_rotor_speed = main_rotor_speed
	_tail_rotor_speed = tail_rotor_speed
	_altitude = altitude
		
func drop_passenger():
	if fuel == 0:
		return
		
	_altitude = 0
	animation_player.play("landing")
	animation_player.play("door_open")
	yield(get_tree().create_timer(3),"timeout")
	animation_player.play("door_close")
	yield(get_tree().create_timer(1),"timeout")
	_altitude = altitude
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if engine_run:
		_current_main_rotor_speed = lerp(_current_main_rotor_speed, _main_rotor_speed, 1 * delta)
		_current_rotor_speed = lerp(_current_rotor_speed, _tail_rotor_speed, 2 * delta)
		
	main_rotor.rotate_y(deg2rad(_current_main_rotor_speed) * delta)
	back_rotor.rotate_x(deg2rad(_current_rotor_speed) * delta)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		set_selected(not _is_selected)
		emit_signal("on_unit_selected", self, _is_selected)
	
func _on_Area_input_event(_camera, event, _position, _normal, _shape_idx):
	if is_selectable:
		input_detection.check_input(event)
		
