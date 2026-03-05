extends Node
class_name BaseGameplay

onready var player :PlayerData = Global.player_data

func _ready():
	NetworkLobbyManager.connect("all_player_ready", self, "_on_all_player_ready")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	setup_ambient_audio()
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
#		if is_instance_valid(ui.selected_battle_map_unit):
#			var speed = ui.selected_battle_map_unit.speed
#			var pos = ui.selected_battle_map_unit.global_position
#			var cam_y = current_cam.translation.y
#			pos = pos + (Vector3.BACK * (cam_y - pos.y - 1))
#			var new_pos = Vector3(pos.x,cam_y,pos.z)
#			current_cam.translation = current_cam.translation.linear_interpolate(new_pos, speed * _delta)
			
			
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
	
	# test squad
#	if NetworkLobbyManager.is_server():
#		for i in NetworkLobbyManager.get_players():
#			yield(get_tree().create_timer(1),"timeout")
#			var p :NetworkPlayer = i
#			var data :PlayerData = PlayerData.new()
#			data.from_dictionary(p.extra)
#
#	spawn_dummy(bases, nva_riflement)
########################################## ambient sound  ############################################

var grand_map_ambient :AudioStreamPlayer
var battle_map_ambient :AudioStreamPlayer

var grand_map_ambient_pos :float = 0.0
var battle_map_ambient_pos :float = 0.0

func setup_ambient_audio():
	grand_map_ambient = AudioStreamPlayer.new()
	grand_map_ambient.volume_db = -12.0
	grand_map_ambient.stream = preload("res://assets/sounds/misc/office_ambient.ogg")
	add_child(grand_map_ambient)
	
	battle_map_ambient = AudioStreamPlayer.new()
	battle_map_ambient.volume_db = -12.0
	battle_map_ambient.stream = preload("res://assets/sounds/misc/jungle_ambient.ogg")
	add_child(battle_map_ambient)
	
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
		base.set_color(Global.get_base_material_color(idx, player.player_team))
		idx += 1
		
	for id in grand_map_mission_data.points:
		var point :BaseTileObject = preload("res://scenes/tile_objects/grand/flag_pole.tscn").instance()
		grand_map.add_child(point)
		point.translation = grand_map.get_tile_instance(id).translation
		point.set_color(MaterialsIndex.team_colors[0])
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
	ui.movable_camera_ui.detect_in_out = true
	
	ui.grand_map_overlay_ui.visible = true
	ui.battle_map_overlay_ui.visible = false
	
	ground_table.visible = false
	grand_map.visible = true
	
	battle_map_ambient_pos = battle_map_ambient.get_playback_position()
	battle_map_ambient.stop()
	grand_map_ambient.play(grand_map_ambient_pos)
	
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
	ui.battle_map_overlay_ui.visible = true
	
	ground_table.visible = true
	
	grand_map_ambient_pos = grand_map_ambient.get_playback_position()
	grand_map_ambient.stop()
	battle_map_ambient.play(battle_map_ambient_pos)
	
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
	
	ui.spawn_infantry.connect("pressed", self, "_on_spawn_infantry")
	ui.spawn_heli.connect("pressed", self, "_on_spawn_heli_press")
	ui.spawn_bot_infantry.connect("pressed", self, "_on_spawn_bot_infantry")
	
	use_grand_camera()
	
func _on_spawn_infantry():
	var macv_riflement = preload("res://data/unit_data/infantry/macv_riflement.tres")
	var nva_riflement = preload("res://data/unit_data/infantry/nva_riflement.tres")
	var bases = grand_map_mission_data.bases
	var tile = bases[player.player_team - 1]
	
	var infantry_squad :InfantrySquadData = preload("res://data/unit_data/squad/infantry_squad.tres").duplicate()
	infantry_squad.player_network_id = player.player_network_id
	infantry_squad.player_id = player.player_id
	infantry_squad.unit_name = "squad_infantry_%s" % Utils.create_unique_id()
	infantry_squad.team = player.player_team
	infantry_squad.current_tile = tile
	infantry_squad.position = grand_map.get_tile_instance(tile).global_position
	infantry_squad.unit_voice = player.player_team
	
	infantry_squad.members = []
	var number = 4 if player.player_team == 1 else 6
	for i in number:
		
		var stats :UnitStatsData = UnitStatsData.new()
		stats.randomize_stats()
		
		var infantry :InfantryData = (nva_riflement if player.player_team != 1 else macv_riflement).duplicate()
		infantry.player_network_id = player.player_network_id
		infantry.player_id = player.player_id
		infantry.unit_name = "infantry_%s_%s" % [Utils.create_unique_id(), i]
		infantry.team = player.player_team
		infantry.current_tile = Vector2.ZERO
		infantry.speed = 1.3
		infantry.position = Vector3.ZERO
		infantry.scene_index = 0
		infantry_squad.members.append(infantry)
		
		infantry.modified_max_hp = stats.get_max_hp(8)
		infantry.modified_speed = stats.get_speed_multiplier()
		infantry.stats = stats
		
		if player.player_team == 1:
			var style = [0,1,2]
			var skin = [0, 1]
			var hats = [0, 1, 2, 4]
			var bags = [0,1,2,3,9]
			var vests = [0, 1, 4]
			
			var black_potrait = [1, 2, 4, 6]
			var white_potrait = [0, 3, 5, 7, 8, 9]
			
			stats.soldier_name = SoldierNames.get_random_us_name()
			stats.soldier_weapon_image_index = 0
			
			infantry.skin_material_index = skin[randi() % 2]
			stats.soldier_potrait_index = black_potrait[randi() % 4] if infantry.skin_material_index == 1 else white_potrait[randi() % 6]
			
			infantry.hat_scene_index = hats[randi() % 4]
			infantry.bag_scene_index = 4 if (i == 0) else bags[randi() % 5]
			infantry.vest_scene_index = vests[randi() % 3]
			infantry.uniform_style = style[randi() % 3]
			
		else:
			stats.soldier_name = SoldierNames.get_random_viet_name()
			stats.soldier_potrait_index = int(rand_range(25, 34))
			stats.soldier_weapon_image_index = 1
			
	rpc("_spawn_grand_map_squad", infantry_squad.to_bytes())
	
