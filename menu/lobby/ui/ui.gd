extends Control

const player_item_scene = preload("res://menu/lobby/player_item/player_item.tscn")

onready var match_tab = $CanvasLayer/Control/VBoxContainer/match_tab
onready var player_tab = $CanvasLayer/Control/VBoxContainer/player_tab

onready var play = $CanvasLayer/Control/VBoxContainer/CenterContainer/play
onready var ready = $CanvasLayer/Control/VBoxContainer/CenterContainer/ready

onready var players_holder = $CanvasLayer/Control/VBoxContainer/player_tab/VBoxContainer

func _ready():
	NetworkLobbyManager.connect("lobby_player_update", self, "_on_lobby_player_update")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	NetworkLobbyManager.connect("on_kicked_by_host", self, "_on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"_on_host_ready")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	if NetworkLobbyManager.is_server():
		play.visible = true
		ready.visible = false
		_on_lobby_player_update(NetworkLobbyManager.get_players())
		
	else:
		play.visible = false
		ready.visible = true
		
	_on_players_pressed()
	
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
	NetworkLobbyManager.leave()
	
func _on_lobby_player_update(players :Array):
	for i in players_holder.get_children():
		players_holder.remove_child(i)
		i.queue_free()
		
	for i in players:
		var player :NetworkPlayer = i
		var item = player_item_scene.instance()
		item.player_name = player.player_name
		players_holder.add_child(item)
		
func _on_host_ready():
	Global.change_scene("res://menu/gameplay/client/client.tscn", true, 3)
	
func _on_leave():
	Global.change_scene("res://menu/main/main.tscn", true, 1)

func _on_match_pressed():
	match_tab.visible = true
	player_tab.visible = false

func _on_players_pressed():
	match_tab.visible = false
	player_tab.visible = true

func _on_play_pressed():
	Global.change_scene("res://menu/gameplay/host/host.tscn", true, 3)
	
func _on_ready_pressed():
	ready.disabled = true
	NetworkLobbyManager.set_ready()
