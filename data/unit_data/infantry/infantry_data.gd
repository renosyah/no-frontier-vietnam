extends TileUnitData
class_name InfantryData

const role_riflement = 1
const role_radio_operator = 2
const role_at_specialist = 3

const faction_macv = 1
const faction_nva = 2

# get all at ScenesIndex

export var skin_material_index :int
export var uniform_material_index :int
export var team_color_material_index :int
export var hat_scene_index :int
export var bag_scene_index :int
export var vest_scene_index :int
export var weapon_scene_index :int
export var launcher_scene_index :int
export var uniform_style :int # 1:normal,2:tanktop,3:notop
export var role :int

# why? because is set from origin side of player
# if i send entire stats, each peeer generate its own
# modified stats of units like hp diff from each unit
export var modified_max_hp :int
export var modified_speed :float
var stats:UnitStatsData

func make_variant(faction_idx :int):
	
	if faction_idx == faction_macv:
		var style = [0,1,2]
		var skin = [0,1]
		var hats = [0,1,2,4]
		var bags = [0,1,2,9]
		var vests = [0,1,4]
		var black_potrait = [1,2,4,6]
		var white_potrait = [0,3,5,7,8,9]
		
		stats.soldier_name = SoldierNames.get_random_us_name()
		skin_material_index = skin[randi() % 2]
		stats.soldier_potrait_index = black_potrait[randi() % 4] if skin_material_index == 1 else white_potrait[randi() % 6]
		hat_scene_index = hats[randi() % 4]
		bag_scene_index = bags[randi() % 4]
		vest_scene_index = vests[randi() % 3]
		uniform_style = style[randi() % 3]
		
		match (role):
			role_radio_operator:
				bag_scene_index = 3
				
			role_at_specialist:
				bag_scene_index = 4
		
	elif faction_idx == faction_nva:
		var hats = [3,4]
		var style = [0,1,2]
		var bags = [5,6,7,9]
		var vests = [2,3,4]
		stats.soldier_name = SoldierNames.get_random_viet_name()
		stats.soldier_potrait_index = int(rand_range(25, 34))
		hat_scene_index = hats[randi() % 2]
		bag_scene_index = bags[randi() % 4]
		vest_scene_index = vests[randi() % 3]
		uniform_style = style[randi() % 3]
		
		match (role):
			role_radio_operator:
				bag_scene_index = 3
				
			role_at_specialist:
				bag_scene_index = 8
				
	else:
		var style = [1,2]
		var vests = [2,3,4]
		stats.soldier_name = SoldierNames.get_random_viet_name()
		stats.soldier_potrait_index = int(rand_range(25, 34))
		hat_scene_index = 4
		bag_scene_index = 9
		vest_scene_index = vests[randi() % 3]
		uniform_style = style[randi() % 2]
		
func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	
	skin_material_index = _data["a1"]
	uniform_material_index = _data["b1"]
	team_color_material_index = _data["c1"]
	hat_scene_index = _data["d1"]
	bag_scene_index = _data["e1"]
	vest_scene_index = _data["f1"]
	weapon_scene_index = _data["g1"]
	launcher_scene_index = _data["h1"]
	uniform_style = _data["i1"]
	modified_max_hp = _data["j1"]
	modified_speed = _data["k1"]
	role = _data["l1"]
	
	stats = UnitStatsData.new()
	stats.from_dictionary(_data["m1"])
	 
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a1"] = skin_material_index
	_data["b1"] = uniform_material_index
	_data["c1"] = team_color_material_index
	_data["d1"] = hat_scene_index
	_data["e1"] = bag_scene_index
	_data["f1"] = vest_scene_index
	_data["g1"] = weapon_scene_index
	_data["h1"] = launcher_scene_index
	_data["i1"] = uniform_style
	_data["j1"] = modified_max_hp
	_data["k1"] = modified_speed
	_data["l1"] = role
	_data["m1"] = stats.to_dictionary()
	return _data
	
	
func spawn(player_data :PlayerData, parent, overlay_ui_path:NodePath, cam_path:NodePath):
	var infantry:Infantry  = ScenesIndex.battle_map_unit_scenes[scene_index].instance()
	infantry.player_id = player_id
	infantry.name = unit_name
	infantry.set_network_master(player_network_id)
	infantry.current_tile = Vector2.ZERO
	infantry.team = team
	infantry.is_selectable = (player_id == player_data.player_id)
	infantry.unit_voice = unit_voice
	infantry.color = color
	
	infantry.role = role
	infantry.skin_material = MaterialsIndex.infantry_skin_colors[skin_material_index]
	infantry.uniform_material = MaterialsIndex.infantry_uniforms[uniform_material_index]
	infantry.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	infantry.hat_scene = ScenesIndex.hats[hat_scene_index]
	infantry.bag_scene = ScenesIndex.bags[bag_scene_index]
	infantry.vest_scene = ScenesIndex.vests[vest_scene_index]
	infantry.weapon_scene = ScenesIndex.weapons[weapon_scene_index]
	infantry.launcher_scene = ScenesIndex.launcher[launcher_scene_index]
	infantry.uniform_style = uniform_style
	
	infantry.overlay_ui = overlay_ui_path
	infantry.camera = cam_path
	
	infantry.hp = modified_max_hp
	infantry.max_hp = modified_max_hp
	infantry.speed = modified_speed
	infantry.discipline = stats.discipline
	infantry.accuracy = stats.accuracy
	
	match (infantry.role):
		role_radio_operator:
			infantry.grenade = 0
			infantry.launcher = 0
			
		role_at_specialist:
			infantry.grenade = 0
			infantry.launcher = 1
			
	parent.add_child(infantry)
	
	infantry.translation = Vector3(-100, -100, -100)
	infantry.visible = false
	infantry.set_hidden(false)
	infantry.set_spotted(true)
	infantry.set_sync(false)
	
	return infantry
