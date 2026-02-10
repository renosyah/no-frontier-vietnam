extends Control

onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var map_name = $CanvasLayer/Control/VBoxContainer/HBoxContainer/ColorRect/map_name

func _on_menu_button_pressed():
	get_tree().change_scene("res://menu/editor/editor.tscn")
