extends Button

export var button_icon :StreamTexture
export var button_color :Color
onready var color_rect = $ColorRect
onready var texture_rect = $TextureRect

func _ready():
	color_rect.color = button_color
	texture_rect.texture = button_icon
	texture_rect.modulate = button_color
