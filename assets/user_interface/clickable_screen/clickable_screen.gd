extends Control
class_name ClickableScreen

signal on_screen_clicked(pos)

var _click_position :Vector2
onready var _input_detection = $input_detection

func _on_input_detection_any_gesture(_sig, event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_screen_clicked", _click_position)

func _on_clickable_screen_gui_input(event):
	_click_position = event.position
	_input_detection.check_input(event)
