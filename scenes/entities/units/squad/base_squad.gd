extends BaseTileUnit
class_name BaseSquad

# MUST SET
export var overlay_ui :NodePath
export var squad_icon :StreamTexture

onready var _cam :Camera = get_viewport().get_camera()
onready var _overlay_ui :Control = get_node_or_null(overlay_ui)
var _floating_icon :FloatingSquadIcon

func _ready():
	_floating_icon = preload("res://assets/user_interface/icons/floating_icon/floating_icon.tscn").instance()
	_floating_icon.color = Global.flat_team_colors[team]
	_floating_icon.icon = squad_icon
	_overlay_ui.add_child(_floating_icon)
	
func set_spotted(v :bool):
	.set_spotted(v)
	
func set_hidden(v :bool):
	.set_hidden(v)
	
func moving(_delta):
	.moving(_delta)
	
	if not _overlay_ui.visible:
		return
		
	var pos = global_position
	_floating_icon.visible = _current_visible and not _cam.is_position_behind(pos)
	if not _floating_icon.visible:
		return
		
	var screen_pos = _cam.unproject_position(pos)
	_floating_icon.rect_global_position = screen_pos - _floating_icon.rect_pivot_offset
	
func set_paths(v :Array):
	.set_paths(v)
	
	if _is_master and not v.empty():
		Global.unit_responded(RadioChatters.COMMAND_ACKNOWLEDGEMENT,team)
		
func _on_squad_on_finish_travel(_unit):
	if _is_master:
		Global.unit_responded(RadioChatters.MOVEMENT,team)
