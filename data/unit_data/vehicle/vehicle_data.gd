extends TileUnitData
class_name VehicleData

export var team_color_material_index :int
export var altitude :float
export var is_air :bool
export var capacity :int = 1

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	team_color_material_index = _data["_a1"]
	altitude = _data["_b1"]
	is_air = _data["_c1"]
	capacity = _data["_d1"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["_a1"] = team_color_material_index
	_data["_b1"] = altitude
	_data["_c1"] = is_air
	_data["_d1"] = capacity
	return _data
	
	
func spawn(player_data :PlayerData, parent, overlay_ui_path:NodePath, cam_path:NodePath) -> Vehicle:
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
	vehicle.capacity = capacity
	vehicle.unit_voice = unit_voice
	vehicle.team_color_material = MaterialsIndex.team_colors[team_color_material_index]
	vehicle.connect("on_unit_selected", parent, "_on_battle_map_unit_selected")
	vehicle.connect("on_unit_dead", parent, "_on_battle_map_unit_dead")
	vehicle.connect("on_vehicle_drop_passenger", parent, "_on_battle_map_vehicle_drop_passenger")
	parent.add_child(vehicle)
	
	vehicle.translation = Vector3(-100, -100, -100)
	vehicle.visible = false
	vehicle.set_hidden(false)
	vehicle.set_spotted(true)
	vehicle.set_sync(false)
	return vehicle
