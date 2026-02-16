extends Control
class_name GameplayUi

onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var center_pos = $CanvasLayer/center_pos
onready var battle_map_name = $CanvasLayer/Control/VBoxContainer/HBoxContainer/ColorRect/battle_map_name
onready var grand_map_overlay_ui = $CanvasLayer/grand_map_overlay_ui
onready var setup_ambush = $CanvasLayer/Control/VBoxContainer/MarginContainer2/HBoxContainer/setup_ambush

var selected_squad :BaseSquad setget _on_selected_squad
var spawned_squad :Array # refrence for BaseGameplay spawned_squad
var squad_positions :Dictionary = {} # refrence for BaseGameplay squad_positions

func _on_selected_squad(v :BaseSquad):
	selected_squad = v
	
	if is_instance_valid(selected_squad):
		setup_ambush.visible = true
		setup_ambush.set_toggle_button(selected_squad.is_ambush_mode())
		
	else:
		setup_ambush.visible = false
		
func _on_setup_ambush_pressed():
	selected_squad.setup_ambush(not selected_squad.is_ambush_mode())
	setup_ambush.set_toggle_button(not setup_ambush.is_toggle)
