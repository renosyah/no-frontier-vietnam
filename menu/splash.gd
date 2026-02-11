extends Control

func _ready():
	yield(get_tree().create_timer(1),"timeout")
	Global.change_scene("res://menu/main/main.tscn", true, 3)
