extends BaseEntity
class_name BaseTileUnit

# this is entity that can sync in network enviroment
# only basic sync of positioning & rotation state on y axis
# because this is unit that using tile mechanic as its movement
# current tile also getting tracked

signal on_current_tile_updated(from_id, to_id)
signal on_reach

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

var paths :Array # [TileUnitPath]
var current_tile :Vector2

puppet var _puppet_current_tile :Vector2
puppet var _puppet_translation :Vector3
puppet var _puppet_rotation_y :float

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		rset_unreliable("_puppet_current_tile", current_tile)
		
# so current tile updated is base on
# ON when goes to next path, current tile is updated
# yea, so unit still on old tile but give signal it "will" enter next tile
# this will result in early detection, but nah, fine
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead or paths.empty():
		return
		
	var pos :Vector3 = global_position
	var to :Vector3 = paths.front().pos
	
	if pos.distance_to(to) < 0.1:
		var old :Vector2 = current_tile
		paths.pop_front()
		
		if paths.empty():
			emit_signal("on_reach")
			return
			
		current_tile = paths.front().tile_id
		emit_signal("on_current_tile_updated", old, current_tile)
		return
	
	translation += pos.direction_to(to) * speed * delta
	
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
		emit_signal("on_current_tile_updated",old , current_tile)
