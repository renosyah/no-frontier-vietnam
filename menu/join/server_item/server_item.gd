extends MarginContainer

signal join

var ip :String

onready var host_name = $VBoxContainer/HBoxContainer/VBoxContainer/host_name
onready var player_slot = $VBoxContainer/HBoxContainer/VBoxContainer/player_slot

func set_info(i :String, n :String, s :String):
	ip = i
	host_name.text = n
	player_slot.text = s

func _on_btn_pressed():
	emit_signal("join")
