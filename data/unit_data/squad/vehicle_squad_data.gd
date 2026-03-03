extends TileUnitData
class_name VehicleSquadData

var vehicle :VehicleData # [ VehicleData ]
export var team_color_material_index :int
export var squad_icon_index :int

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	vehicle = VehicleData.new()
	vehicle.from_dictionary(_data["_a"])
	team_color_material_index = _data["_b"]
	squad_icon_index = _data["_c"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["_a"] = vehicle.to_dictionary()
	_data["_b"] = team_color_material_index
	_data["_c"] = squad_icon_index 
	return _data
	
func spawn(player_data :PlayerData, parent, overlay_ui_path:NodePath, cam_path:NodePath) -> VehicleSquad:
	var vehicle_squad :VehicleSquad = ScenesIndex.grand_map_squad_scenes[scene_index].instance()
	vehicle_squad.player_id = player_id
	vehicle_squad.name = unit_name
	vehicle_squad.set_network_master(player_network_id)
	vehicle_squad.current_tile = current_tile
	vehicle_squad.team = team
	vehicle_squad.overlay_ui = overlay_ui_path
	vehicle_squad.camera = cam_path
	vehicle_squad.unit_voice = unit_voice
	vehicle_squad.is_selectable = (player_id == player_data.player_id)
	vehicle_squad.squad_icon = AssetsIndex.squad_icons[squad_icon_index]
	vehicle_squad.color = color
	vehicle_squad.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	parent.add_child(vehicle_squad)
	
	vehicle_squad.set_spotted(team != player_data.player_team)
	vehicle_squad.set_hidden(false)
	vehicle_squad.translation = position
	
	return vehicle_squad
