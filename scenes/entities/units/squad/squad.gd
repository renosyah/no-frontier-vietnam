extends BaseTileUnit

onready var mesh_instances = [
	$MeshInstance, $MeshInstance2, $MeshInstance4, $MeshInstance5, $MeshInstance3
]

var overlay_ui :Control
onready var cam :Camera = get_viewport().get_camera()
var _floating_icon :FloatingSquadIcon

func _ready():
	_floating_icon = preload("res://assets/user_interface/icons/floating_icon/floating_icon.tscn").instance()
	_floating_icon.color = Global.flat_team_colors[team]
	_floating_icon.icon = preload("res://assets/user_interface/icons/floating_icon/infantry.png")
	overlay_ui.add_child(_floating_icon)
	
	for i in mesh_instances:
		i.set_surface_material(0,Global.spatial_team_colors[team])
	
func _process(_delta):
	if not overlay_ui.visible:
		return
		
	var pos = global_position
	_floating_icon.visible = _current_visible and not cam.is_position_behind(pos)
	if _floating_icon.visible:
		var screen_pos = cam.unproject_position(pos)
		_floating_icon.rect_global_position = screen_pos - _floating_icon.rect_pivot_offset
	
func set_paths(v :Array):
	.set_paths(v)
	
	if _is_master and not v.empty():
		Global.unit_responded(RadioChatters.COMMAND_ACKNOWLEDGEMENT)
		
func _on_squad_on_finish_travel(_unit):
	if _is_master:
		Global.unit_responded(RadioChatters.MOVEMENT)
