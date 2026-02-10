extends Node

func _ready():
	SaveLoad.ensure_dir("user://%s/" % map_dir)
	_init_save_load_map()
	_setup_transition()
	
##########################################  transisiion  ############################################
var transition :CanvasLayer

func _setup_transition():
	transition = preload("res://assets/transision_screen/transision_screen.tscn").instance()
	add_child(transition)
	
func change_scene(scene :String, use :bool = false, bg_idx :int = 1):
	transition.change_scene(scene, use, bg_idx)
	
func hide_transition():
	transition.hide_transition()
##########################################  camera strict  ############################################

onready var camera_limit_bound = Vector3(3, 0, 2)

##########################################  map editor  ############################################
# for load and save maps
const map_dir = "map"
const grand_map_size = 2
const battle_map_size = 4
const req_base_count = 2
const req_point_count = 1

var save_load_map :SaveLoadImproved

onready var grand_map_manifest_datas :Array = [] # [ GrandMapFileManifest ]

func _init_save_load_map():
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
onready var grand_map_manifest_data :GrandMapFileManifest
onready var grand_map_data :TileMapFileData
onready var grand_map_mission_data :GrandMapFileMission
onready var battle_map_datas :Dictionary = {} # [ Vector2:TileMapFileData ]

var battle_map_name :String
var battle_map_data :TileMapFileData

func empty_map_data():
	grand_map_manifest_data = GrandMapFileManifest.new()
	grand_map_manifest_data.map_name = RandomNameGenerator.generate_name()
	grand_map_manifest_data.map_size = grand_map_size
	grand_map_manifest_data.battle_map_size = battle_map_size
	grand_map_manifest_data.battle_map_names = {}
	
	grand_map_data = TileMapUtils.generate_basic_tile_map(grand_map_manifest_data.map_size)
	
	grand_map_mission_data = GrandMapFileMission.new()
	grand_map_mission_data.bases = []
	grand_map_mission_data.points = []
	
	var alphabetics = Utils.military_alphabetic()
	battle_map_datas = {}
	for key in grand_map_data.tile_ids.keys():
		battle_map_datas[key] = TileMapUtils.generate_basic_tile_map(grand_map_manifest_data.battle_map_size, false)
		var sector_name = "%s %s-%s" % [alphabetics[randi() % alphabetics.size()], abs(key.x), abs(key.y)]
		grand_map_manifest_data.battle_map_names[key] = sector_name
		
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
