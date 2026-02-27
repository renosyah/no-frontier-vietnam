extends Area
class_name HitRegister

signal on_click

var unit :BaseTileUnit

var input_detection

func _ready():
	input_detection = preload("res://addons/Godot-Touch-Input-Manager/input_detection.tscn").instance()
	input_detection.connect("any_gesture", self, "_on_input_detection_any_gesture")
	add_child(input_detection)
	
	connect("input_event", self, "_on_hit_register_input_event")

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click")
		
func _on_hit_register_input_event(_camera, event, _position, _normal, _shape_idx):
	if unit.is_selectable:
		input_detection.check_input(event)
