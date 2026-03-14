extends MarginContainer

export var color :Color
export var icon :StreamTexture
var squad :BaseSquad

onready var _color_rect = $ColorRect
onready var _texture_rect = $VBoxContainer/HBoxContainer/TextureRect
onready var _label = $VBoxContainer/HBoxContainer/Label

func _ready():
	_texture_rect.texture = icon
	_color_rect.modulate = color
	update_squad_members_size()
	
func update_squad_members_size():
	if squad is InfantrySquad:
		var sum = 0
		for i in squad.members:
			if not is_instance_valid(i):
				continue
			if i.is_dead:
				continue
			sum += 1
		_label.text = "%s" % sum
		
	if squad is VehicleSquad:
		_label.text = "1"
