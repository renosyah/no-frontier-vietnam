extends MarginContainer

signal close
signal drop_passenger

onready var potrait = $Control2/TextureRect/potrait
onready var unit_name = $Control3/Control/TextureRect/unit_name
onready var vehicle_option = $vehicle_option

func _ready():
	vehicle_option.visible = false

func show_stats(stats :UnitStatsData, unit :BaseTileUnit):
	unit_name.text = stats.soldier_name
	potrait.texture = Global.infantry_potraits[stats.soldier_potrait_index]
	
	if unit is Vehicle:
		_display_vehicle_info(unit)

func _display_vehicle_info(veh: Vehicle):
	vehicle_option.visible = veh.passengers.size() > 0

func _on_close_pressed():
	emit_signal("close")

func _on_drop_unit_pressed():
	emit_signal("drop_passenger")