func _on_spawn_heli_press():
	var bases = grand_map_mission_data.bases
	var tile = bases[player.player_team - 1]
	var vehicle_squad :VehicleSquadData = preload("res://data/unit_data/squad/vehicle_squad.tres").duplicate()
	vehicle_squad.player_network_id = player.player_network_id
	vehicle_squad.player_id = player.player_id
	vehicle_squad.unit_name = "squad_vehicle_%s" % Utils.create_unique_id()
	vehicle_squad.team = player.player_team
	vehicle_squad.current_tile = tile
	vehicle_squad.position = grand_map.get_tile_instance(tile).global_position
	vehicle_squad.unit_voice = player.player_team
	
	var stats :UnitStatsData = UnitStatsData.new()
	stats.randomize_stats()
	stats.soldier_name = SoldierNames.get_random_us_name()
	stats.soldier_weapon_image_index = 0
	stats.soldier_potrait_index = int(rand_range(20, 24))
	
	var vehicle = preload("res://data/unit_data/vehicle/uh1d.tres").duplicate()
	vehicle.player_network_id = player.player_network_id
	vehicle.player_id = player.player_id
	vehicle.unit_name = "vehicle_%s" % Utils.create_unique_id()
	vehicle.team = player.player_team
	vehicle.current_tile = Vector2.ZERO
	vehicle.position = Vector3.ZERO
	vehicle.stats = stats
	
	vehicle_squad.vehicle = vehicle
	
	rpc("_spawn_grand_map_vehicle", vehicle_squad.to_bytes())
	
func _on_spawn_bot_infantry():
	var tile_id :Vector2 = grand_map_mission_data.points[0]
	
	var id = "BOT_1"
	var infantry_squad :InfantrySquadData = preload("res://data/unit_data/squad/infantry_squad.tres").duplicate()
	infantry_squad.player_network_id = 1
	infantry_squad.player_id = id
	infantry_squad.unit_name = "squad_infantry_%s" % Utils.create_unique_id()
	infantry_squad.team = 3
	infantry_squad.current_tile = tile_id
	infantry_squad.position = grand_map.get_tile_instance(tile_id).global_position
	infantry_squad.unit_voice = 2
	
	infantry_squad.members = []
	for i in 6:
		var stats :UnitStatsData = UnitStatsData.new()
		stats.soldier_name = SoldierNames.get_random_viet_name()
		stats.soldier_potrait_index = int(rand_range(10, 19))
		stats.soldier_weapon_image_index = 1
		stats.randomize_stats()
		
		var infantry :InfantryData = preload("res://data/unit_data/infantry/nva_riflement.tres").duplicate()
		infantry.player_network_id = 1
		infantry.player_id = id
		infantry.unit_name = "infantry_%s_%s" % [Utils.create_unique_id(), i]
		infantry.team = 3
		infantry.current_tile = Vector2.ZERO
		infantry.speed = 1.3
		infantry.position = Vector3.ZERO
		infantry.scene_index = 0
		
		infantry.modified_max_hp = stats.get_max_hp(8)
		infantry.modified_speed = stats.get_speed_multiplier()
		infantry.stats = stats
		
		infantry_squad.members.append(infantry)
		
	rpc("_spawn_grand_map_squad", infantry_squad.to_bytes())
	
func _on_camera_down_zoom_in():
	if current_cam != movable_camera_room:
		return
		
	var tile = get_closes_zoomable_battle_map(selection_battle_map_indicator.translation)
	if tile == null:
		return
		
	set_current_battle_map(tile.id)
	
	if is_instance_valid(ui.selected_squad):
		ui.selected_squad.set_selected(false)
		ui.selected_squad = null
	
func _on_camera_up_exiting():
	if current_cam != movable_camera_battle:
		return
		
	if is_instance_valid(ui.selected_battle_map_unit):
		return
		
	use_grand_camera()
	hide_battle_map()
	
#	if is_instance_valid(ui.selected_battle_map_unit):
#		ui.selected_battle_map_unit.set_selected(false)
#		ui.selected_battle_map_unit = null

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
		unit.tile_map = grand_map
		unit.move_to(tile.id)
		Global.unit_responded(RadioChatters.COMMAND_ACKNOWLEDGEMENT,unit.unit_voice)
		show_feedback_move_order(tile.pos + grand_map.global_position)
		
