extends MarginContainer

signal close
signal drop_passenger

onready var potrait = $HBoxContainer/Control/Control2/TextureRect/potrait
onready var unit_name = $HBoxContainer/Control/Control2/Control/Control/TextureRect/unit_name
onready var vehicle_option = $HBoxContainer/vehicle_option
onready var infantry_option = $HBoxContainer/infantry_option
onready var weapon_image = $HBoxContainer/infantry_option/MarginContainer/VBoxContainer/CenterContainer/weapon_image
onready var ammo = $HBoxContainer/infantry_option/MarginContainer/VBoxContainer/HBoxContainer/ammo

var _info_weapon :Weapon

func _ready():
	vehicle_option.visible = false
	infantry_option.visible = false
	
func _process(delta):
	if not visible:
		return
		
	if is_instance_valid(_info_weapon):
		ammo.text = "%s/%s" % [_info_weapon.ammo, _info_weapon.reserve_ammo]

func show_stats(stats :UnitStatsData, unit :BaseTileUnit):
	unit_name.text = stats.soldier_name
	potrait.texture = Global.infantry_potraits[stats.soldier_potrait_index]
	
	infantry_option.visible = false
	vehicle_option.visible = false
	
	if unit is Vehicle:
		_display_vehicle_info(unit)
		
	if unit is Infantry:
		_display_infantry_info(unit)

func _display_vehicle_info(veh: Vehicle):
	vehicle_option.visible = veh.passengers.size() > 0

func _display_infantry_info(unit :Infantry):
	infantry_option.visible = true
	_info_weapon = unit.get_weapon()
	weapon_image.texture = _info_weapon.icon
	
func _on_close_pressed():
	emit_signal("close")

func _on_drop_unit_pressed():
	emit_signal("drop_passenger")
