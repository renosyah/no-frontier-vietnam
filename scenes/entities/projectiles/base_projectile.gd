extends Spatial
class_name BaseProjectile

export var to :Vector3
export var speed :float = 12.0
export var is_ready :bool = true
export var max_range :float = 5.0
export var is_master :bool
export var damage :int = 6

var dir :Vector3
var travel_distance :float = 0

func _ready():
	visible = false
	set_process(false)
	set_as_toplevel(true)

func launch():
	visible = true
	dir = global_position.direction_to(to)
	travel_distance = 0
	is_ready = false
	set_process(true)
	look_at(to, Vector3.UP)
	
func on_travel(delta):
	if travel_distance > max_range:
		on_stop()
		return
		
	var vel = speed * delta
	translation += dir * vel
	travel_distance += vel
	
func _process(delta):
	on_travel(delta)
	
func on_stop():
	set_process(false)
	is_ready = true
	visible = false
	
	
	
	



