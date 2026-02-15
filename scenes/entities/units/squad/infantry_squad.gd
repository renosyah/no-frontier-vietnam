extends BaseSquad

onready var mesh_instances = [
	$decoration_icon/MeshInstance, $decoration_icon/MeshInstance2,
	$decoration_icon/MeshInstance4, $decoration_icon/MeshInstance5,
	$decoration_icon/MeshInstance3
]
onready var decoration_icon = $decoration_icon

func _ready():
	for i in mesh_instances:
		i.set_surface_material(0, Global.spatial_team_colors[team])
		
func set_spotted(v :bool):
	.set_spotted(v)
	
	decoration_icon.visible = _current_visible
	
func set_hidden(v :bool):
	.set_hidden(v)
	
	decoration_icon.visible = _current_visible
