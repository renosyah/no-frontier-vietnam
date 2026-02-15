extends MarginContainer
class_name FloatingSquadIcon

export var color :Color
export var icon :Resource

onready var bg = $bg
onready var icn = $VBoxContainer/icn

func _ready():
	bg.modulate = color
	icn.texture = icon
