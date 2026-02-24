extends TileUnitData
class_name VehicleSquadData

var vehicle :VehicleData # [ VehicleData ]
export var team_color_material_index :int

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	vehicle = VehicleData.new()
	vehicle.from_dictionary(_data["_a"])
	team_color_material_index = _data["_b"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["_a"] = vehicle.to_dictionary()
	_data["_b"] = team_color_material_index
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
	vehicle_squad.is_selectable = (player_id == player_data.player_id)
	vehicle_squad.squad_icon = preload("res://assets/user_interface/icons/floating_icon/uh1d.png")
	vehicle_squad.color = color
	vehicle_squad.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	vehicle_squad.connect("on_finish_travel", parent ,"_on_grand_map_squad_finish_travel")
	vehicle_squad.connect("on_current_tile_updated", parent, "_on_grand_map_squad_current_tile_updated")
	vehicle_squad.connect("on_unit_selected", parent, "_on_grand_map_squad_selected")
	vehicle_squad.connect("on_squad_task_exit_battle_map", parent, "_on_grand_map_squad_task_exit_battle_map")
	parent.add_child(vehicle_squad)
	
	vehicle_squad.set_spotted(team != player_data.player_team)
	vehicle_squad.set_hidden(false)
	vehicle_squad.translation = position
	
	# connect signal after set_spotted function called
	# if not,it will trigger to emit on_unit_spotted
	vehicle_squad.connect("on_unit_spotted", parent, "_on_grand_map_squad_spotted")
	
	var veh :Vehicle = vehicle.spawn(player_data, parent, overlay_ui_path, cam_path)
	veh.squad = vehicle_squad
	
	vehicle_squad.vehicle = veh
	return vehicle_squad
