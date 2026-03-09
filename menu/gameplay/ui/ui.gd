extends Control
class_name GameplayUi

signal to_battle_map(tile_id)

onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var center_pos = $CanvasLayer/center_pos
onready var battle_map_name = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control/VBoxContainer/MarginContainer/battle_map_name
onready var grand_map_overlay_ui = $CanvasLayer/grand_map_overlay_ui
onready var battle_map_overlay_ui = $CanvasLayer/battle_map_overlay_ui

onready var spawn_infantry = $CanvasLayer/Control/HBoxContainer/VBoxContainer/spawn_infantry
onready var spawn_heli = $CanvasLayer/Control/HBoxContainer/VBoxContainer/spawn_heli
onready var spawn_bot_infantry = $CanvasLayer/Control/HBoxContainer/VBoxContainer2/spawn_bot_infantry

onready var unit_stats = $CanvasLayer/Control/VBoxContainer/HBoxContainer/unit_stats
onready var game_resource = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control2/game_resource
onready var bm_shortcut_holder = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control/VBoxContainer/bm_shortcut_holder

var player :PlayerData
var grand_map_mission_data :GrandMapFileMission
var selected_battle_map_unit :BaseTileUnit setget _on_selected_battle_map_unit
var selected_squad :BaseSquad setget _on_selected_squad

func _ready():
	spawn_bot_infantry.visible = NetworkLobbyManager.is_server()
	unit_stats.visible = false
	
func on_zoomable_battle_map_updated(zoomable_battle_map :Dictionary):
	for i in bm_shortcut_holder.get_children():
		bm_shortcut_holder.remove_child(i)
		i.queue_free()
		
	var keys :Array = zoomable_battle_map.keys()
	var bases :Array = grand_map_mission_data.bases
	var point :Array = grand_map_mission_data.points
	
	var idx = 1
	for key in bases:
		if not keys.has(key):
			continue
			
		var item = preload("res://menu/gameplay/ui/battle_map_shortcut/bm_shortcut.tscn").instance()
		item.button_icon = preload("res://assets/user_interface/icons/base.png")
		item.button_color = Global.get_base_color(idx, player.player_team)
		item.connect("pressed", self, "_on_bm_shortcut_press", [key])
		bm_shortcut_holder.add_child(item)
		idx += 1
		
	for key in point:
		if not keys.has(key):
			continue
			
		var item = preload("res://menu/gameplay/ui/battle_map_shortcut/bm_shortcut.tscn").instance()
		item.button_icon = preload("res://assets/user_interface/icons/flag.png")
		item.button_color = Color.white
		item.connect("pressed", self, "_on_bm_shortcut_press", [key])
		bm_shortcut_holder.add_child(item)
		bm_shortcut_holder.move_child(item, 1)
		
func _on_bm_shortcut_press(tile_id :Vector2):
	emit_signal("to_battle_map", tile_id)
	
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
