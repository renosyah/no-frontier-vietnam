extends BaseSquad
class_name BaseInfantrySquad

onready var mesh_instances = [
	$decoration_icon/MeshInstance, $decoration_icon/MeshInstance2,
	$decoration_icon/MeshInstance4, $decoration_icon/MeshInstance5,
	$decoration_icon/MeshInstance3
]
onready var decoration_icon = $decoration_icon
onready var task_checker = $task_checker

var _on_ambush_mode :bool
var _on_camp_mode :bool

func task_exiting(at_battle_map_id :Vector2, to_grand_map_id :Vector2):
	var _task_completed :bool = false
	while not _task_completed:
		var _all_arived :bool = true
		for i in members:
			if i.current_tile != at_battle_map_id:
				_all_arived = false
				
			else:
				i.translation = Vector3(-100, -100, -100)
				
		_task_completed = _all_arived
		
		task_checker.start()
		yield(task_checker,"timeout")
		
	.task_exiting(at_battle_map_id, to_grand_map_id)

func setup_ambush(v :bool):
	if _on_camp_mode or _is_moving:
		return
		
	if _is_master:
		rpc("_setup_ambush", v)
		
func setup_camp(v :bool):
	if _on_ambush_mode or _is_moving:
		return
		
	_on_camp_mode = v
	
remotesync func _setup_ambush(v :bool):
	_on_ambush_mode = v
	
func is_ambush_mode() -> bool:
	return _on_ambush_mode
	
func is_camp_mode() -> bool:
	return _on_camp_mode
	
func _ready():
	for i in mesh_instances:
		i.set_surface_material(0, Global.spatial_team_colors[team])
		
func move_to(tile_id :Vector2):
	if is_ambush_mode() or _on_camp_mode:
		return
	
	.move_to(tile_id)
	
func set_spotted(v :bool):
	if is_ambush_mode():
		return
	
	.set_spotted(v)
	
	decoration_icon.visible = _current_visible
	
func set_hidden(v :bool):
	.set_hidden(v)
	
	decoration_icon.visible = _current_visible
