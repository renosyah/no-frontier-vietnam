extends Button

export var button_icon :StreamTexture
export var button_color :Color
var contested :ContestedTile

onready var _progress = $progress
onready var _button_icon = $button_icon

func _ready():
	_progress.tint_progress = button_color
	_button_icon.texture = button_icon
	_button_icon.modulate = button_color

func display_update_point(player_team :int):
	var _color = Global.get_base_color(contested.team, player_team)
	_progress.max_value = contested.max_point
	_progress.value = contested.point
	_progress.tint_progress = _color
	_button_icon.modulate = _color
