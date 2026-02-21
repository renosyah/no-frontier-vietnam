extends Vehicle

const selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")

var engine_run :bool = true

export var main_rotor_speed = 900
export var tail_rotor_speed = 1800

onready var main_rotor = $pivot/main_rotor
onready var back_rotor = $pivot/back_rotor
onready var input_detection = $input_detection
onready var circle = $circle
onready var arrow = $circle/arrow
onready var area = $Area

func _ready():
	area.connect("input_event", self, "_on_Area_input_event")
	arrow.visible = _is_selected
	circle.set_surface_material(0, Global.spatial_team_colors[team])
	
func set_selected(v :bool):
	.set_selected(v)
	
	if not is_selectable:
		return
		
	circle.set_surface_material(0, selected_area_material if _is_selected else Global.spatial_team_colors[team])
	arrow.visible = _is_selected
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if engine_run:
		main_rotor.rotate_y(deg2rad(main_rotor_speed) * delta)
		back_rotor.rotate_x(deg2rad(tail_rotor_speed) * delta)
		
	circle.global_position = global_position * Vector3(1, 0, 1)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		set_selected(not _is_selected)
		emit_signal("on_unit_selected", self, _is_selected)
	
func _on_Area_input_event(_camera, event, _position, _normal, _shape_idx):
	if is_selectable:
		input_detection.check_input(event)
		
