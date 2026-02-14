extends BaseEntity
class_name BaseTileUnit

# this is entity that can sync in network enviroment
# only basic sync of positioning & rotation state on y axis
# because this is unit that using tile mechanic as its movement
# current tile also getting tracked

signal on_current_tile_updated(unit, from_id, to_id)
signal on_finish_travel(unit)

class TileUnitPath:
	var tile_id :Vector2
	var pos :Vector3
	
	func _init(a,b):
		tile_id = a
		pos = b

# info
export var team :int = 0
export var color :Color = Color.white
export var speed :float = 0.4

export var is_dead :bool = false
export var is_selectable :bool = false

var _paths :Array # [TileUnitPath]
var current_tile :Vector2

var _last_to :Vector3

puppet var _puppet_current_tile :Vector2
puppet var _puppet_translation :Vector3
puppet var _puppet_rotation_y :float

func set_paths(v :Array):
	if _is_master:
		_paths.clear()
		_paths.append_array(v)

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		rset_unreliable("_puppet_current_tile", current_tile)
		
# so current tile updated is base on
# ON when goes to next path, current tile is updated
# yea, so unit still on old tile but give signal it "will" enter next tile
# this will result in early detection, but nah, fine
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead or _paths.empty():
		return
		
	var pos :Vector3 = global_position
	var new_to :Vector3 = _paths.front().pos
	
	if  pos.distance_to(new_to) < 0.1:
		_paths.pop_front()
		
		if _paths.empty():
			emit_signal("on_finish_travel", self)
			return
			
		_last_to = new_to
		return
		
	var dist_from = _last_to.distance_squared_to(pos)
	var dist_to = new_to.distance_squared_to(pos)
	var new_tile = _paths.front().tile_id
	
	if dist_from > dist_to and current_tile != new_tile:
		emit_signal("on_current_tile_updated", self, current_tile, new_tile)
		current_tile = new_tile
		
	translation += pos.direction_to(new_to) * speed * delta
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, delta)
	translation = _puppet_translation
	
	# make sure only send updated
	# this make sure value changes only once
	if current_tile != _puppet_current_tile:
		var old = current_tile
		current_tile = _puppet_current_tile
		emit_signal("on_current_tile_updated", self, old, current_tile)
