extends Node
class_name BaseGameplay

func _ready():
	NetworkLobbyManager.connect("all_player_ready", self, "_on_all_player_ready")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	setup_battle_map()
	spawn_grand_map()
	spawn_movable_camera()
	setup_clickable_floor()
	setup_ui()
	setup_selection()
	
	if NetworkLobbyManager.is_server():
		NetworkLobbyManager.set_host_ready()
		
func _process(_delta):
	if is_instance_valid(current_cam):
		clickable_floor.translation = current_cam.translation * Vector3(1,0,1)
		
	show_tile_by_ray()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	if current_cam == movable_camera_battle:
		return
		
	NetworkLobbyManager.leave()
	
func _on_leave():
	Global.change_scene("res://menu/main/main.tscn", true, 1)
	
func _on_all_player_ready():
	# test squad
	if NetworkLobbyManager.is_server():
		rpc("_spawn_squad", NetworkLobbyManager.host_id, grand_map_mission_data.bases[0])
		
	Global.hide_transition()
	
##########################################  ############################################

onready var grand_map_manifest_data :GrandMapFileManifest = Global.grand_map_manifest_data
onready var grand_map_data :TileMapFileData = Global.grand_map_data
onready var grand_map_mission_data :GrandMapFileMission = Global.grand_map_mission_data
onready var battle_map_datas :Dictionary = Global.battle_map_datas

var grand_map :BaseTileMap

func spawn_grand_map():
	grand_map = preload("res://scenes/maps/grand/grand_map.tscn").instance()
	grand_map.connect("on_map_ready", self, "_on_grand_map_ready")
	grand_map.name = "grand_map"
	add_child(grand_map)
	grand_map.generate_from_data(grand_map_data)
	grand_map.setup_border_scale(Vector3.ONE * ((grand_map_manifest_data.map_size * 2) + 1.5))
	
func _on_grand_map_ready():
	NetworkLobbyManager.set_ready()
	setup_base_and_point()
	
# var bases :Dictionary = {} # [team_id : BaseTileObject] 
var points :Dictionary = {} # [team_id : BaseTileObject] 

func setup_base_and_point():
	# remove default object spawn by map
	for id in grand_map_mission_data.bases + grand_map_mission_data.points:
		grand_map.remove_spawned_object(id)
		
	var idx = 1
	for id in grand_map_mission_data.bases:
		var base :BaseTileObject = preload("res://scenes/tile_objects/grand/faction_base.tscn").instance()
		grand_map.add_child(base)
		base.translation = grand_map.get_tile_instance(id).translation
		base.set_color(Global.team_colors[idx])
		idx += 1
		
	for id in grand_map_mission_data.points:
		var point :BaseTileObject = preload("res://scenes/tile_objects/grand/flag_pole.tscn").instance()
		grand_map.add_child(point)
		point.translation = grand_map.get_tile_instance(id).translation
		point.set_color(Global.team_colors[Global.TEAM_WHITE])
		points[id] = point
		
##########################################  ############################################

var movable_camera_room :MovableCamera
var movable_camera_battle :MovableCamera
var current_cam :MovableCamera

func spawn_movable_camera():
	movable_camera_room = preload("res://assets/camera/movable_camera_room.tscn").instance()
	movable_camera_room.name = "movable_camera_room"
	add_child(movable_camera_room)
	movable_camera_room.translation = Vector3(0, 5, 2)
	
	movable_camera_battle = preload("res://assets/camera/movable_camera_battle.tscn").instance()
	movable_camera_battle.name = "movable_camera_battle"
	add_child(movable_camera_battle)
	movable_camera_battle.translation = Vector3(0, 6, 2)
	
##########################################  ############################################

var ui :GameplayUi

func setup_ui():
	ui = preload("res://menu/gameplay/ui/ui.tscn").instance()
	ui.name = "ui"
	add_child(ui)
	
	ui.movable_camera_ui.connect("camera_down", self, "_on_camera_down_zoom_in")
	ui.movable_camera_ui.connect("camera_up", self, "_on_camera_up_exiting")
	
	use_grand_camera()
	