func on_battle_map_clicked_input(tile :TileMapData):
	if is_instance_valid(ui.selected_battle_map_unit):
		var unit :BaseTileUnit = ui.selected_battle_map_unit
		unit.tile_map = current_battle_map
		unit.attack_move = false # true
		unit.move_to(tile.id)
		Global.unit_responded(RadioChatters.COMMAND_ACKNOWLEDGEMENT,unit.unit_voice)
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
	
	var battle_map = preload("res://scenes/maps/battle/battle_map.tscn").instance()
	battle_map.connect("on_map_ready", self, "_on_battle_map_ready", [id, battle_map])
	battle_map.name = "battle_map_%s" % id
	add_child(battle_map)
	
	battle_map.translation = at
	battle_map.generate_from_data(battle_map_datas[id])
	battle_map_holder[id] = battle_map
	battle_map.visible = false
	
	if not battle_map_unit_positions.has(battle_map):
		battle_map_unit_positions[battle_map] = {}
		
	# initiated empty positions
	var battle_map_size :int = grand_map_manifest_data.battle_map_size
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		Vector2.ZERO,
		battle_map_size
	)
	for id in tiles:
		battle_map_unit_positions[battle_map][id] = []
			
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
	
	if dead_bodies_holder.has(current_battle_map):
		for i in dead_bodies_holder[current_battle_map]:
			i.visible = true
	
func hide_battle_map():
	for i in battle_map_holder.values():
		i.visible = false
		
		if dead_bodies_holder.has(i):
			for ded in dead_bodies_holder[i]:
				ded.visible = false
				
func _on_battle_map_ready(tile_id :Vector2, battle_map :BaseTileMap):
	create_transit_point(tile_id, battle_map)
	
	var mission = grand_map_mission_data
	if tile_id in mission.points:
		var index :int = mission.points.find(tile_id)
		spawn_battle_map_capture_point(tile_id, battle_map,index)
		
	if tile_id in mission.bases:
		var index :int = mission.bases.find(tile_id)
		spawn_battle_map_base_building(tile_id, battle_map, index)
		
	battle_map.visible = false
	
########################################## battle map capture point ############################################

var team_listen_radio :int

func spawn_battle_map_capture_point(tile_id :Vector2, battle_map :BaseTileMap, index:int):
	var props :Spatial
	if index == 0:
		props = preload("res://scenes/entities/props/hidden_cache/hidden_cache_intel.tscn").instance()
		battle_map.add_child(props)
		
		battle_map.enable_nav(Vector2.UP + Vector2.LEFT, false)
		battle_map.enable_nav(Vector2.UP + Vector2.RIGHT, false)
		battle_map.enable_nav(Vector2.DOWN + Vector2.LEFT, false)
		battle_map.enable_nav(Vector2.DOWN + Vector2.RIGHT, false)
		
		props.listening_spot.connect("on_listening", self, "_on_listening_post_listen")
		
	elif index == 1:
		props = preload("res://scenes/entities/props/hidden_cache/hidden_cache_medkit.tscn").instance()
		
		# resource is private/local not shared
		# event at same team, failed manage you own
		# your fault
		props.player_id = player.player_id
		battle_map.add_child(props)
		
	else:
		props = preload("res://scenes/entities/props/hidden_cache/hidden_cache_ammo.tscn").instance()
		
		# resource is private/local not shared
		# event at same team, failed manage you own
		# your fault
		props.player_id = player.player_id
		battle_map.add_child(props)
	
	props.global_position = battle_map.get_tile_instance(Vector2.ZERO).global_position
	battle_map.enable_nav(Vector2.UP, false)
	battle_map.enable_nav(Vector2.LEFT, false)
	battle_map.enable_nav(Vector2.RIGHT, false)
	
func spawn_battle_map_base_building(tile_id :Vector2, battle_map :BaseTileMap, index:int):
	var field_base :Spatial
	if index == 0:
		field_base = preload("res://scenes/entities/props/base_camp/field_base.tscn").instance()
		
	else:
		field_base = preload("res://scenes/entities/props/base_camp/village_base.tscn").instance()
	
	# resource is private/local not shared
	# event at same team, failed manage you own
	# your fault
	field_base.player_id = player.player_id
	
	battle_map.add_child(field_base)
	
	# if player team id same as base (index + 1) = team id
	# register the resource to game ui
	if player.player_team == (index + 1):
		ui.game_resource.resource_spots.append_array(field_base.get_spots())
	
	field_base.translation = battle_map.get_tile_instance(Vector2.ZERO).translation
	var disable_tiles = [
		Vector2.ZERO, 
		Vector2(2,-2), Vector2(1,-2),
		Vector2(2,-1), Vector2(-2,2),
		Vector2(-1,2), Vector2(-2,1),
		Vector2(-1,-2), Vector2(-2,-1),
		Vector2(-2,-2), Vector2(2,2),
		Vector2(2,1), Vector2(1,2),
	]
	for i in disable_tiles:
		battle_map.enable_nav(i, false)
	
