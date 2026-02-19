extends BaseEntity
class_name BaseTileUnit

# this is entity that can sync in network enviroment
# only basic sync of positioning & rotation state on y axis
# because this is unit that using tile mechanic as its movement
# current tile also getting tracked

signal on_unit_spotted(unit)
signal on_unit_selected(unit, selected)
signal on_current_tile_updated(unit, from_id, to_id)
signal on_finish_travel(unit, last_id, current_id)
signal on_unit_dead(unit)

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

# hp
export var hp :int = 3
export var max_hp :int = 3

export var is_dead :bool = false
export var is_selectable :bool = false

var current_tile :Vector2

var _is_moving :bool # block some function if this is true
var _is_selected :bool # allow this unit to be selected or not

var _last_tile :Vector2 # last tile leaved
var _last_to :Vector3 # las position leave
var _paths :Array # [TileUnitPath]

var _hidden :bool # permanent invisible
var _spotted :bool # visible or not, but be overide by _hidden
var _current_visible :bool # current state of visible 

var tile_map :BaseTileMap

# multiplayer data to sync
puppet var _puppet_current_tile :Vector2
puppet var _puppet_translation :Vector3

func move_to(tile_id :Vector2):
	if not _is_master or not is_instance_valid(tile_map):
		return
		
	var v :Array = _get_tile_path(tile_id)
	if v.empty():
		return
		
	_paths.clear()
	_paths.append_array(v)
	
func _get_tile_path(to :Vector2, _is_air :bool = false) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = tile_map.get_navigation(current_tile, to, [], _is_air)
	for id in p:
		var pos3 = tile_map.get_tile_instance(id).global_position
		paths.append(TileUnitPath.new(id, pos3))
		
	return paths
	
func stop():
	if _is_master:
		_stop()
		return
		
	# call stop, tell master to stop from other peer
	rpc_id(get_network_master(), "_stop")
	
func set_spotted(v :bool):
	if not _is_master and not _hidden:
		_spotted = v
		_current_visible = _spotted
		
	if _current_visible:
		emit_signal("on_unit_spotted", self)
		
func set_hidden(v :bool):
	_hidden = v
	_current_visible = not _hidden

func set_selected(v :bool):
	_is_selected = v
	
remote func _stop():
	_is_moving = false
	_paths.clear()
	
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_current_tile", current_tile)
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead or _paths.empty():
		return
		
	var pos :Vector3 = global_position
	var new_to :Vector3 = _paths.front().pos
	
	if  pos.distance_to(new_to) < 0.1:
		_paths.pop_front()
		
		if _paths.empty():
			_is_moving = false
			emit_signal("on_finish_travel", self, _last_tile, current_tile)
			return
			
		_last_to = new_to
		return
		
	var dist_from = _last_to.distance_squared_to(pos)
	var dist_to = new_to.distance_squared_to(pos)
	var new_tile = _paths.front().tile_id
	
	if dist_from > dist_to and current_tile != new_tile:
		emit_signal("on_current_tile_updated", self, current_tile, new_tile)
		_last_tile = current_tile
		current_tile = new_tile
		
	_move_to_path(delta, pos, new_to)
	_is_moving = true
	
func _move_to_path(delta :float, pos :Vector3, to :Vector3):
	translation += pos.direction_to(to) * speed * delta
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 25 * delta) 
	
	# make sure only send updated
	# this make sure value changes only once
	if current_tile != _puppet_current_tile:
		var old = current_tile
		current_tile = _puppet_current_tile
		emit_signal("on_current_tile_updated", self, old, current_tile)
	
func set_dead():
	if not is_dead:
		rpc("_set_dead")
	
remotesync func _set_dead():
	is_dead = true
	emit_signal("on_unit_dead", self)










