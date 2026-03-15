extends MarginContainer

signal close
signal drop_passenger

onready var potrait = $HBoxContainer/Control/Control2/TextureRect/potrait
onready var unit_name = $HBoxContainer/Control/Control2/Control/Control/TextureRect/unit_name

onready var vehicle_option = $HBoxContainer/vehicle_option
onready var vehicle_info = $HBoxContainer/vehicle_info
onready var vehicle_image = $HBoxContainer/vehicle_info/MarginContainer/CenterContainer/vehicle_image

onready var infantry_weapon_info = $HBoxContainer/infantry_weapon_info
onready var weapon_image = $HBoxContainer/infantry_weapon_info/MarginContainer/VBoxContainer/CenterContainer/weapon_image
onready var ammo = $HBoxContainer/infantry_weapon_info/MarginContainer/VBoxContainer/HBoxContainer/ammo
onready var weapon_durability = $HBoxContainer/infantry_weapon_info/MarginContainer/VBoxContainer/CenterContainer/weapon_durability

onready var infantry_grenade_ability = $HBoxContainer/infantry_grenade_ability
onready var infantry_launcher_ability = $HBoxContainer/infantry_launcher_ability
onready var infantry_heal_ability = $HBoxContainer/infantry_heal_ability

onready var grenade_count = $HBoxContainer/infantry_grenade_ability/MarginContainer/greande_count
onready var launcher_count = $HBoxContainer/infantry_launcher_ability/MarginContainer/launcher_count
onready var heal_count = $HBoxContainer/infantry_heal_ability/MarginContainer/heal_count

var _info_weapon :Weapon
var _vehicle_unit :Vehicle
var _infantry_unit :Infantry

func _ready():
	_hide()
	
func _process(delta):
	if not visible:
		return
		
	if is_instance_valid(_info_weapon):
		ammo.text = "%s/%s" % [_info_weapon.ammo, _info_weapon.reserve_ammo]
		weapon_durability.modulate.a = (_info_weapon.max_durability - _info_weapon.durability) / 100
		
	if is_instance_valid(_infantry_unit):
		infantry_grenade_ability.visible = _infantry_unit.grenade > 0
		infantry_launcher_ability.visible = _infantry_unit.launcher > 0
		infantry_heal_ability.visible = _infantry_unit.medkit > 0
		grenade_count.text = "x %s" % _infantry_unit.grenade
		launcher_count.text = "x %s" % _infantry_unit.launcher
		heal_count.text = "x %s" % _infantry_unit.medkit
		
func show_stats(stats :UnitStatsData, unit :BaseTileUnit):
	_vehicle_unit = null
	_infantry_unit = null
	
	unit_name.text = stats.soldier_name
	potrait.texture = Global.infantry_potraits[stats.soldier_potrait_index]
	
	_hide()
	
	if unit is Vehicle:
		_vehicle_unit = unit
		_display_vehicle_info(unit)
		
	if unit is Infantry:
		_infantry_unit = unit
		_display_infantry_info(unit)

func _hide():
	vehicle_info.visible = false
	infantry_weapon_info.visible = false
	vehicle_option.visible = false
	infantry_grenade_ability.visible = false
	infantry_launcher_ability.visible = false
	infantry_heal_ability.visible = false
	
func _display_vehicle_info(veh: Vehicle):
	vehicle_info.visible = true
	vehicle_option.visible = veh.passengers.size() > 0
	vehicle_image.texture = veh.icon

func _display_infantry_info(unit :Infantry):
	infantry_weapon_info.visible = true
	_info_weapon = unit.get_weapon()
	weapon_image.texture = _info_weapon.icon
	
func _on_close_pressed():
	emit_signal("close")

func _on_drop_unit_pressed():
	emit_signal("drop_passenger")

func _on_grenade_pressed():
	if is_instance_valid(_infantry_unit):
		_infantry_unit.use_grenade()
	
func _on_launch_pressed():
	if is_instance_valid(_infantry_unit):
		_infantry_unit.use_launcher()

func _on_heal_pressed():
	if is_instance_valid(_infantry_unit):
		_infantry_unit.use_medkit()
