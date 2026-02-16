extends MarginContainer
class_name FloatingSquadIcon

signal on_press

export var color :Color
export var icon :Resource
export var is_selectable :bool

onready var bg_2 = $bg2
onready var bg = $bg
onready var icn = $VBoxContainer/icn
onready var input_detection = $input_detection

func _ready():
	bg.modulate = color
	icn.texture = icon
	bg_2.visible = false
	
	mouse_filter = MOUSE_FILTER_IGNORE
	
	if is_selectable:
		mouse_filter = MOUSE_FILTER_STOP
		connect("gui_input", self, "_on_floating_icon_gui_input")
	
func selected(v :bool):
	bg_2.visible = v

func _on_floating_icon_gui_input(event):
	input_detection.check_input(event)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_press")
