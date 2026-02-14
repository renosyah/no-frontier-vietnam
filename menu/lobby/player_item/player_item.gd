extends MarginContainer

export var id :int
export var player_name :String

onready var label = $HBoxContainer/Label
onready var loading = $HBoxContainer/loading

func _ready():
	label.text = player_name
	set_loading(false)

func set_loading(v :bool):
	loading.visible = v

func is_loading() -> bool:
	return loading.visible
