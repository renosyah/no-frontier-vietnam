extends MarginContainer

onready var color_rect = $Control2/MarginContainer/ColorRect
onready var hp_bar = $Control/hp_bar
onready var ammo_bar = $Control/ammo_bar
onready var hide_timeout = $hide_timeout


func init_bar(color :Color, max_hp :int, max_ammo: int):
	hp_bar.max_value = max_hp
	ammo_bar.max_value = max_ammo
	
	#hp_bar.tint_progress = color
	color_rect.color = color
	
func update_bar(hp :int, ammo: int):
	hp_bar.value = hp
	ammo_bar.value = ammo
	
	visible = true
	
	if hide_timeout.is_stopped():
		hide_timeout.start()
		
func _on_hide_timeout_timeout():
	visible = false
