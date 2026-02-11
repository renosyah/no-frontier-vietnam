extends MovableCamera
onready var camera = $Camera

func set_as_current(v :bool):
	.set_as_current(v)
	
	camera.current = v
