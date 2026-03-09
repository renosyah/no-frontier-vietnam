extends MarginContainer

export var manpower :int = 80
export var max_manpower :int = 80

var resource_spots :Array = []

onready var mp = $VBoxContainer/HBoxContainer3/mp
onready var ammo = $VBoxContainer/HBoxContainer/ammo
onready var med = $VBoxContainer/HBoxContainer2/med

var _total_ammo :int
var _total_med :int

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")

func _on_global_tick():
	_total_ammo = 0
	_total_med = 0
	
	for i in resource_spots:
		if not is_instance_valid(i):
			resource_spots.erase(i)
			return
			
		if i is AmmoSpot:
			_total_ammo += i.ammo_supply
			
		elif i is HealSpot:
			_total_med += i.medical_supply
			
	mp.text = Utils.format_number(manpower)
	ammo.text = Utils.format_number(_total_ammo)
	med.text = Utils.format_number(_total_med)
