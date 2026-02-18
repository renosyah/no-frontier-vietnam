extends BaseSquad
class_name BaseVehicleSquad

onready var mesh_instance = $decoration_icon/MeshInstance
onready var decoration_icon = $decoration_icon

var vehicle :BaseVehicle

func _ready():
	mesh_instance.set_surface_material(0, Global.spatial_team_colors[team])
	
func set_spotted(v :bool):
	.set_spotted(v)
	
	decoration_icon.visible = _current_visible
	
func set_hidden(v :bool):
	.set_hidden(v)
	
	decoration_icon.visible = _current_visible
