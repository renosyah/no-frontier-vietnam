extends ContestedTile

onready var border = $border
onready var swords = $swords
onready var flag = $flag

func _ready():
	flag.visible = false
	swords.visible = false

func _set_team(v :int):
	._set_team(v)

	if is_instance_valid(swords):
		swords.visible = (v == 0)
		
	if is_instance_valid(flag):
		flag.visible = (v != 0 and point < max_point)

func set_color(m :SpatialMaterial):
	border.set_surface_material(0,m)
