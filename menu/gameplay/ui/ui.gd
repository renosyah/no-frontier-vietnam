extends Control
class_name GameplayUi

onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var center_pos = $CanvasLayer/center_pos
onready var battle_map_name = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control/MarginContainer/battle_map_name
onready var grand_map_overlay_ui = $CanvasLayer/grand_map_overlay_ui
onready var battle_map_overlay_ui = $CanvasLayer/battle_map_overlay_ui

onready var spawn_infantry = $CanvasLayer/Control/HBoxContainer/VBoxContainer/spawn_infantry
onready var spawn_heli = $CanvasLayer/Control/HBoxContainer/VBoxContainer/spawn_heli
onready var spawn_bot_infantry = $CanvasLayer/Control/HBoxContainer/VBoxContainer2/spawn_bot_infantry

onready var unit_stats = $CanvasLayer/Control/HBoxContainer/MarginContainer/unit_stats
onready var game_resource = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control2/game_resource

var selected_battle_map_unit :BaseTileUnit setget _on_selected_battle_map_unit
var selected_squad :BaseSquad setget _on_selected_squad
var spawned_squad :Array # refrence for BaseGameplay spawned_squad
var squad_positions :Dictionary = {} # refrence for BaseGameplay squad_positions

func _ready():
	spawn_bot_infantry.visible = NetworkLobbyManager.is_server()
	unit_stats.visible = false
	
func _on_selected_battle_map_unit(v :BaseTileUnit):
	selected_battle_map_unit = v
	
	var is_set :bool = is_instance_valid(selected_battle_map_unit)
	movable_camera_ui.detect_in_out = not is_set
	unit_stats.visible = is_set
	
func _on_selected_squad(v :BaseSquad):
	selected_squad = v
	
func _on_infantry_stats_close():
	selected_battle_map_unit.set_selected(false)
	_on_selected_battle_map_unit(null)

func _on_unit_stats_drop_passenger():
	if not is_instance_valid(selected_battle_map_unit):
		return
	
	if selected_battle_map_unit is Vehicle:
		selected_battle_map_unit.drop_passenger()
		
	selected_battle_map_unit.set_selected(false)
	_on_selected_battle_map_unit(null)
	
func _on_menu_button_pressed():
	NetworkLobbyManager.leave()