func _on_camera_down_zoom_in():
	if current_cam != movable_camera_room:
		return
		
	var tile = get_closes_zoomable_battle_map(selection.translation)
	if tile == null:
		return
		
	set_current_battle_map(tile.id)
		
func _on_camera_up_exiting():
	if current_cam != movable_camera_battle:
		return
		
	hide_battle_map()
	use_grand_camera()

func use_grand_camera():
	movable_camera_battle.set_as_current(false)
	movable_camera_room.set_as_current(true)
	
	current_cam = movable_camera_room
	#current_cam.translation = Vector3(0, 5, 2) + grand_map.global_position
	
	var map_size = grand_map_manifest_data.map_size
	ui.movable_camera_ui.target = movable_camera_room
	ui.movable_camera_ui.min_zoom = 1
	ui.movable_camera_ui.max_zoom = 5
	ui.movable_camera_ui.camera_limit_bound = Vector3( map_size + 1, 0, map_size + 3)
	ui.movable_camera_ui.center_pos = grand_map.global_position
	
	ground_table.visible = false
	grand_map.visible = true
	
func use_battle_camera(center :Vector3):
	movable_camera_room.set_as_current(false)
	movable_camera_battle.set_as_current(true)
	
	current_cam = movable_camera_battle
	current_cam.translation = Vector3(0, 6, 2) + center
	
	var map_size = grand_map_manifest_data.battle_map_size
	ui.movable_camera_ui.target = movable_camera_battle
	ui.movable_camera_ui.min_zoom = 2
	ui.movable_camera_ui.max_zoom = 7
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
	match current_cam:
		movable_camera_room:
			var tile = grand_map.get_closes_tile(pos)
			
			# test squad
			var p :PoolVector2Array = grand_map.get_navigation(squad.current_tile, tile.id)
			var paths :Array = []
			for id in p:
				var pos3 = grand_map.get_tile_instance(id).global_position
				paths.append(BaseTileUnit.TileUnitPath.new(id, pos3))
				
			squad.paths = paths
			
		movable_camera_battle:
			var tile = current_battle_map.get_closes_tile(pos)
			selection.translation = tile.pos + current_battle_map.global_position
			selection.visible = true

	
##########################################  ############################################

var selection :Spatial

func setup_selection():
	selection = preload("res://assets/tile_highlight/selection.tscn").instance()
	selection.name = "selection"
	add_child(selection)
	
	selection.visible = false
	
func show_tile_by_ray():
	if current_cam != movable_camera_room:
		return
		
	var cam_pos = current_cam.global_position + Vector3.FORWARD
	var from = cam_pos + (Vector3.UP * 20)
	var to = cam_pos + (Vector3.DOWN * 10)
	
	var result :Dictionary = get_viewport().get_world().direct_space_state.intersect_ray(from, to, [], 4, false, true)
	if result.empty():
		return
		
	var tile = get_closes_zoomable_battle_map(result["position"])
	if tile == null:
		return
		
	if not battle_map_holder.has(tile.id):
		return
	
	selection.visible = true
	selection.translation = tile.pos + grand_map.global_position
	
	ui.battle_map_name.text = grand_map_manifest_data.battle_map_names[tile.id]
	
func create_transit_point(tile_id :Vector2, battle_map :BaseTileMap):
	var battle_map_adjacent = []
	
	var adjacent = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS,
		Vector2.ZERO, 1
	)
	for id in adjacent:
		if grand_map.is_nav_enable(id + tile_id):
			battle_map_adjacent.append(id)
			
	for id in battle_map_adjacent:
		var pos_point = id * grand_map_manifest_data.battle_map_size
		var t = preload("res://scenes/tile_objects/battle/transit_point.tscn").instance()
		battle_map.add_child(t)
		t.set_label("Go to %s" % grand_map_manifest_data.battle_map_names[id + tile_id])
		t.translation = battle_map.get_tile_instance(pos_point).translation
		
