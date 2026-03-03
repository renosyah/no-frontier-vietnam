extends BaseTileUnit
class_name BaseSquad

signal on_squad_task_exit_battle_map(squad, to_grand_map_id)
signal on_squad_destroyed(squad)

# MUST SET
export var overlay_ui :NodePath
export var camera :NodePath
export var squad_icon :StreamTexture
export var team_color_material :SpatialMaterial

onready var _cam :Camera = get_node_or_null(camera)
onready var _overlay_ui :Control = get_node_or_null(overlay_ui)

var in_battle_map :bool
var _floating_icon :FloatingSquadIcon

func _ready():
	_floating_icon = preload("res://assets/user_interface/icons/floating_icon/floating_icon.tscn").instance()
	_floating_icon.color = color
	_floating_icon.icon = squad_icon
	_floating_icon.name = name
	_floating_icon.is_selectable = is_selectable
	_floating_icon.connect("on_press", self, "_on_floating_icon_press")
	_overlay_ui.add_child(_floating_icon)
	
func _exit_tree():
	_floating_icon.queue_free()
	
func exit_battle_map(_at_battle_map_id :Vector2, to_grand_map_id :Vector2):
	emit_signal("on_squad_task_exit_battle_map", self, to_grand_map_id)
	
func moving(_delta):
	.moving(_delta)
	
	_track_floating_icon(_cam, global_position)
	
func _track_floating_icon(_active_cam :Camera, pos :Vector3):
	if not _overlay_ui.visible:
		return
		
	_floating_icon.visible = _current_visible
	if not _floating_icon.visible:
		return
		
	if _active_cam.is_position_behind(pos):
		return
		
	var screen_pos = _active_cam.unproject_position(pos)
	_floating_icon.rect_global_position = screen_pos - _floating_icon.rect_pivot_offset
	
func set_selected(v :bool):
	if not is_selectable:
		return
		
	.set_selected(v)
	_floating_icon.selected(_is_selected)
	
func _on_floating_icon_press():
	emit_signal("on_unit_clicked", self)
