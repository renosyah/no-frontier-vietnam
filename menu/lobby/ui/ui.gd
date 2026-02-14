extends Control

const player_item_scene = preload("res://menu/lobby/player_item/player_item.tscn")

onready var match_tab = $CanvasLayer/Control/VBoxContainer/match_tab
onready var player_tab = $CanvasLayer/Control/VBoxContainer/player_tab

onready var play = $CanvasLayer/Control/VBoxContainer/CenterContainer/play
onready var receiving_data = $CanvasLayer/Control/receiving_data
onready var receiving_data_progress = $CanvasLayer/Control/receiving_data/VBoxContainer/receiving_data_progress

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
		play.disabled = false
		play.visible = true
		receiving_data.visible = false
		
		_on_lobby_player_update(NetworkLobbyManager.get_players())
		
	else:
		play.visible = false
		
		receiving_data.visible = true
		receiving_data_progress.value = 0
		receiving_data_progress.max_value = 100
		
		rpc_id(NetworkLobbyManager.host_id, "_request_grand_map_data", NetworkLobbyManager.get_id())
		
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
	
# for host
remote func _request_grand_map_data(from_id :int):
	var _manifest :GrandMapFileManifest = Global.grand_map_manifest_data
	var _mission :GrandMapFileMission = Global.grand_map_mission_data
	var _map_data :TileMapFileData = Global.grand_map_data
	
	rpc_id(
		from_id, "_receive_grand_map_data",
		var2bytes(_manifest.to_dictionary()),
		var2bytes(_mission.to_dictionary()),
		var2bytes(_map_data.to_dictionary())
	)
	
remote func _request_battle_map_datas(from_id :int):
	var size = Global.battle_map_datas.size()
	for key in Global.battle_map_datas.keys():
		var data :TileMapFileData = Global.battle_map_datas[key]
		var data_byte = var2bytes(data.to_dictionary())
		rpc_id(from_id, "_receive_battle_map_data",key, data_byte, size)
		yield(get_tree().create_timer(0.2),"timeout")
		
# for join player
remote func _receive_grand_map_data(manifest: PoolByteArray, mission: PoolByteArray, map_data: PoolByteArray):
	var _manifest :GrandMapFileManifest = GrandMapFileManifest.new()
	_manifest.from_dictionary(bytes2var(manifest))
	Global.grand_map_manifest_data = _manifest
	
	var _mission :GrandMapFileMission = GrandMapFileMission.new()
	_mission.from_dictionary(bytes2var(mission))
	Global.grand_map_mission_data = _mission
	
	var _map_data :TileMapFileData = TileMapFileData.new()
	_map_data.from_dictionary(bytes2var(map_data))
	Global.grand_map_data = _map_data
	
	rpc_id(NetworkLobbyManager.host_id, "_request_battle_map_datas", NetworkLobbyManager.get_id())
	
# for join player
remote func _receive_battle_map_data(id :Vector2, map_data: PoolByteArray, total_size :int):
	var _map_data :TileMapFileData = TileMapFileData.new()
	_map_data.from_dictionary(bytes2var(map_data))
	Global.battle_map_datas[id] = _map_data
	
	receiving_data_progress.value = Global.battle_map_datas.size()
	receiving_data_progress.max_value = total_size
		
	if Global.battle_map_datas.size() == total_size:
		receiving_data.visible = false
		
		# tell everyone that you have receive map data
		rpc("_map_data_received",  NetworkLobbyManager.get_id())
	
remotesync func _map_data_received(player_id :int):
	var player_loading = false
	for i in players_holder.get_children():
		if i.id == player_id:
			i.set_loading(false)
		
		if i.is_loading():
			player_loading = true
			
	if NetworkLobbyManager.is_server():
		play.disabled = player_loading
	
func _on_lobby_player_update(players :Array):
	for i in players_holder.get_children():
		players_holder.remove_child(i)
		i.queue_free()
		
	for i in players:
		var player :NetworkPlayer = i
		var item = player_item_scene.instance()
		item.id = player.player_network_unique_id
		item.player_name = player.player_name
		players_holder.add_child(item)
		item.set_loading(player.player_network_unique_id != NetworkLobbyManager.host_id)
		
	if NetworkLobbyManager.is_server():
		play.disabled = players.size() > 1
		
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




