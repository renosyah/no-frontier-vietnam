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

onready var unit_stats = $CanvasLayer/Control/VBoxContainer/HBoxContainer/unit_stats
onready var game_resource = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control2/game_resource
onready var bm_shortcut_holder = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control/VBoxContainer/bm_shortcut_holder
onready var capture_progress = $CanvasLayer/Control/VBoxContainer/MarginContainer/Control/VBoxContainer/capture_progress

onready var toggle_attack_move = $CanvasLayer/Control/HBoxContainer/VBoxContainer2/attack_move/toggle_attack_move

var player :PlayerData
var grand_map_data :TileMapFileData
var grand_map_mission_data :GrandMapFileMission

var attack_move_mode :bool
var selected_battle_map_unit :BaseTileUnit setget _on_selected_battle_map_unit
var selected_squad :BaseSquad setget _on_selected_squad

func _ready():
	unit_stats.visible = false
	
func on_contested_map_point_update():
	for i in bm_shortcut_holder.get_children():
		i.display_update_point(player.player_team)
		
func on_contested_map_updated(contested_tile_object :Dictionary, zoomable :Array):
	for i in bm_shortcut_holder.get_children():
		bm_shortcut_holder.remove_child(i)
		i.queue_free()
		
	var keys :Array = contested_tile_object.keys()
	var total_captured :int = 0
	var total_point :int = 0
	
	for key in keys:
		var contested :ContestedTile = contested_tile_object[key]
		if contested.team == player.player_team:
			total_captured += 1
		
		if contested.team != 0:
			total_point += 1
		
		if zoomable.has(key):
			var item = preload("res://menu/gameplay/ui/battle_map_shortcut/bm_shortcut.tscn").instance()
			item.button_icon = contested.icon
			item.button_color = Global.get_base_color(contested.team, player.player_team)
			item.connect("pressed", self, "_on_bm_shortcut_press", [key])
			item.contested = contested
			bm_shortcut_holder.add_child(item)
			
			var centerIndex = int(bm_shortcut_holder.get_child_count() / 2)
			bm_shortcut_holder.move_child(item, centerIndex)
			
	capture_progress.max_value = total_point
	capture_progress.value = total_captured
	
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

func _on_attack_move_pressed():
	attack_move_mode = not attack_move_mode
	toggle_attack_move.visible = attack_move_mode
