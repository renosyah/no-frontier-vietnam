extends BaseTileUnit
class_name Vehicle

export var fuel_cost :int = 1
export var fuel :int = 100
export var max_fuel :int = 100

export var altitude :float
export var is_air :bool

var squad :BaseSquad

var _altitude :float
puppet var _puppet_rotation_y :float

func _ready():
	margin = 0.4
	_altitude = altitude
	connect("on_current_tile_updated", self, "_on_current_tile_updated")
	
func move_to(tile_id :Vector2):
	if fuel == 0:
		return
	
	.move_to(tile_id)
	
func drop_passenger():
	pass
	
func _get_tile_path(to :Vector2) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = tile_map.get_navigation(current_tile, to, [], is_air)
	for id in p:
		var pos3 = tile_map.get_tile_instance(id).global_position
		paths.append(TileUnitPath.new(id, pos3))
		
	return paths
	
func _on_current_tile_updated(_unit, _from_id, _to_id):
	fuel = clamp(fuel - fuel_cost, 0, max_fuel)
	
	if fuel == 0:
		stop()

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		
func master_moving(_delta :float) -> void:
	.master_moving(_delta)
	
	translation.y = lerp(translation.y, _altitude, 2 * _delta)
	
# overide move_to_path
func _move_to_path(delta :float, pos :Vector3, to :Vector3):
	if _altitude < (0.5):
		return
		
	var t:Transform = transform.looking_at(to, Vector3.UP)
	transform = transform.interpolate_with(t, 8 * delta)
	translation += -transform.basis.z * speed * delta
	rotation.x = 0
	rotation.z = 0
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
