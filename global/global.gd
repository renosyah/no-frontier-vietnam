extends Node

func _ready():
	SaveLoad.ensure_dir("user://%s/" % map_dir)
	load_player_data()
	monitor_network()
	init_save_load_map()
	setup_transition()
	init_radio_chatter()
	setup_tick()
	
##########################################  tick  ############################################

signal on_global_tick

var _tick :Timer

func setup_tick():
	_tick = Timer.new()
	_tick.wait_time = 1
	_tick.one_shot = true
	_tick.connect("timeout", self, "_on_tick")
	add_child(_tick)
	_tick.start()
	
func _on_tick():
	emit_signal("on_global_tick")
	_tick.start()
	
##########################################  team  ############################################

func get_team_color(owner_id :String, team :int, player_id :String, player_team :int):
	if owner_id == player_id:
		return Color.blue
	if owner_id != player_id and team == player_team:
		return Color.yellow
		
	return Color.red
	
func get_team_material_color(owner_id :String, team :int, player_id :String, player_team :int):
	return MaterialsIndex.team_colors[get_team_material_color_index(owner_id, team, player_id, player_team)]
	
func get_team_material_color_index(owner_id :String, team :int, player_id :String, player_team :int):
	if owner_id == player_id:
		return 1
	if owner_id != player_id and team == player_team:
		return 3
		
	return 2
	
func get_base_material_color(index :int, player_team :int):
	if index == player_team:
		return MaterialsIndex.team_colors[1]
	return MaterialsIndex.team_colors[2]
	
##########################################  player data  ############################################

const player_data_filepath :String = "player_data.dat"
var player_data :PlayerData
var player_potrait :PlayerPotrait

func monitor_network():
	Network.connect("server_player_connected", self, "_on_player_connected")
	Network.connect("client_player_connected", self, "_on_player_connected")
	
func _on_player_connected(player_network_unique_id :int):
	player_data.player_network_id = player_network_unique_id

func load_player_data():
	player_potrait = preload("res://assets/user_interface/player_potraits/player_potrait.tscn").instance()
	add_child(player_potrait)
	
	player_data = PlayerData.new()
	var data = SaveLoad.load_save(player_data_filepath, true)
	if data == null:
		player_data.player_id = Utils.create_unique_id()
		player_data.player_name = OS.get_name()
		player_data.player_rank = 0
		player_data.player_team = 1
		player_data.player_potrait = 0
		SaveLoad.save(player_data_filepath, player_data.to_dictionary(), true)
		
	else:
		player_data.from_dictionary(data)
		
		
func copy_preset_map():
	var maps :Array = Utils.get_all_resources("res://data/preset/", ["png","manifest","mission","map"])
	for i in maps:
		var file_path :String = i
		Utils.copy_file_to_user(i, "user://%s/%s" % [map_dir, file_path.get_file()])
		yield(get_tree(), "idle_frame")
		
##########################################  transisiion  ############################################
var transition :CanvasLayer

func setup_transition():
	transition = preload("res://assets/transision_screen/transision_screen.tscn").instance()
	add_child(transition)
	
func change_scene(scene :String, use :bool = false, bg_idx :int = 1):
	transition.change_scene(scene, use, bg_idx)
	
func hide_transition():
	transition.hide_transition()
	
##########################################  radio  ############################################

var radio_chatter :RadioChatters

func init_radio_chatter():
	radio_chatter = preload("res://assets/sounds/radio_chatter/radio_chatters.tscn").instance()
	add_child(radio_chatter)

func unit_responded(chatter_id :int, unit_voice :int, with_static :bool = false):
	var r = radio_chatter.US_RADIO[chatter_id] if unit_voice == 1 else radio_chatter.VIET_RADIO[chatter_id]
	var k = r.keys()
	var key = k[randi() % k.size()]
	radio_chatter.play_radio(key, r[key], with_static, true)
	
##########################################  potrait  ############################################
# infantry_potraits combine (0 - 9 macv) + 10 - 19 macv sog + 20 - 29 nva
onready var infantry_potraits :Array = SoldierPotraits.get_macv_potraits(2) + SoldierPotraits.get_nva_potraits(1)

onready var weapons = [
	preload("res://assets/user_interface/weapon_potraits/m16.png"),
	preload("res://assets/user_interface/weapon_potraits/type56.png")
]

##########################################  map editor  ############################################
# for load and save maps
const map_dir = "map"
const grand_map_size = 2
const battle_map_size = 5
const req_base_count = 2
const req_point_count = 1

var save_load_map :SaveLoadImproved

onready var grand_map_manifest_datas :Array = [] # [ GrandMapFileManifest ]

func init_save_load_map():
	save_load_map = preload("res://addons/save_load/save_load_improve.tscn").instance()
	add_child(save_load_map)

func load_maps() :
	grand_map_manifest_datas.clear()
	var list :PoolStringArray = Utils.get_all_resources("user://%s/" % map_dir, ["manifest"])
	for i in list:
		var m :GrandMapFileManifest = GrandMapFileManifest.new()
		var data = SaveLoad.load_save(i,false)
		m.from_dictionary(data)
		grand_map_manifest_datas.append(m)
		
func save_map(filename :String, data, use_prefix = true):
	var path = "%s/%s" %[map_dir, filename] if use_prefix else filename
	save_load_map.save_data_async(path, data, use_prefix)
	
