extends BaseTileObject

onready var mesh_instance = $MeshInstance
onready var border = $border

func set_color(m :SpatialMaterial):
	mesh_instance.set_surface_material(0,m)
	border.set_surface_material(0,m)
