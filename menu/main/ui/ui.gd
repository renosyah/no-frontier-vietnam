extends Control

const edit_map_button = preload("res://menu/editor_menu/button/edit_map_button.tscn")

onready var main = $CanvasLayer/Control/main
onready var new_game = $CanvasLayer/Control/new_game
onready var map_select = $CanvasLayer/Control/map_select

onready var maps_holder = $CanvasLayer/Control/map_select/vbox/ScrollContainer/GridContainer

func _ready():
	_on_back_pressed()
	
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_host_player_connected")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().quit()
	
func _on_editor_pressed():
	Global.change_scene("res://menu/editor_menu/editor_menu.tscn")

func _on_play_pressed():
	main.visible = false
	new_game.visible = true
	
func _on_host_pressed():
	_show_maps()
	map_select.visible = true
	
func _show_maps():
	Global.load_maps()
	
	for i in maps_holder.get_children():
		maps_holder.remove_child(i)
		i.queue_free()
		
	for i in Global.grand_map_manifest_datas:
		var data :GrandMapFileManifest = i
		var loaded_maps_edit_button = edit_map_button.instance()
		loaded_maps_edit_button.data = data
		loaded_maps_edit_button.connect("pressed", self, "_loaded_maps_edit_button_pressed")
		maps_holder.add_child(loaded_maps_edit_button)
		maps_holder.move_child(loaded_maps_edit_button, 0)
		
func _loaded_maps_edit_button_pressed(manif :GrandMapFileManifest):
	yield(Global.set_active_map(manif),"completed")

	var config :NetworkServer = NetworkServer.new()
	NetworkLobbyManager.configuration = config
	NetworkLobbyManager.player_name = Global.player_data.player_name
	NetworkLobbyManager.player_extra_data = Global.player_data.to_dictionary()
	NetworkLobbyManager.init_lobby()
	
func _on_host_player_connected():
	Global.change_scene("res://menu/lobby/lobby.tscn", true, 2)
	
func _on_join_pressed():
	Global.change_scene("res://menu/join/join.tscn", true, 2)
	
func _on_back_pressed():
	map_select.visible = false
	main.visible = true
	new_game.visible = false

func _on_close_map_select_pressed():
	map_select.visible = false
