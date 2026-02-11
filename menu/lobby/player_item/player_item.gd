extends MarginContainer

export var player_name:String
onready var label = $HBoxContainer/Label

func _ready():
	label.text = player_name
