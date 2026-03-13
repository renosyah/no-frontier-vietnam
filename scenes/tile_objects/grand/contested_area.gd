extends ContestedTile

onready var border = $border

func set_color(m :SpatialMaterial):
	border.set_surface_material(0,m)
