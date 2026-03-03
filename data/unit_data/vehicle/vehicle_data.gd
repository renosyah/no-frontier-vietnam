extends TileUnitData
class_name VehicleData

export var team_color_material_index :int
export var altitude :float
export var is_air :bool

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	team_color_material_index = _data["_a1"]
	altitude = _data["_b1"]
	is_air = _data["_c1"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["_a1"] = team_color_material_index
	_data["_b1"] = altitude
	_data["_c1"] = is_air
	return _data
	
	
func spawn(player_data :PlayerData, parent, _overlay_ui_path:NodePath, _cam_path:NodePath) -> Vehicle:
	var vehicle :Vehicle = ScenesIndex.battle_map_unit_scenes[scene_index].instance()
	vehicle.player_id = player_id
	vehicle.name = unit_name
	vehicle.set_network_master(player_network_id)
	vehicle.current_tile = Vector2.ZERO
	vehicle.team = team
	vehicle.is_selectable = (player_id == player_data.player_id)
	vehicle.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	vehicle.is_air = is_air
	vehicle.altitude = altitude
	vehicle.unit_voice = unit_voice
	vehicle.color = color
	vehicle.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	parent.add_child(vehicle)
	
	vehicle.translation = Vector3(-100, -100, -100)
	vehicle.visible = false
	vehicle.set_hidden(false)
	vehicle.set_spotted(true)
	vehicle.set_sync(false)
	
	return vehicle
