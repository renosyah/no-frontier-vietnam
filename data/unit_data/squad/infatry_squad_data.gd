extends TileUnitData
class_name InfantrySquadData

export var members :Array # [ InfantryData ]
export var team_color_material_index :int
export var squad_icon_index :int

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	
	members = []
	for i in _data["_a"]:
		var inf :InfantryData = InfantryData.new()
		inf.from_dictionary(i)
		members.append(inf)
		
	team_color_material_index = _data["_b"]
	squad_icon_index = _data["_c"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["_a"] = []
	for i in members:
		var inf :InfantryData = i
		_data["_a"].append(inf.to_dictionary())
		
	_data["_b"] = team_color_material_index
	_data["_c"] = squad_icon_index 
	return _data

func spawn(player_data :PlayerData, parent, overlay_ui_path:NodePath, cam_path:NodePath) -> InfantrySquad:
	var infantry_squad :InfantrySquad = ScenesIndex.grand_map_squad_scenes[scene_index].instance()
	infantry_squad.player_id = player_id
	infantry_squad.name = unit_name
	infantry_squad.set_network_master(player_network_id)
	infantry_squad.current_tile = current_tile
	infantry_squad.team = team
	infantry_squad.overlay_ui = overlay_ui_path
	infantry_squad.camera = cam_path
	infantry_squad.unit_voice = unit_voice
	infantry_squad.is_selectable = (player_id == player_data.player_id)
	infantry_squad.squad_icon = AssetsIndex.squad_icons[squad_icon_index]
	infantry_squad.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	infantry_squad.color = color
	parent.add_child(infantry_squad)
	
	infantry_squad.set_spotted(team != player_data.player_team)
	infantry_squad.set_hidden(false)
	infantry_squad.translation = position
	
	for i in members:
		var inf :InfantryData = i
		var infantry :Infantry = inf.spawn(player_data, parent,overlay_ui_path,cam_path)
		infantry.squad = infantry_squad
		infantry_squad.members.append(infantry)
		
	return infantry_squad
