extends Node
class_name BaseGameplay

func _ready():
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()
	
	_spawn_grand_map()
	_spawn_movable_camera()
	_setup_ui()
	
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
	
func _on_leave():
	Global.change_scene("res://menu/main/main.tscn", true, 1)
	
##########################################  ############################################

var grand_map :BaseTileMap

func _spawn_grand_map():
	grand_map = preload("res://scenes/maps/grand/grand_map.tscn").instance()
	grand_map.connect("on_map_ready", self, "_on_grand_map_ready")
	add_child(grand_map)
	grand_map.generate_from_data(Global.grand_map_data)
	grand_map.setup_border_scale(Vector3.ONE * ((Global.grand_map_manifest_data.map_size * 2) + 1.5))
	
func _on_grand_map_ready():
	if NetworkLobbyManager.is_server():
		NetworkLobbyManager.set_host_ready()
	
##########################################  ############################################

var movable_camera_room :MovableCamera
var movable_camera_battle :MovableCamera

func _spawn_movable_camera():
	movable_camera_room = preload("res://assets/camera/movable_camera_room.tscn").instance()
	add_child(movable_camera_room)
	
	movable_camera_battle = preload("res://assets/camera/movable_camera_battle.tscn").instance()
	add_child(movable_camera_battle)
	
	movable_camera_battle.set_as_current(false)
	movable_camera_room.set_as_current(true)

##########################################  ############################################

var ui :GameplayUi

func _setup_ui():
	ui = preload("res://menu/gameplay/ui/ui.tscn").instance()
	add_child(ui)
	use_grand_camera()

func use_grand_camera():
	var map_size = Global.grand_map_manifest_data.map_size
	ui.movable_camera_ui.target = movable_camera_room
	ui.movable_camera_ui.camera_limit_bound = Vector3( map_size + 1, 0, map_size)
	ui.movable_camera_ui.center_pos = grand_map.global_position + Vector3(0, 0, 2)
	
func use_battle_camera(center :Vector3):
	var map_size = Global.grand_map_manifest_data.battle_map_size
	ui.movable_camera_ui.target = movable_camera_battle
	ui.movable_camera_ui.camera_limit_bound = Vector3(map_size + 1, 0, map_size)
	ui.movable_camera_ui.center_pos = center + Vector3(0, 0, 2)
