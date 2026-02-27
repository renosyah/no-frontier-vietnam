extends BaseTileUnit
class_name Vehicle

signal on_vehicle_drop_passenger(vehicle, passengers)

export var altitude :float
export var is_air :bool
export var capacity :int = 1
export var team_color_material :SpatialMaterial

var squad :BaseSquad
var passengers :Array # [ InfantrySquad ]

var _on_task :bool
var _altitude :float

puppet var _puppet_rotation_y :float

func _ready():
	_altitude = altitude
	
func move_to(tile_id :Vector2):
	if _on_task or is_dead:
		return
	
	.move_to(tile_id)
	
func drop_passenger():
	if passengers.empty():
		return
		
	emit_signal("on_vehicle_drop_passenger", self, passengers.duplicate())
	passengers.clear()
	
func have_task():
	return _on_task
	
func prepare_take_passenger():
	pass
	
func take_passenger(squads :Array):
	passengers.append_array(squads)
	
func _get_tile_path(to :Vector2) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = tile_map.get_navigation(current_tile, to, [], is_air)
	for id in p:
		var pos3 = tile_map.get_tile_instance(id).global_position
		paths.append(TileUnitPath.new(id, pos3))
		
	return paths
	
func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		
func master_moving(_delta :float) -> void:
	.master_moving(_delta)
	
	translation.y = lerp(translation.y, _altitude, 2 * _delta)
	
# overide move_to_path
func _move_to_path(delta :float, pos :Vector3, to :Vector3):
	if _altitude < (0.5):
		return
		
	var dir_to :Vector3 = pos.direction_to(to)
	var t:Transform = transform.looking_at(to, Vector3.UP)
	transform = transform.interpolate_with(t, 2 * delta)
	
	var foward_dir = (-global_transform.basis.z)
	if foward_dir.dot(dir_to) > 0.75:
		translation += dir_to * speed * delta
		
	rotation.x = 0
	rotation.z = 0
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
		
func on_dead():
	.on_dead()
	
	if passengers.empty():
		return
	
	# all onboard fking dead
	for i in passengers:
		var passenger :InfantrySquad = i
		for m in passenger.members:
			m.set_dead(false) # call without rpc
	
