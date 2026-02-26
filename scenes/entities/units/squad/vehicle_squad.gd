extends BaseSquad
class_name VehicleSquad

export var fuel_cost :int = 1
export var fuel :int = 100
export var max_fuel :int = 100

onready var mesh_instance = $decoration_icon/MeshInstance
onready var decoration_icon = $decoration_icon
onready var task_checker = $task_checker

var vehicle :Vehicle

func _ready():
	mesh_instance.set_surface_material(0, team_color_material)
	
func _on_current_tile_updated(_unit, _from_id, _to_id):
	._on_current_tile_updated(_unit, _from_id, _to_id)
	
	fuel = clamp(fuel - fuel_cost, 0, max_fuel)
	
	if fuel == 0:
		stop()
	
func move_to(tile_id :Vector2):
	if fuel == 0:
		return
	
	.move_to(tile_id)
	
func exit_battle_map(at_battle_map_id :Vector2, to_grand_map_id :Vector2):
	var _task_completed :bool = false
	while not _task_completed:
		var _all_arived :bool = true
		for i in [vehicle]:
			if i.current_tile != at_battle_map_id:
				_all_arived = false
				
			else:
				
				# hide unit
				# somewhere far LOL
				i.translation = Vector3(-100, -100, -100)
				i.set_sync(false)
				i.visible = false
				
		_task_completed = _all_arived
		
		task_checker.start()
		yield(task_checker,"timeout")
		
	.exit_battle_map(at_battle_map_id, to_grand_map_id)
	
func _get_tile_path(to :Vector2) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = tile_map.get_navigation(current_tile, to, [], vehicle.is_air)
	for id in p:
		var pos3 = tile_map.get_tile_instance(id).global_position
		paths.append(TileUnitPath.new(id, pos3))
		
	return paths
	
func set_spotted(v :bool):
	.set_spotted(v)
	
	decoration_icon.visible = _current_visible
	
func set_hidden(v :bool):
	.set_hidden(v)
	
	decoration_icon.visible = _current_visible
