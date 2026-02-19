extends BaseTileUnit
class_name BaseSquad

signal on_squad_task_exit_battle_map(squad, to_grand_map_id)

# MUST SET
export var overlay_ui :NodePath
export var squad_icon :StreamTexture
export var camera :NodePath

onready var _cam :Camera = get_node_or_null(camera)
onready var _overlay_ui :Control = get_node_or_null(overlay_ui)

var _floating_icon :FloatingSquadIcon

var members :Array = [] # [ Infantry ]

func _ready():
	_floating_icon = preload("res://assets/user_interface/icons/floating_icon/floating_icon.tscn").instance()
	_floating_icon.color = Global.flat_team_colors[team]
	_floating_icon.icon = squad_icon
	_floating_icon.name = name
	_floating_icon.is_selectable = is_selectable
	_floating_icon.connect("on_press", self, "_on_floating_icon_press")
	_overlay_ui.add_child(_floating_icon)
	
func exit_battle_map(_at_battle_map_id :Vector2, to_grand_map_id :Vector2):
	emit_signal("on_squad_task_exit_battle_map", self, to_grand_map_id)
	
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
	
func set_selected(v :bool):
	if not is_selectable:
		return
		
	.set_selected(v)
	_floating_icon.selected(_is_selected)
	
func _on_floating_icon_press():
	set_selected(not _is_selected)
	emit_signal("on_unit_selected", self, _is_selected)
