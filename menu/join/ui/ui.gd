extends Control

const ITEM = preload("res://menu/join/server_item/server_item.tscn")

onready var _item_holder = $CanvasLayer/Control/VBoxContainer/ScrollContainer/VBoxContainer
onready var _server_list = $CanvasLayer/Control/VBoxContainer/ScrollContainer
onready var _find_server = $CanvasLayer/Control/VBoxContainer/Label
onready var _server_listener = $server_listener
onready var _error = $CanvasLayer/Control/VBoxContainer/error
onready var _ip_input = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/ip_input
onready var _overlay_loading = $CanvasLayer/overlay_loading

func _ready():
	NetworkLobbyManager.connect("on_client_player_connected", self, "_on_client_player_connected")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	start_finding()
	
	_overlay_loading.visible = false
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
			
func _on_back_pressed():
	stop_finding()
	Global.change_scene("res://menu/main/main.tscn", true, 1)
	
func start_finding():
	show_loading(true)
	_server_listener.setup()
	
func stop_finding():
	show_loading(false)
	_server_listener.stop()
	
func show_loading(_show):
	_find_server.visible = _show
	_server_list.visible = not _show
	
func clear_list():
	_server_listener.force_clean_up()
	for i in _item_holder.get_children():
		_item_holder.remove_child(i)
		i.queue_free()
		
func _on_server_listener_error_listening(_msg):
	stop_finding()
	_error.visible = true
	_error.text = _msg

func _on_server_listener_remove_server(serverIps):
	for child in _item_holder.get_children():
		if child.ip in serverIps:
			_item_holder.remove_child(child)
			child.queue_free()
			break
			
	show_loading(_item_holder.get_children().empty())

func _on_server_listener_new_server(serverInfo):
	show_loading(false)
	var item = ITEM.instance()
	item.connect("join", self, "_join", [serverInfo.duplicate()])
	_item_holder.add_child(item)
	item.set_info(serverInfo.ip, serverInfo.name, "Player Slot : " + str(serverInfo.player) + "/" + str(serverInfo.max_player))

func _join(info):
	stop_finding()
	_overlay_loading.visible = true
	
	var configuration = NetworkClient.new()
	configuration.ip = info["ip"]
	
	NetworkLobbyManager.player_name = Global.player_data.player_name
	NetworkLobbyManager.player_extra_data = Global.player_data.to_dictionary()
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func _on_client_player_connected():
	Global.change_scene("res://menu/lobby/lobby.tscn")
	