func _on_listening_post_listen(by_team :int):
	team_listen_radio = by_team
	
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
		t.connect("transit_point_click", self, "_on_transit_point_click")
		t.battle_map = battle_map
		t.battle_map_tile_id = pos_point
		t.grand_map_tile_id = grand_map_tile_id
		t.name = "tp_%s" % battle_map_name
		battle_map.add_child(t)
		t.set_label("Go to %s" % battle_map_name)
		t.translation = battle_map.get_tile_instance(pos_point).translation
		
		if not transit_points.has(tile_id):
			transit_points[tile_id] = []
		
		transit_points[tile_id].append(t)
		
func _on_transit_point_click(t :BattleMapTransitPoint):
	if is_instance_valid(ui.selected_battle_map_unit):
		order_squad_to_exit_battle_map(ui.selected_battle_map_unit.squad, t.battle_map_tile_id, t.grand_map_tile_id)
		ui.selected_battle_map_unit = null
		
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
	
func create_entry_positions(from_tile_id :Vector2, current_tile_id :Vector2, is_air :bool = false) -> Array:
	var entry_positions :Array = []
	var map_size :int = grand_map_manifest_data.battle_map_size
	var point :BattleMapTransitPoint = get_transit_point_spawn_point(
		current_tile_id, from_tile_id
	)
	var positions :Array
	var point_battle_map :BaseTileMap
	var battle_map_tile_id :Vector2 # for fallback
	
	# simplified LOL
	if is_air:
		battle_map_tile_id = current_tile_id.direction_to(from_tile_id) * map_size
		return [[battle_map_tile_id], battle_map_holder[current_tile_id], Vector2.ZERO]
	
	# for case if squad enter
	# but no entry point found from direction
	# of that squad entering
	# NOT USED NOW
	if point == null:
		battle_map_tile_id = from_tile_id.direction_to(current_tile_id) * map_size
		point_battle_map = battle_map_holder[current_tile_id]
		positions = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), battle_map_tile_id, 2)
		
	else:
		battle_map_tile_id = point.battle_map_tile_id
		point_battle_map = point.battle_map
		positions = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), battle_map_tile_id, 2)
		
	for id in positions:
		if not point_battle_map.has_tile(id):
			continue
			
		if point_battle_map.is_nav_enable(id):
			entry_positions.append(id)
			
	return [entry_positions, point_battle_map, battle_map_tile_id]
	
########################################## grand map squad ############################################

var squad_positions :Dictionary = {} # [Vector2 : [ BaseTileUnit ] ]
var spawned_squad :Array = [] # for tracking purposes

# this is for spotting mechanic
var grand_map_watchlist_position :Array = []

remotesync func _spawn_grand_map_squad(bytes :PoolByteArray):
	var squad :InfantrySquadData = InfantrySquadData.new()
	squad.from_bytes(bytes)
	
	squad.color = Global.get_team_color(
		squad.player_id, squad.team, player.player_id, player.player_team
	)
	squad.team_color_material_index = Global.get_team_material_color_index(
		squad.player_id, squad.team, player.player_id, player.player_team
	)
	for i in squad.members:
		var infantry :InfantryData = i
		infantry.color = squad.color
		infantry.team_color_material_index = squad.team_color_material_index
	
	var infantry_squad :InfantrySquad = squad.spawn(
		player, self, ui.grand_map_overlay_ui.get_path(), movable_camera_room.camera.get_path()
	)
	
	infantry_squad.connect("on_finish_travel", self ,"_on_grand_map_squad_finish_travel")
	infantry_squad.connect("on_current_tile_updated", self, "_on_grand_map_squad_current_tile_updated")
	infantry_squad.connect("on_unit_clicked", self, "_on_grand_map_squad_clicked")
	infantry_squad.connect("on_squad_task_exit_battle_map", self, "_on_grand_map_squad_task_exit_battle_map")
	infantry_squad.connect("on_infatry_squad_task_enter_vehicle", self, "_on_grand_map_infatry_squad_task_enter_vehicle")
	infantry_squad.connect("on_infantry_squad_member_died", self, "_on_grand_map_infantry_squad_member_died")
	infantry_squad.connect("on_squad_destroyed", self, "_on_grand_map_squad_squad_destroyed")
	
	# connect signal after set_spotted function called
	# if not,it will trigger to emit on_unit_spotted
	infantry_squad.connect("on_unit_spotted", self, "_on_grand_map_squad_spotted")
	
	for i in squad.members:
		var inf :InfantryData = i
		var infantry :Infantry = inf.spawn(
			player, self, ui.battle_map_overlay_ui.get_path(), movable_camera_battle.camera.get_path()
		)
		infantry.squad = infantry_squad
		
		#infantry.connect("on_finish_travel", self ,"_on_battle_map_squad_finish_travel")
		infantry.connect("on_current_tile_updated", self, "_on_battle_map_squad_current_tile_updated")
		infantry.connect("on_unit_clicked", self, "_on_battle_map_infantry_clicked", [inf.stats])
		infantry.connect("on_unit_dead", self, "_on_battle_map_unit_dead")
		infantry.connect("on_unit_dead", infantry_squad, "_on_member_dead")
		infantry_squad.members.append(infantry)
		
	on_grand_map_squad_spawned(infantry_squad)
	
