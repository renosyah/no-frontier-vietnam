extends ContestedTile

onready var mesh_instance = $MeshInstance
onready var border = $border

func set_color(m :SpatialMaterial):
	.set_color(m)
	
	mesh_instance.set_surface_material(0,m)
	border.set_surface_material(0,m)