func set_active_map(manif :GrandMapFileManifest):
	grand_map_manifest_data = manif
	
	save_load_map.load_data_async(manif.map_file_path,false)
	var results = yield(save_load_map,"load_done")
	grand_map_data = TileMapFileData.new()
	grand_map_data.from_dictionary(results[1])
	
	save_load_map.load_data_async(manif.mission_file_path,false)
	results = yield(save_load_map,"load_done")
	grand_map_mission_data = GrandMapFileMission.new()
	grand_map_mission_data.from_dictionary(results[1])
	
	battle_map_datas = {}
	for key in manif.battle_map_files.keys():
		var value = manif.battle_map_files[key]
		save_load_map.load_data_async(value,false)
		results = yield(save_load_map,"load_done")
		var battle_data = TileMapFileData.new()
		battle_data.from_dictionary(results[1])
		battle_map_datas[key] = battle_data
	
# for editor
var grand_map_manifest_data :GrandMapFileManifest
var grand_map_data :TileMapFileData
var grand_map_mission_data :GrandMapFileMission
var battle_map_datas :Dictionary = {} # [ Vector2:TileMapFileData ]

# entering battle map
var battle_map_name :String
var battle_map_data :TileMapFileData
var battle_map_id :Vector2
var battle_map_adjacent :Array # [ Vector2 ]

func null_map_data():
	grand_map_manifest_data = null
	grand_map_data = null
	grand_map_mission_data = null
	battle_map_datas = {}
	battle_map_name = ""
	battle_map_data = null
	battle_map_id = Vector2.ZERO
	battle_map_adjacent = []

func empty_map_data():
	grand_map_manifest_data = GrandMapFileManifest.new()
	grand_map_manifest_data.map_name = RandomNameGenerator.generate_name()
	grand_map_manifest_data.map_size = grand_map_size
	grand_map_manifest_data.battle_map_size = battle_map_size
	grand_map_manifest_data.battle_map_names = {}
	
	grand_map_data = TileMapUtils.generate_empty_tile_map(grand_map_manifest_data.map_size)
	
	grand_map_mission_data = GrandMapFileMission.new()
	grand_map_mission_data.bases = []
	grand_map_mission_data.points = []
	
	var alphabetics = Utils.military_alphabetic()
	battle_map_datas = {}
	for key in grand_map_data.tile_ids.keys():
		battle_map_datas[key] = TileMapUtils.generate_empty_tile_map(grand_map_manifest_data.battle_map_size, false)
		var sector_name = "%s %s-%s" % [alphabetics[randi() % alphabetics.size()], abs(key.x), abs(key.y)]
		grand_map_manifest_data.battle_map_names[key] = sector_name
		grand_map_mission_data.edited_battle_maps[key] = false
		
func save_edited_map():
	var map_file = yield(_save_map(),"completed")
	var mission_file = yield(_save_mission(),"completed")
	yield(_save_manifest(map_file, mission_file),"completed")
	
func _save_mission() -> String:
	var map_name = grand_map_manifest_data.map_name
	var file_path = "user://%s/%s.mission" % [map_dir,map_name]
	save_map(file_path, grand_map_mission_data.to_dictionary(), false)
	yield(save_load_map,"save_done")
	return file_path
	
func _save_map() -> String:
	var map_name = grand_map_manifest_data.map_name
	var file_path = "user://%s/%s.map" % [map_dir, map_name]
	save_map(file_path, grand_map_data.to_dictionary(), false)
	yield(save_load_map,"save_done")
	return file_path
	
func _save_manifest(map_file:String, mission_file:String):
	var map_name = grand_map_manifest_data.map_name
	var file_path = "user://%s/%s.manifest" % [map_dir, map_name]
	
	var img_path = yield(save_ss(map_name), "completed")
	grand_map_manifest_data.map_image_file_path = img_path
	
	grand_map_manifest_data.map_file_path = map_file
	grand_map_manifest_data.mission_file_path = mission_file
	grand_map_manifest_data.battle_map_files = {}
	
	for key in battle_map_datas.keys():
		var bmd :TileMapFileData =  battle_map_datas[key]
		var battle_file_path = "user://%s/%s_%s_%s.map" % [map_dir, map_name, key.x, key.y]
		save_map(battle_file_path, bmd.to_dictionary(), false)
		yield(save_load_map,"save_done")
		grand_map_manifest_data.battle_map_files[key] = battle_file_path
		
	# uses save load, cause data not that many LOL
	SaveLoad.save(file_path, grand_map_manifest_data.to_dictionary(), false)
	
##########################################  util  ############################################
func save_ss(map_name:String) -> String:
	var img: Image = get_viewport().get_texture().get_data()
	img.flip_y()
	
	var w = img.get_width()
	var h = img.get_height()
	var crop_rect = Rect2((w - 512)/2, (h - 512)/2, 512, 512)
	var img_path = "user://%s/%s.png" % [map_dir, map_name]
	var cropped_img = Image.new()
	cropped_img.create(512, 512, false, img.get_format())
	cropped_img.blit_rect(img, crop_rect, Vector2(0,0))
	cropped_img.save_png(img_path)
	yield(get_tree(),"idle_frame")
	
	return img_path
