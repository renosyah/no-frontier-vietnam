extends Node
class_name BaseGameplay

func _ready():
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	setup_battle_map_pos()
	spawn_grand_map()
	spawn_movable_camera()
	setup_clickable_floor()
	setup_ui()
	setup_selection()
	
	
func _process(_delta):
	var valids = [
		is_instance_valid(clickable_floor),
		is_instance_valid(selected_cam)
	]
	if valids.has(false):
		return
		
	clickable_floor.translation = selected_cam.translation * Vector3(1,0,1)

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	if selected_cam == movable_camera_battle:
		hide_battle_map()
		use_grand_camera()
		return
		
	NetworkLobbyManager.leave()
	
func _on_leave():
	Global.change_scene("res://menu/main/main.tscn", true, 1)
	
##########################################  ############################################

var grand_map :BaseTileMap

func spawn_grand_map():
	grand_map = preload("res://scenes/maps/grand/grand_map.tscn").instance()
	grand_map.connect("on_map_ready", self, "_on_grand_map_ready")
	grand_map.name = "grand_map"
	add_child(grand_map)
	grand_map.generate_from_data(Global.grand_map_data)
	grand_map.setup_border_scale(Vector3.ONE * ((Global.grand_map_manifest_data.map_size * 2) + 1.5))
	
func _on_grand_map_ready():
	if NetworkLobbyManager.is_server():
		NetworkLobbyManager.set_host_ready()
		
	Global.hide_transition()
	
##########################################  ############################################

var movable_camera_room :MovableCamera
var movable_camera_battle :MovableCamera
var selected_cam :MovableCamera

func spawn_movable_camera():
	movable_camera_room = preload("res://assets/camera/movable_camera_room.tscn").instance()
	movable_camera_room.name = "movable_camera_room"
	add_child(movable_camera_room)
	movable_camera_room.translation = Vector3(0, 5, 2)
	
	movable_camera_battle = preload("res://assets/camera/movable_camera_battle.tscn").instance()
	movable_camera_battle.name = "movable_camera_battle"
	add_child(movable_camera_battle)
	movable_camera_battle.translation = Vector3(0, 3, 2)
	
##########################################  ############################################

var ui :GameplayUi

func setup_ui():
	ui = preload("res://menu/gameplay/ui/ui.tscn").instance()
	ui.name = "ui"
	add_child(ui)
	
	use_grand_camera()

func use_grand_camera():
	movable_camera_battle.set_as_current(false)
	movable_camera_room.set_as_current(true)
	
	selected_cam = movable_camera_room
	#selected_cam.translation = Vector3(0, 5, 2) + grand_map.global_position
	
	var map_size = Global.grand_map_manifest_data.map_size
	ui.movable_camera_ui.target = movable_camera_room
	ui.movable_camera_ui.camera_limit_bound = Vector3( map_size + 1, 0, map_size)
	ui.movable_camera_ui.center_pos = grand_map.global_position + Vector3(0, 0, 2)
	
	ground_table.visible = false
	
func use_battle_camera(center :Vector3):
	movable_camera_room.set_as_current(false)
	movable_camera_battle.set_as_current(true)
	
	selected_cam = movable_camera_battle
	selected_cam.translation = Vector3(0, 3, 2) + center
	
	var map_size = Global.grand_map_manifest_data.battle_map_size
	ui.movable_camera_ui.target = movable_camera_battle
	ui.movable_camera_ui.camera_limit_bound = Vector3(map_size + 1, 0, map_size)
	ui.movable_camera_ui.center_pos = center + Vector3(0, 0, 2)
	
	ground_table.visible = true
	
##########################################  ############################################

var clickable_floor :ClickableFloor

func setup_clickable_floor():
	clickable_floor = preload("res://assets/clickable_floor/clickable_floor.tscn").instance()
	clickable_floor.connect("on_floor_clicked", self, "_on_floor_clicked")
	clickable_floor.name = "clickable_floor"
	add_child(clickable_floor)

func _on_floor_clicked(pos :Vector3):
	match selected_cam:
		movable_camera_room:
			
			var tile = grand_map.get_closes_tile(pos)
			selection.translation = tile.pos + grand_map.global_position
			selection.visible = true
			
			if battle_map_pos.has(tile.id):
				rpc("_spawn_battle_map", tile.id, battle_map_pos[tile.id])
			
		movable_camera_battle:
			pass
	
##########################################  ############################################

var selection :Spatial

func setup_selection():
	selection = preload("res://assets/tile_highlight/selection.tscn").instance()
	selection.name = "selection"
	add_child(selection)
	
	selection.visible = false
	
##########################################  ############################################

var ground_table :Sprite3D
var battle_map_pos :Dictionary = {} # [Vector2 : Vector3]
var battle_map_holder :Dictionary = {} # [Vector2 : BattleMap]

func setup_battle_map_pos():
	ground_table = preload("res://assets/background/ground.tscn").instance()
	ground_table.name = "ground_table"
	add_child(ground_table)
	
	var maps = Global.battle_map_datas.keys()
	var poses = Utils.generate_positions(maps.size(), 40, 50)
	
	var idx = 0
	for i in maps:
		battle_map_pos[i] = poses[idx]
		idx += 1

remotesync func _spawn_battle_map(id :Vector2, at :Vector3):
	if battle_map_holder.has(id):
		_on_battle_map_ready(battle_map_holder[id])
		return
		
	var manif = Global.grand_map_manifest_data
	var battle_map = preload("res://scenes/maps/battle/battle_map.tscn").instance()
	battle_map.connect("on_map_ready", self, "_on_battle_map_ready", [battle_map])
	battle_map.name = manif.battle_map_names[id]
	add_child(battle_map)
	
	battle_map.translation = at
	battle_map.generate_from_data(Global.battle_map_datas[id])
	battle_map_holder[id] = battle_map
	battle_map.visible = false
	
func hide_battle_map():
	for i in battle_map_holder.values():
		i.visible = false
	
func _on_battle_map_ready(battle_map :BaseTileMap):
	battle_map.visible = true
	use_battle_camera(battle_map.global_position)
	ground_table.position = battle_map.global_position + Vector3(0, -0.4, -1)





