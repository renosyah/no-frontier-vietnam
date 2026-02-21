extends Control
class_name GameplayUi

onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var center_pos = $CanvasLayer/center_pos
onready var battle_map_name = $CanvasLayer/Control/VBoxContainer/HBoxContainer/ColorRect/battle_map_name
onready var grand_map_overlay_ui = $CanvasLayer/grand_map_overlay_ui

onready var squad_option = $CanvasLayer/Control/VBoxContainer/squad_option
onready var setup_camp = $CanvasLayer/Control/VBoxContainer/squad_option/HBoxContainer/setup_camp
onready var setup_ambush = $CanvasLayer/Control/VBoxContainer/squad_option/HBoxContainer/setup_ambush

onready var infantry_option = $CanvasLayer/Control/VBoxContainer/infantry_option

var selected_battle_map_unit :BaseTileUnit setget _on_selected_battle_map_unit
var selected_squad :BaseSquad setget _on_selected_squad
var spawned_squad :Array # refrence for BaseGameplay spawned_squad
var squad_positions :Dictionary = {} # refrence for BaseGameplay squad_positions

func _ready():
	squad_option.visible = false
	infantry_option.visible = false
	
func _on_selected_battle_map_unit(v :BaseTileUnit):
	selected_battle_map_unit = v
	infantry_option.visible =  is_instance_valid(selected_battle_map_unit)
	
func _on_selected_squad(v :BaseSquad):
	selected_squad = v
	squad_option.visible = false
	
	if not is_instance_valid(selected_squad):
		return
		
	if selected_squad is BaseInfantrySquad:
		squad_option.visible = true
		setup_ambush.set_toggle_button(selected_squad.is_ambush_mode())
		setup_camp.set_toggle_button(selected_squad.is_camp_mode())
		
func _on_setup_ambush_pressed():
	if not is_instance_valid(selected_squad):
		return
		
	if selected_squad is BaseInfantrySquad:
		selected_squad.setup_ambush(not selected_squad.is_ambush_mode())
		setup_ambush.set_toggle_button(selected_squad.is_ambush_mode())
	
	
func _on_setup_camp_pressed():
	if not is_instance_valid(selected_squad):
		return
		
	if selected_squad is BaseInfantrySquad:
		selected_squad.setup_camp(not selected_squad.is_camp_mode())
		setup_camp.set_toggle_button(selected_squad.is_camp_mode())
	
func _on_fire_weapon_pressed():
	if not is_instance_valid(selected_battle_map_unit):
		return
	
	if selected_battle_map_unit is Infantry:
		selected_battle_map_unit.fire_weapon()
		Global.unit_responded(RadioChatters.COMBAT_STATUS,selected_battle_map_unit.team)

func _on_use_launcher_pressed():
	if not is_instance_valid(selected_battle_map_unit):
		return
		
	if selected_battle_map_unit is Infantry:
		selected_battle_map_unit.use_launcher(Vector3.ZERO)
		Global.unit_responded(RadioChatters.COMBAT_STATUS,selected_battle_map_unit.team)