remotesync func _spawn_grand_map_vehicle(bytes :PoolByteArray):
	var squad :VehicleSquadData = VehicleSquadData.new()
	squad.from_bytes(bytes)
	
	squad.color = Global.get_team_color(
		squad.player_id, squad.team, player.player_id, player.player_team
	)
	squad.team_color_material_index = Global.get_team_material_color_index(
		squad.player_id, squad.team, player.player_id, player.player_team
	)
	squad.vehicle.color = squad.color
	squad.vehicle.team_color_material_index = squad.team_color_material_index
	
	var vehicle_squad :VehicleSquad = squad.spawn(
		player, self, ui.grand_map_overlay_ui.get_path(), movable_camera_room.camera.get_path()
	)
	
	vehicle_squad.connect("on_finish_travel", self ,"_on_grand_map_squad_finish_travel")
	vehicle_squad.connect("on_current_tile_updated", self, "_on_grand_map_squad_current_tile_updated")
	vehicle_squad.connect("on_unit_clicked", self, "_on_grand_map_squad_clicked")
	vehicle_squad.connect("on_squad_task_exit_battle_map", self, "_on_grand_map_squad_task_exit_battle_map")
	vehicle_squad.connect("on_squad_destroyed", self, "_on_grand_map_squad_squad_destroyed")
	
	# connect signal after set_spotted function called
	# if not,it will trigger to emit on_unit_spotted
	vehicle_squad.connect("on_unit_spotted", self, "_on_grand_map_squad_spotted")
	
	var vehicle :Vehicle = squad.vehicle.spawn(
		player, self, ui.battle_map_overlay_ui.get_path(), movable_camera_battle.camera.get_path()
	)
	vehicle.squad = vehicle_squad
	vehicle_squad.vehicle = vehicle
	
	#vehicle.connect("on_finish_travel", self ,"_on_battle_map_squad_finish_travel")
	vehicle.connect("on_current_tile_updated", self, "_on_battle_map_squad_current_tile_updated")
	vehicle.connect("on_unit_clicked", self, "_on_battle_map_vehicle_clicked", [squad.vehicle.stats])
	vehicle.connect("on_unit_dead", self, "_on_battle_map_unit_dead")
	vehicle.connect("on_unit_dead", vehicle_squad, "_on_vehicle_dead")
	vehicle.connect("on_vehicle_drop_passenger", self, "_on_battle_map_vehicle_drop_passenger")
	
	on_grand_map_squad_spawned(vehicle_squad)
	
func on_grand_map_squad_spawned(unit :BaseTileUnit):
	var current_tile :Vector2 = unit.current_tile
	if not squad_positions.has(current_tile):
		squad_positions[current_tile] = []
		
	squad_positions[current_tile].append(unit)
	
	spawned_squad.append(unit)
	unit.set_spotted(unit.team != player.player_team)
	unit.set_hidden(current_tile in zoomable_battle_map.keys())
	
	# spawned squad
	# imidiatly enter a battle map
	# call function via non rpc
	on_grand_map_squad_enter_battle_map(unit, unit.current_tile, unit.current_tile)
	
func _on_grand_map_squad_clicked(unit :BaseSquad):
	if is_instance_valid(ui.selected_squad):
		var holder = ui.selected_squad
		ui.selected_squad.set_selected(false)
		ui.selected_squad = null
		
		if holder == unit:
			return
		
	if unit.player_id == player.player_id:
		ui.selected_squad = unit
		ui.selected_squad.set_selected(true)
	
func _on_grand_map_squad_current_tile_updated(unit :BaseTileUnit, from :Vector2, to :Vector2):
	# rule of gameplay, squad  not displayed on map
	# if inside one of active battle map
	unit.set_hidden(to in zoomable_battle_map.keys())
	
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
	# rule of gameplay, squad  not displayed on map
	# if inside one of active battle map
	# if currently selected squad then it became unselected
	if current_tile_id in zoomable_battle_map.keys():
		if (ui.selected_squad == unit):
			ui.selected_squad.set_selected(false)
			ui.selected_squad = null
		
		rpc("_on_grand_map_squad_enter_battle_map", unit.get_path(), from_tile_id, current_tile_id)
	
	if unit.player_id == player.player_id:
		Global.unit_responded(RadioChatters.MOVEMENT, unit.unit_voice)
	
# filter only for enemy unit that spotted, not player
func _on_grand_map_squad_spotted(unit :BaseTileUnit):
	if unit.player_id != player.player_id:
		# do something like sow warning to UI
		# and make player aware these squad are threat
		pass
	
remotesync func _on_grand_map_squad_enter_battle_map(unit :NodePath, from_tile_id :Vector2, current_tile_id :Vector2):
	on_grand_map_squad_enter_battle_map(get_node_or_null(unit), from_tile_id, current_tile_id )
	
func on_grand_map_squad_enter_battle_map(unit :BaseSquad, from_tile_id :Vector2, current_tile_id :Vector2):
	order_squad_to_enter_battle_map(unit, from_tile_id, current_tile_id)
	
