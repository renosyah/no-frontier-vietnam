extends MarginContainer

export var icon :StreamTexture

onready var color_rect = $Control2/MarginContainer/ColorRect
onready var hp_bar = $Control/hp_bar
onready var ammo_bar = $Control/ammo_bar
onready var hide_timeout = $hide_timeout
onready var texture_rect = $Control2/MarginContainer/TextureRect

var _show :bool

func _ready():
	texture_rect.texture = icon

func init_bar(color :Color, max_hp :int, max_ammo: int):
	hp_bar.max_value = max_hp
	ammo_bar.max_value = max_ammo
	color_rect.color = color
	
func update_bar(hp :int, ammo: int):
	hp_bar.value = hp
	ammo_bar.value = ammo
	
	if not _show:
		visible = true
		_show = true
		hide_timeout.start()
		
func _on_hide_timeout_timeout():
	visible = false
	_show = false
