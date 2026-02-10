tool
extends Button

export var button_image :StreamTexture setget set_button_image
export var button_color: Color = Color(0, 0, 0)
export var button_color_toggle :Color = Color(0.230469, 0.230469, 0.230469)
export var manual_toggle :bool = false

var is_toggle: bool = false

onready var texture_rect = $TextureRect
onready var color_rect = $ColorRect

func _ready():
	if not manual_toggle:
		connect("pressed", self, "_on_pressed")
		
	texture_rect.texture = button_image
	color_rect.color = button_color_toggle if is_toggle else button_color
	
func set_button_image(value):
	button_image = value
	if texture_rect:
		texture_rect.texture = button_image

func _on_pressed():
	set_toggle_button(not is_toggle)
	
func set_toggle_button(v :bool):
	is_toggle = v
	color_rect.color = button_color_toggle if is_toggle else button_color