func _on_grand_map_squad_task_exit_battle_map(squad :BaseSquad, to_grand_map_id :Vector2):
	squad.tile_map = grand_map
	squad.move_to(to_grand_map_id)
	squad.in_battle_map = false
	
	if squad is VehicleSquad:
		var vehicle :Vehicle = squad.vehicle
		
		# remove from spotting mechanic
		var pos_datas:Array = battle_map_unit_positions[vehicle.tile_map][vehicle.current_tile]
		if pos_datas.has(vehicle):
			pos_datas.erase(vehicle)
			
	if squad is InfantrySquad:
		for i in squad.members:
			var infantry :Infantry = i
			
			# remove from spotting mechanic
			var pos_datas:Array = battle_map_unit_positions[infantry.tile_map][infantry.current_tile]
			if pos_datas.has(infantry):
				pos_datas.erase(infantry)

func _on_grand_map_infantry_squad_member_died(squad :BaseSquad, unit :Infantry):
	if unit.player_id == player.player_id:
		Global.unit_responded(RadioChatters.CASUALTY, unit.unit_voice)
		
func _on_grand_map_squad_squad_destroyed(squad :BaseSquad):
	if squad_positions[squad.current_tile].has(squad):
		squad_positions[squad.current_tile].erase(squad)
		
	if spawned_squad.has(squad):
		spawned_squad.erase(squad)
		
	yield(get_tree(),"idle_frame")
	squad.queue_free()
	
func _on_grand_map_infatry_squad_task_enter_vehicle(squad :InfantrySquad, vehicle):
	if not is_instance_valid(vehicle):
		squad.reasemble_member_around()
		return
		
	for i in squad.members:
		var member :Infantry = i
		
		# remove from spotting mechanic
		var pos_datas:Array = battle_map_unit_positions[member.tile_map][member.current_tile]
		if pos_datas.has(member):
			pos_datas.erase(member)
			
	if vehicle is Vehicle:
		vehicle.take_passenger([squad])
	
func on_team_grand_map_squad_moving(unit :BaseTileUnit, from :Vector2, to :Vector2):
	# check if to is a active battle map tile
	var to_in_zone = to in zoomable_battle_map.keys()
	
	# pasive spotting
	if not grand_map_watchlist_position.has(to):
		grand_map_watchlist_position.append(to)
		
	if grand_map_watchlist_position.has(from):
		grand_map_watchlist_position.erase(from)
		
	# ignore check if to is 
	# a active battle map tile
	if to_in_zone:
		
		# NEW RULE
		# force enter battle map
		# even if just intent to passing by
		# cause performace issue, hold for now
		#if unit.player_id == player.player_id:
			#unit.stop()
			#_on_grand_map_squad_finish_travel(unit, from, to)
			#return
			
		return
		
	# for active spotting
	# when entering check if any enemy in it
	# set spot if true
	if not squad_positions[to].empty():
		for i in squad_positions[to]:
			if i.team != player.player_team:
				i.set_spotted(true)
		
func on_enemy_grand_map_squad_moving(unit :BaseTileUnit, _from :Vector2, to :Vector2):
	# ignore if in battle map zone
	if to in zoomable_battle_map.keys():
		return
		
	# if listening pos is captured by team
	# all enemy team unit will be spotted
	var is_listening :bool = (team_listen_radio == player.player_team)
	
	# pasive spotting
	# enemy enter one of the watch list position
	# set spotted true, only from POV of spotter player
	unit.set_spotted(to in grand_map_watchlist_position or is_listening)
	
########################################## battle map unit ############################################

var battle_map_unit_positions :Dictionary = {} # { BaseTileMap (battle map):{Vector2:[ BaseTileUnit ] }}
var dead_bodies_holder :Dictionary ={}
	
func _on_battle_map_squad_finish_travel(_unit :BaseTileUnit, _from_tile_id :Vector2, _current_tile_id :Vector2):
	pass
	
func _on_battle_map_squad_current_tile_updated(unit :BaseTileUnit, from :Vector2, to :Vector2):
	if not battle_map_unit_positions.has(unit.tile_map):
		return
		
	var unit_pos :Dictionary = battle_map_unit_positions[unit.tile_map]
		
	# form of position tracking on map
	# this will tied to spotting mechanic
	if unit_pos.has(from):
		unit_pos[from].erase(unit)
		
	if not unit_pos.has(to):
		unit_pos[to] = []
		
	unit_pos[to].append(unit)
	
func _on_battle_map_infantry_clicked(unit :Infantry, stats :UnitStatsData):
	var player_unit :bool = unit.player_id == player.player_id
	if is_instance_valid(ui.selected_battle_map_unit):
		var holder = ui.selected_battle_map_unit
		ui.selected_battle_map_unit.set_selected(false)
		ui.selected_battle_map_unit = null
		
		if holder == unit:
			return
		
	if player_unit:
		ui.selected_battle_map_unit = unit
		ui.selected_battle_map_unit.set_selected(true)
		ui.unit_stats.show_stats(stats, false)
		
func _on_battle_map_vehicle_clicked(vehicle :Vehicle, stats :UnitStatsData):
	var player_unit :bool = vehicle.player_id == player.player_id
	
	if is_instance_valid(ui.selected_battle_map_unit):
		
		# condition enter vehicle if current unit is infantry
		# and target unit selected is vehicle
		var is_infantry = ui.selected_battle_map_unit is Infantry
		if player_unit and is_infantry:
			order_infatry_squad_to_enter_vehicle(ui.selected_battle_map_unit, vehicle)
			
			ui.selected_battle_map_unit.set_selected(false)
			ui.selected_battle_map_unit = null
			return
			
		var holder = ui.selected_battle_map_unit
		ui.selected_battle_map_unit.set_selected(false)
		ui.selected_battle_map_unit = null
		
		if holder == vehicle:
			return
			
	if player_unit:
		ui.selected_battle_map_unit = vehicle
		ui.selected_battle_map_unit.set_selected(true)
		ui.unit_stats.show_stats(stats, true)
		