##########################################  ############################################

var ground_table :Sprite3D
var battle_map_pos :Dictionary = {} # [Vector2 : Vector3]
var battle_map_holder :Dictionary = {} # [Vector2 : BattleMap]
var zoomable_battle_map :Dictionary = {} # [Vector2 : TileMapData (grand map)]

var current_battle_map :BaseTileMap

func setup_battle_map():
	ground_table = preload("res://assets/background/ground.tscn").instance()
	ground_table.name = "ground_table"
	add_child(ground_table)
	
	var map_keys = battle_map_datas.keys()
	var poses = Utils.generate_positions(map_keys.size(), 40, 50)
	
	var idx = 0
	for i in map_keys:
		battle_map_pos[i] = poses[idx]
		idx += 1
		
	# spawn battle map localy
	# for bases and point
	var mission = grand_map_mission_data
	for id in mission.bases + mission.points:
		_spawn_battle_map(id, battle_map_pos[id])
		
	# demo
	# check if all battle map can be spawned
#	for id in battle_map_datas.keys():
#		_spawn_battle_map(id, battle_map_pos[id])
		
remotesync func _spawn_battle_map(id :Vector2, at :Vector3):
	if battle_map_holder.has(id):
		return
		
	var manif = grand_map_manifest_data
	var battle_map = preload("res://scenes/maps/battle/battle_map.tscn").instance()
	battle_map.connect("on_map_ready", self, "_on_battle_map_ready", [id, battle_map])
	battle_map.name = manif.battle_map_names[id]
	add_child(battle_map)
	
	battle_map.translation = at
	battle_map.generate_from_data(battle_map_datas[id])
	battle_map_holder[id] = battle_map
	battle_map.visible = false
	
	for tile in grand_map_data.tiles:
		if tile.id == id:
			zoomable_battle_map[id] = tile
			return
	
func get_closes_zoomable_battle_map(from :Vector3) -> TileMapData:
	var tiles :Array = zoomable_battle_map.values()
	if tiles.empty():
		return null
		
	var current :TileMapData = tiles[0]
	var modifier :Vector3 = grand_map.global_position
	for i in tiles:
		if i == current:
			continue
			
		var dist_1 = (current.pos + modifier).distance_squared_to(from)
		var dist_2 = (i.pos + modifier).distance_squared_to(from)
		if dist_2 < dist_1:
			current = i
			
	return current # TileMapData
	
func set_current_battle_map(battle_map_id :Vector2):
	current_battle_map = battle_map_holder[battle_map_id]
	current_battle_map.visible = true
	grand_map.visible = false
	
	use_battle_camera(current_battle_map.global_position)
	ground_table.position = current_battle_map.global_position + Vector3(0, -0.4, -1)
	
func hide_battle_map():
	for i in battle_map_holder.values():
		i.visible = false
	
func _on_battle_map_ready(tile_id :Vector2, battle_map :BaseTileMap):
	create_transit_point(tile_id, battle_map)
	
##########################################  ############################################

var squad :BaseTileUnit

remotesync func _spawn_squad(network_id :int, tile_id :Vector2):
	squad = preload("res://scenes/entities/units/squad/squad.tscn").instance()
	squad.name = "test_squad"
	squad.set_network_master(network_id)
	squad.current_tile = tile_id
	squad.connect("on_finish_travel", self ,"_on_squad_finish_travel")
	squad.connect("on_current_tile_updated", self, "_on_squad_current_tile_updated")
	add_child(squad)
	
	squad.translation = grand_map.get_tile_instance(tile_id).global_position

func _on_squad_current_tile_updated(unit :BaseTileUnit, from :Vector2, to :Vector2):
	
	# rule of gameplay, squad cannot contact hq
	# if inside one of active battle map
	unit.visible = not (to in zoomable_battle_map.keys())
	
	print("squad leave : %s and enter : %s" % [from,to])

func _on_squad_finish_travel(unit :BaseTileUnit):
	print("squad finish travel : %s" % unit.current_tile)









