extends Node

onready var movable_camera_custom = $movable_camera_custom
onready var ui = $ui
onready var battle_map = $battle_map
onready var clickable_floor = $clickable_floor

var grand_map_manifest_data :GrandMapFileManifest
var battle_map_data :TileMapFileData

# Called when the node enters the scene tree for the first time.
func _ready():
	grand_map_manifest_data = Global.grand_map_manifest_data
	battle_map_data = Global.battle_map_data
	
	Global.camera_limit_bound = Vector3(grand_map_manifest_data.battle_map_size + 1, 0, grand_map_manifest_data.battle_map_size)
	
	ui.movable_camera_ui.camera_limit_bound = Global.camera_limit_bound
	ui.map_name.text = Global.battle_map_name
	ui.movable_camera_ui.target = movable_camera_custom
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	battle_map.generate_from_data(battle_map_data, true)
	
func _process(_delta):
	var cam_pos = movable_camera_custom.translation
	clickable_floor.translation = cam_pos * Vector3(1,0,1)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().change_scene("res://menu/editor/editor.tscn")

func _on_battle_map_on_map_ready():
	pass # Replace with function body.
