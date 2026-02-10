extends Control

const edit_map_button = preload("res://menu/editor_menu/button/edit_map_button.tscn")

onready var grid_container = $CanvasLayer/Control/VBoxContainer/ScrollContainer/GridContainer
onready var loaded_maps_edit_buttons = []

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.load_maps()
	_show_maps()
	
func _show_maps():
	for i in loaded_maps_edit_buttons:
		grid_container.remove_child(i)
	loaded_maps_edit_buttons.clear()
	
	for i in Global.grand_map_manifest_datas:
		var data :GrandMapFileManifest = i
		var loaded_maps_edit_button = edit_map_button.instance()
		loaded_maps_edit_button.data = data
		loaded_maps_edit_button.connect("pressed", self, "_loaded_maps_edit_button_pressed")
		grid_container.add_child(loaded_maps_edit_button)
		grid_container.move_child(loaded_maps_edit_button, 0)
		loaded_maps_edit_buttons.append(loaded_maps_edit_button)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	Global.change_scene("res://menu/main/main.tscn")

func _on_back_pressed():
	on_back_pressed()
	
func _loaded_maps_edit_button_pressed(manif :GrandMapFileManifest):
	yield(Global.set_active_map(manif),"completed")
	Global.change_scene("res://menu/editor/editor.tscn", true, 0)
	
func _on_add_map_button_pressed():
	Global.empty_map_data()
	Global.change_scene("res://menu/editor/editor.tscn", true, 0)
