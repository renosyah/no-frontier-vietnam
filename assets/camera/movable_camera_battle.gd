extends MovableCamera
onready var camera = $Camera
onready var directional_light = $DirectionalLight

func _ready():
	directional_light.set_as_toplevel(true)

func set_as_current(v :bool):
	.set_as_current(v)
	
	camera.current = v
