extends Node
class_name BaseGameplay

onready var player :PlayerData = Global.player_data

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
	Global.hide_transition()
	
	var tile_id = Vector2.ZERO
	
	# test squad
	if NetworkLobbyManager.is_server():
		for i in NetworkLobbyManager.get_players():
			var player :NetworkPlayer = i
			var data :PlayerData = PlayerData.new()
			data.from_dictionary(player.extra)
			
			rpc("_spawn_grand_map_squad", 
				player.player_network_unique_id, data.player_id,
				data.player_team, tile_id,
				grand_map.get_tile_instance(tile_id).global_position
			)
########################################## grand map  ############################################

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
		base.set_color(Global.spatial_team_colors[idx])
		idx += 1
		
	for id in grand_map_mission_data.points:
		var point :BaseTileObject = preload("res://scenes/tile_objects/grand/flag_pole.tscn").instance()
		grand_map.add_child(point)
		point.translation = grand_map.get_tile_instance(id).translation
		point.set_color(Global.spatial_team_colors[Global.TEAM_WHITE])
		points[id] = point
		
########################################## camera  ############################################

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
	
	ui.grand_map_overlay_ui.visible = true
	
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
	
	ui.grand_map_overlay_ui.visible = false
	
	ground_table.visible = true
	
########################################## UI  ############################################

var ui :GameplayUi

func setup_ui():
	ui = preload("res://menu/gameplay/ui/ui.tscn").instance()
	ui.name = "ui"
	add_child(ui)
	
	ui.movable_camera_ui.connect("camera_down", self, "_on_camera_down_zoom_in")
	ui.movable_camera_ui.connect("camera_up", self, "_on_camera_up_exiting")
	
	ui.spawned_squad = spawned_squad
	ui.squad_positions = squad_positions
	
	use_grand_camera()
	
func _on_camera_down_zoom_in():
	if current_cam != movable_camera_room:
		return
		
	var tile = get_closes_zoomable_battle_map(selection_battle_map_indicator.translation)
	if tile == null:
		return
		
	set_current_battle_map(tile.id)
		
func _on_camera_up_exiting():
	if current_cam != movable_camera_battle:
		return
		
	hide_battle_map()
	use_grand_camera()

##########################################  floor interaction  ############################################

var clickable_floor :ClickableFloor

func setup_clickable_floor():
	clickable_floor = preload("res://assets/clickable_floor/clickable_floor.tscn").instance()
	clickable_floor.connect("on_floor_clicked", self, "_on_floor_clicked")
	clickable_floor.name = "clickable_floor"
	add_child(clickable_floor)

func _on_floor_clicked(pos :Vector3):
	match current_cam:
		movable_camera_room:
			on_grandmap_clicked_input(grand_map.get_closes_tile(pos))
			
		movable_camera_battle:
			on_battle_map_clicked_input(current_battle_map.get_closes_tile(pos))
			
func on_grandmap_clicked_input(tile :TileMapData):
	if is_instance_valid(ui.selected_squad):
		var unit :BaseTileUnit = ui.selected_squad
		unit.set_paths(get_tile_path(grand_map, unit.current_tile, tile.id))
		show_feedback_move_order(tile.pos + grand_map.global_position)
		return
		
func on_battle_map_clicked_input(tile :TileMapData):
	if is_instance_valid(ui.selected_battle_map_unit):
		var unit :BaseTileUnit = ui.selected_battle_map_unit
		unit.set_paths(get_tile_path(current_battle_map, unit.current_tile, tile.id))
		show_feedback_move_order(tile.pos + current_battle_map.global_position)
		
########################################## selection tile ############################################

var tile_selection :Spatial
var selection_battle_map_indicator :Spatial
var move_order_tap :Spatial

func setup_selection():
	tile_selection = preload("res://assets/tile_highlight/selection.tscn").instance()
	tile_selection.name = "tile_selection"
	add_child(tile_selection)

	selection_battle_map_indicator = preload("res://assets/tile_highlight/got_to_here.tscn").instance()
	selection_battle_map_indicator.name = "selection_battle_map_indicator"
	add_child(selection_battle_map_indicator)
	
	move_order_tap = preload("res://assets/tile_highlight/circle_selection.tscn").instance()
	move_order_tap.name = "move_order_tap"
	add_child(move_order_tap)
	
	tile_selection.visible = false
	selection_battle_map_indicator.visible = false
	move_order_tap.visible = false
	
func show_feedback_move_order(at :Vector3):
	move_order_tap.visible = true
	move_order_tap.translation = at
	move_order_tap.tap()
	