func _on_battle_map_unit_dead(unit :BaseTileUnit):
	if ui.selected_battle_map_unit == unit:
		ui.selected_battle_map_unit.set_selected(false)
		ui.selected_battle_map_unit = null
		
	# decrease man power
	# every time a fking unit died
	if unit.player_id == player.player_id:
		var mp :int = ui.game_resource.manpower
		var mxmp :int = ui.game_resource.max_manpower
		if unit is Infantry:
			ui.game_resource.manpower = int(clamp(mp - 1, 0, mxmp))
		elif unit is Vehicle:
			ui.game_resource.manpower = int(clamp(mp - 2, 0, mxmp))
		
	# remove from spotting mechanic
	var pos_datas:Array = battle_map_unit_positions[unit.tile_map][unit.current_tile]
	if pos_datas.has(unit):
		pos_datas.erase(unit)
		
	var dead_body = unit.clone_mesh()
	add_child(dead_body)
	
	# add dead body to holder
	if not dead_bodies_holder.has(unit.tile_map):
		dead_bodies_holder[unit.tile_map] = []
		
	dead_bodies_holder[unit.tile_map].append(dead_body)
	
	# limit 15 dead per battle map
	if dead_bodies_holder[unit.tile_map].size() > 15:
		var f = dead_bodies_holder[unit.tile_map].front()
		f.queue_free()
		dead_bodies_holder[unit.tile_map].pop_front()
		
	yield(get_tree(),"idle_frame")
	unit.queue_free()
	
func _on_battle_map_vehicle_drop_passenger(vehicle :Vehicle, passengers :Array):
	var vehicle_squad :VehicleSquad = vehicle.squad
	
	var squads :Array = []
	for i in passengers:
		var if_s :InfantrySquad = i
		if_s.current_tile = vehicle_squad.current_tile
		if_s.translation = vehicle_squad.global_position
		
		for m in if_s.members:
			m.current_tile = vehicle.current_tile
			
		squads.append(if_s.get_path())
	
	rpc("_on_battle_map_passenger_exit_vehicle", squads,vehicle_squad.current_tile, vehicle.current_tile)
	
# tell all that this squad are entering
# battle map
remotesync func _on_battle_map_passenger_exit_vehicle(units:Array, grand_map_tile_id :Vector2, battle_map_tile_id :Vector2):
	for unit in units:
		order_infatry_squad_to_exit_vehicle(get_node_or_null(unit), grand_map_tile_id, battle_map_tile_id)
	
########################################## squad member control ############################################

func order_squad_to_enter_battle_map(unit :BaseSquad, from_tile_id :Vector2, current_tile_id :Vector2):
	unit.in_battle_map = true

	if unit is VehicleSquad:
		
		var vehicle :Vehicle = unit.vehicle
		
		var result :Array = create_entry_positions(from_tile_id, current_tile_id, vehicle.is_air)
		var entry_positions :Array = result[0]
		var point_battle_map :BaseTileMap = result[1]
		var battle_map_tile_id :Vector2 = result[2]
		var center_point :Vector3 = point_battle_map.get_tile_instance(Vector2.ZERO).global_position
		
		vehicle.unit_position = battle_map_unit_positions[point_battle_map]
		vehicle.tile_map = point_battle_map
		vehicle.current_tile = battle_map_tile_id
		vehicle.translation = point_battle_map.get_tile_instance(vehicle.current_tile).global_position
		vehicle.visible = true
		vehicle.is_selectable = (vehicle.player_id == player.player_id)
		vehicle.set_sync(true)
		
		if vehicle.player_id == player.player_id:
			vehicle.stop()
		
		if not entry_positions.empty():
			vehicle.current_tile = entry_positions.front()
			vehicle.translation = point_battle_map.get_tile_instance(vehicle.current_tile).global_position
			entry_positions.pop_front()
			
		# add to spotting mechanic
		if not battle_map_unit_positions[vehicle.tile_map].has(vehicle.current_tile):
			battle_map_unit_positions[vehicle.tile_map][vehicle.current_tile] = []
			
		var pos_datas:Array = battle_map_unit_positions[vehicle.tile_map][vehicle.current_tile]
		if not pos_datas.has(vehicle):
			pos_datas.append(vehicle)
			
		if vehicle.current_tile != Vector2.ZERO:
			vehicle.look_at(center_point, Vector3.UP)
			vehicle.global_rotation.x = 0
			vehicle.global_rotation.z = 0
			vehicle.translation = vehicle.translation + (vehicle.transform.basis.z * 10)
			vehicle.move_to(vehicle.current_tile)
			
		if vehicle.is_air:
			vehicle.translation.y = 10.0
			
		vehicle.update_spotting()
		
	if unit is InfantrySquad:
		var result :Array = create_entry_positions(from_tile_id, current_tile_id)
		var entry_positions :Array = result[0]
		var point_battle_map :BaseTileMap = result[1]
		var battle_map_tile_id :Vector2 = result[2]
		var center_point :Vector3 = point_battle_map.get_tile_instance(Vector2.ZERO).global_position
		
		for member in unit.members:
			var infantry :Infantry = member
			infantry.unit_position = battle_map_unit_positions[point_battle_map]
			infantry.tile_map = point_battle_map
			infantry.current_tile = battle_map_tile_id
			infantry.translation = point_battle_map.get_tile_instance(infantry.current_tile).global_position
			infantry.visible = true
			infantry.is_selectable = (infantry.player_id == player.player_id)
			infantry.set_sync(true)
			
			if infantry.player_id == player.player_id:
				infantry.stop()
				
			if not entry_positions.empty():
				infantry.current_tile = entry_positions.front()
				infantry.translation = point_battle_map.get_tile_instance(infantry.current_tile).global_position
				entry_positions.pop_front()
				
			# add to spotting mechanic
			if not battle_map_unit_positions[infantry.tile_map].has(infantry.current_tile):
				battle_map_unit_positions[infantry.tile_map][infantry.current_tile] = []
				
			var pos_datas:Array = battle_map_unit_positions[infantry.tile_map][infantry.current_tile]
			if not pos_datas.has(infantry):
				pos_datas.append(infantry)
			
			if infantry.current_tile != Vector2.ZERO:
				infantry.look_at(center_point, Vector3.UP)
				infantry.global_rotation.x = 0
				infantry.global_rotation.z = 0
				
			infantry.update_spotting()
			
