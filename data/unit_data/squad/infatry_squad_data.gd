extends TileUnitData
class_name InfantrySquadData

export var members :Array # [ InfantryData ]
export var team_color_material_index :int

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	
	members = []
	for i in _data["_a"]:
		var inf :InfantryData = InfantryData.new()
		inf.from_dictionary(i)
		members.append(inf)
		
	team_color_material_index = _data["_b"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["_a"] = []
	for i in members:
		var inf :InfantryData = i
		_data["_a"].append(inf.to_dictionary())
		
	_data["_b"] = team_color_material_index
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
	infantry_squad.is_selectable = (player_id == player_data.player_id)
	infantry_squad.squad_icon = preload("res://assets/user_interface/icons/floating_icon/infantry.png")
	infantry_squad.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	infantry_squad.connect("on_finish_travel", parent ,"_on_grand_map_squad_finish_travel")
	infantry_squad.connect("on_current_tile_updated", parent, "_on_grand_map_squad_current_tile_updated")
	infantry_squad.connect("on_unit_selected", parent, "_on_grand_map_squad_selected")
	infantry_squad.connect("on_squad_task_exit_battle_map", parent, "_on_grand_map_squad_task_exit_battle_map")
	
	if infantry_squad is InfantrySquad:
		infantry_squad.connect("on_infatry_squad_task_enter_vehicle", parent, "_on_grand_map_infatry_squad_task_enter_vehicle")
	
	parent.add_child(infantry_squad)
	
	infantry_squad.set_spotted(team != player_data.player_team)
	infantry_squad.set_hidden(false)
	infantry_squad.translation = position
	
	# connect signal after set_spotted function called
	# if not,it will trigger to emit on_unit_spotted
	infantry_squad.connect("on_unit_spotted", parent, "_on_grand_map_squad_spotted")
	
	for i in members:
		var inf :InfantryData = i
		var infantry :Infantry = inf.spawn(player_data, parent,overlay_ui_path,cam_path)
		infantry.squad = infantry_squad
		infantry_squad.members.append(infantry)
		
	return infantry_squad