func show_tile_selection(at :Vector3):
	tile_selection.visible = true
	tile_selection.translation = at
	
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
	
	selection_battle_map_indicator.visible = true
	selection_battle_map_indicator.translation = tile.pos + grand_map.global_position
	
	ui.battle_map_name.text = grand_map_manifest_data.battle_map_names[tile.id]
	
########################################## battle map ############################################

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
	battle_map.name = "battle_map_%s" % id
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
	ground_table.translation = current_battle_map.global_position + Vector3(0, -0.4, -1)
	
func hide_battle_map():
	for i in battle_map_holder.values():
		i.visible = false
	
func _on_battle_map_ready(tile_id :Vector2, battle_map :BaseTileMap):
	create_transit_point(tile_id, battle_map)
	
########################################## battle map transit point ############################################

# to despawn unit in battle map to enter back at grand map
# use BattleMapTransitPoint.grand_map_tile_id to move unit to it
var transit_points :Dictionary = {} # { Vector2 : [ BattleMapTransitPoint ] }

func create_transit_point(tile_id :Vector2, battle_map :BaseTileMap):
	for dir in TileMapUtils.ARROW_DIRECTIONS:
		var grand_map_tile_id :Vector2 = dir + tile_id
		if not grand_map.is_nav_enable(grand_map_tile_id):
			continue
			
		var pos_point = dir * grand_map_manifest_data.battle_map_size
		var battle_map_name :String = grand_map_manifest_data.battle_map_names[grand_map_tile_id]
		var t :BattleMapTransitPoint = preload("res://scenes/tile_objects/battle/transit_point.tscn").instance()
		t.battle_map_tile_id = pos_point
		t.grand_map_tile_id = grand_map_tile_id
		t.name = "tp_%s" % battle_map_name
		battle_map.add_child(t)
		t.set_label("Go to %s" % battle_map_name)
		t.translation = battle_map.get_tile_instance(pos_point).translation
		
		if not transit_points.has(tile_id):
			transit_points[tile_id] = []
		
		transit_points[tile_id].append(t)
		
# to spawn unit entering battle map
# find current tile id and find BattleMapTransitPoint.grand_map_tile_id unit comming from
func get_transit_point_spawn_point(current_tile_id :Vector2, from_tile_id :Vector2) -> BattleMapTransitPoint:
	if not transit_points.has(current_tile_id):
		return null
		
	for i in transit_points[current_tile_id]:
		var point :BattleMapTransitPoint = i
		if point.grand_map_tile_id == from_tile_id:
			return point
		
	return null
	
########################################## grand map squad ############################################

var squad_positions :Dictionary = {} # [Vector2 : [ BaseTileUnit ] ]
var spawned_squad :Array = []

# this is for spotting mechanic
var grand_map_watchlist_position :Array = []

remotesync func _spawn_grand_map_squad(network_id :int, player_id :String, team :int, tile_id :Vector2, at :Vector3):
	var squad = preload("res://scenes/entities/units/squad/infatry_squad.tscn").instance()
	squad.player_id = player_id
	squad.name = "squad_%s" % player_id
	squad.set_network_master(network_id)
	squad.current_tile = tile_id
	squad.team = team
	squad.overlay_ui = ui.grand_map_overlay_ui.get_path()
	squad.is_selectable = (player_id == player.player_id)
	squad.squad_icon = preload("res://assets/user_interface/icons/floating_icon/infantry.png")
	squad.connect("on_finish_travel", self ,"_on_grand_map_squad_finish_travel")
	squad.connect("on_current_tile_updated", self, "_on_grand_map_squad_current_tile_updated")
	squad.connect("on_unit_selected", self, "_on_grand_map_squad_selected")
	squad.connect("on_unit_spotted", self, "_on_grand_map_squad_spotted")
	add_child(squad)
	
	squad.set_spotted(team != player.player_team)
	squad.set_hidden(false)
	squad.translation = at
	
	for i in 4:
		var infantry:Infantry  = preload("res://scenes/entities/units/infantry/infantry.tscn").instance()
		infantry.player_id = player_id
		infantry.name = "infantry_%s_%s" % [squad.name, i]
		infantry.set_network_master(network_id)
		infantry.current_tile = Vector2.ZERO
		infantry.team = team
		infantry.is_selectable = (player_id == player.player_id)
		infantry.connect("on_unit_selected", self, "_on_battle_map_infantry_selected")
		add_child(infantry)
		
		infantry.translation = Vector3(-100, -100, -100)
		infantry.visible = false
		infantry.set_hidden(false)
		infantry.set_spotted(true)
		
		squad.members.append(infantry)
	
	on_grand_map_squad_spawned(squad)
	