func order_squad_to_exit_battle_map(squad :BaseSquad, battle_map_tile_id :Vector2, grand_map_tile_id :Vector2):
	if squad is VehicleSquad:
		var vehicle :Vehicle = squad.vehicle
		if vehicle.have_task():
			return
		
		vehicle.attack_move = false
		vehicle.unit_position = {}
		vehicle.tile_map = battle_map_holder[squad.current_tile]
		vehicle.move_to(battle_map_tile_id)
		vehicle.set_selected(false)
		vehicle.is_selectable = false
		
	if squad is InfantrySquad:
		for i in squad.members:
			var infantry :Infantry = i
			
			# remove from spotting mechanic
			var pos_datas:Array = battle_map_unit_positions[infantry.tile_map][infantry.current_tile]
			if pos_datas.has(infantry):
				pos_datas.erase(infantry)
				
			infantry.attack_move = false
			infantry.unit_position = {}
			infantry.tile_map = battle_map_holder[squad.current_tile]
			infantry.move_to(battle_map_tile_id)
			infantry.set_selected(false)
			infantry.is_selectable = false
		
	squad.exit_battle_map(battle_map_tile_id, grand_map_tile_id)
	
func order_infatry_squad_to_enter_vehicle(infantry :Infantry, vehicle :Vehicle):
	var has_space :bool = vehicle.capacity > vehicle.passengers.size()
	var is_enter_tile_valid :bool = infantry.tile_map.is_nav_enable(vehicle.current_tile)
	if not is_enter_tile_valid or not has_space or vehicle.have_task() or vehicle.is_moving():
		return
		
	var squad :InfantrySquad = infantry.squad
	for i in squad.members:
		var member :Infantry = i
		member.attack_move = false
		member.tile_map = battle_map_holder[squad.current_tile]
		member.move_to(vehicle.current_tile)
		member.set_selected(false)
		member.is_selectable = false
	
	squad.enter_vehicle(vehicle.current_tile, vehicle)
	vehicle.prepare_take_passenger()
	
func order_infatry_squad_to_exit_vehicle(unit :InfantrySquad, grand_map_tile_id :Vector2, battle_map_tile_id :Vector2):
	var positions :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), battle_map_tile_id, 2)
	var point_battle_map :BaseTileMap = battle_map_holder[grand_map_tile_id]
	var entry_positions :Array = []
	
	for id in positions:
		if not point_battle_map.has_tile(id):
			continue
			
		if point_battle_map.is_nav_enable(id):
			entry_positions.append(id)
			
	unit.current_tile = grand_map_tile_id
	unit.translation = grand_map.get_tile_instance(grand_map_tile_id).global_position
	
	for member in unit.members:
		var infantry :Infantry = member
		infantry.unit_position = battle_map_unit_positions[point_battle_map]
		infantry.tile_map = point_battle_map
		infantry.current_tile = battle_map_tile_id
		infantry.translation = point_battle_map.get_tile_instance(infantry.current_tile).global_position
		infantry.visible = true
		infantry.is_selectable = (infantry.player_id == player.player_id)
		infantry.set_sync(true)
		
		if infantry.player_id == player.player_id:
			infantry.stop()
			
		if not entry_positions.empty():
			infantry.current_tile = entry_positions.front()
			infantry.translation = point_battle_map.get_tile_instance(infantry.current_tile).global_position
			entry_positions.pop_front()
			
		if not battle_map_unit_positions[infantry.tile_map].has(infantry.current_tile):
			battle_map_unit_positions[infantry.tile_map][infantry.current_tile] = []
			
		infantry.update_spotting()
		
		# add to spotting mechanic
		var pos_datas:Array = battle_map_unit_positions[member.tile_map][member.current_tile]
		if not pos_datas.has(member):
			pos_datas.append(member)



