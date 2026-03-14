extends BaseTileObject
class_name ContestedTile

# MUST SET
export var overlay_ui :NodePath
export var camera :NodePath
export var icon :StreamTexture

export var team :int = 0 setget _set_team
export var point :int = 100
export var max_point :int = 100

var _is_set :bool
var _cam :Camera
var _overlay_ui :Control

func _ready():
	_cam = get_node_or_null(camera)
	_overlay_ui = get_node_or_null(overlay_ui)
	_is_set = is_instance_valid(_cam) and is_instance_valid(_overlay_ui)
	set_process(_is_set)

func _set_team(v :int):
	team = v

func _process(delta):
	pass

func set_color(m :SpatialMaterial):
	pass