func on_grand_map_squad_spawned(unit :BaseTileUnit):
	if not squad_positions.has(unit.current_tile):
		squad_positions[unit.current_tile] = []
		
	squad_positions[unit.current_tile].append(unit)
	
	if unit.player_id == player.player_id:
		spawned_squad.append(unit)
		
	if unit.team != player.player_team:
		unit.set_spotted(false)
		
func _on_grand_map_squad_selected(unit :BaseTileUnit, selected :bool):
	if is_instance_valid(ui.selected_squad):
		ui.selected_squad.set_selected(false)
		
	ui.selected_squad = unit if selected else null
	
func _on_battle_map_infantry_selected(unit :BaseTileUnit, selected :bool):
	if is_instance_valid(ui.selected_battle_map_unit):
		ui.selected_battle_map_unit.set_selected(false)
		
	ui.selected_battle_map_unit = unit if selected else null
	
	
func _on_grand_map_squad_current_tile_updated(unit :BaseTileUnit, from :Vector2, to :Vector2):
	# form of position tracking on map
	# this will tied to spotting mechanic
	if squad_positions.has(from):
		squad_positions[from].erase(unit)
		
	if not squad_positions.has(to):
		squad_positions[to] = []
		
	squad_positions[to].append(unit)
	
	if unit.team != player.player_team:
		on_enemy_grand_map_squad_moving(unit, from, to)
		
	else:
		on_team_grand_map_squad_moving(unit, from, to)

func _on_grand_map_squad_finish_travel(unit :BaseTileUnit, from_tile_id :Vector2, current_tile_id :Vector2):
	# rule of gameplay, squad cannot contact hq
	# if inside one of active battle map
	# apply to all unit sides
	var in_zone = current_tile_id in zoomable_battle_map.keys()
	unit.set_hidden(in_zone)
	
	if in_zone:
		# if currently selected squad then it became unselected
		if (ui.selected_squad == unit):
			ui.selected_squad.set_selected(false)
			ui.selected_squad = null
		
		rpc("_on_grand_map_squad_enter_battle_map", unit.get_path(), from_tile_id, current_tile_id)
	
func _on_grand_map_squad_spotted(_unit :BaseTileUnit):
	Global.unit_responded(RadioChatters.ENEMY_SPOTTED, player.player_team)
	
# tell all that this squad are entering
# battle map
remotesync func _on_grand_map_squad_enter_battle_map(unit :NodePath, from_tile_id :Vector2, current_tile_id :Vector2):
	on_grand_map_squad_enter_battle_map(get_node_or_null(unit), from_tile_id, current_tile_id )
	
func on_grand_map_squad_enter_battle_map(unit :BaseTileUnit, from_tile_id :Vector2, current_tile_id :Vector2):
	if unit is BaseSquad:
		var point :BattleMapTransitPoint = get_transit_point_spawn_point(current_tile_id, from_tile_id)
		for member in unit.members:
			var infantry :Infantry = member
			infantry.current_tile = point.battle_map_tile_id
			infantry.translation = point.global_position
			infantry.visible = true
	
func on_team_grand_map_squad_moving(_unit :BaseTileUnit, from :Vector2, to :Vector2):
	
	# pasive spotting
	if not grand_map_watchlist_position.has(to):
		grand_map_watchlist_position.append(to)
		
	if grand_map_watchlist_position.has(from):
		grand_map_watchlist_position.erase(from)
		
	var in_zone = to in zoomable_battle_map.keys()
	if in_zone:
		return
		
	# for active spotting
	# when entering check if any enemy in it
	# set spot if true
	if not squad_positions[to].empty():
		for i in squad_positions[to]:
			if i.team != player.player_team:
				i.set_spotted(true)
		
func on_enemy_grand_map_squad_moving(unit :BaseTileUnit, _from :Vector2, to :Vector2):
	var in_zone = to in zoomable_battle_map.keys()
	if in_zone:
		return
		
	# pasive spotting
	# enemy enter one of the watch list position
	# set spotted true, only from POV of spotter player
	if to in grand_map_watchlist_position:
		unit.set_spotted(true)
		Global.unit_responded(RadioChatters.ENEMY_SPOTTED, player.player_team)
		
	else:
		unit.set_spotted(false)

########################################## utils ############################################

func get_tile_path(m :BaseTileMap, from :Vector2, to :Vector2, _is_air :bool = false) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = m.get_navigation(from, to, [], _is_air)
	for id in p:
		var pos3 = m.get_tile_instance(id).global_position
		paths.append(BaseTileUnit.TileUnitPath.new(id, pos3))
		
	return paths
