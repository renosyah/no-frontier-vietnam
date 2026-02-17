extends BaseSquad
class_name BaseInfantrySquad

onready var mesh_instances = [
	$decoration_icon/MeshInstance, $decoration_icon/MeshInstance2,
	$decoration_icon/MeshInstance4, $decoration_icon/MeshInstance5,
	$decoration_icon/MeshInstance3
]
onready var decoration_icon = $decoration_icon

var _on_ambush_mode :bool
var _on_camp_mode :bool

func setup_ambush(v :bool):
	if is_camp_mode():
		return
		
	if _is_master:
		rpc("_setup_ambush", v)
		
func setup_camp(v :bool):
	if is_ambush_mode():
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
		
func set_paths(v :Array):
	if is_ambush_mode() or _on_camp_mode:
		return
	
	.set_paths(v)
	
	if _is_master and not v.empty():
		Global.unit_responded(RadioChatters.COMMAND_ACKNOWLEDGEMENT,team)
		
func set_spotted(v :bool):
	if is_ambush_mode():
		return
	
	.set_spotted(v)
	
	decoration_icon.visible = _current_visible
	
func set_hidden(v :bool):
	.set_hidden(v)
	
	decoration_icon.visible = _current_visible
