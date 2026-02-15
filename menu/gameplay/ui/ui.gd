extends Control
class_name GameplayUi

onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var center_pos = $CanvasLayer/center_pos
onready var battle_map_name = $CanvasLayer/Control/VBoxContainer/HBoxContainer/ColorRect/battle_map_name
onready var grand_map_overlay_ui = $CanvasLayer/grand_map_overlay_ui

var spawned_squad :Array # refrence for BaseGameplay spawned_squad
var squad_positions :Dictionary = {} # refrence for BaseGameplay squad_positions

func on_grand_map_tile_selected(tile_id :Vector2, grand_map :BaseTileMap):
	pass
	
func on_battle_map_tile_selected(tile_id :Vector2, battle_map :BaseTileMap):
	pass
	

