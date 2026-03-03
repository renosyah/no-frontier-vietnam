extends TileUnitData
class_name InfantryData

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
	
	parent.add_child(infantry)
	
	infantry.translation = Vector3(-100, -100, -100)
	infantry.visible = false
	infantry.set_hidden(false)
	infantry.set_spotted(true)
	infantry.set_sync(false)
	
	return infantry
