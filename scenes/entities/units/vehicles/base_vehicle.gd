extends BaseTileUnit
class_name BaseVehicle

export var fuel_cost :int = 1
export var fuel :int = 100
export var max_fuel :int = 100

puppet var _puppet_rotation_y :float

func _ready():
	connect("on_current_tile_updated", self, "_on_current_tile_updated")
	
func set_paths(v :Array):
	if not _is_master or v.empty() or fuel == 0:
		return
		
	.set_paths(v)
	
func _on_current_tile_updated(_unit, _from_id, _to_id):
	fuel = clamp(fuel - fuel_cost, 0, max_fuel)
	
	if fuel == 0:
		stop()

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_rotation_y", global_rotation.y)

# overide move_to_path
func move_to_path(delta :float, pos :Vector3, to :Vector3):
	var dir: Vector3 = pos.direction_to(to)
	var t: Transform = transform.looking_at(dir * 100, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	translation += -transform.basis.z * speed * delta
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, delta)
