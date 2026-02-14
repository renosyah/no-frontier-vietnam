extends BaseTileObject

onready var label = $label

func set_label(v :String):
	label.text = v
