extends BaseEntity
class_name BaseTileUnit

# this is entity that can sync in network enviroment
# only basic sync of positioning & rotation state on y axis
# because this is unit that using tile mechanic as its movement
# current tile also getting tracked

signal on_unit_spotted(unit)
signal on_unit_clicked(unit)
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
export var unit_voice :int # 1=us, 2:viet

# hp
export var hp :int = 3
export var max_hp :int = 3

export var is_dead :bool = false
export var is_selectable :bool = false
export var is_combatan :bool = true
export var margin :float = 0.1
export var spotting_range :int = 2
var current_tile :Vector2

var _is_moving :bool # block some function if this is true
var _is_selected :bool # allow this unit to be selected or not

var _last_tile :Vector2 # last tile leaved
var _last_to :Vector3 # las position leave
var _paths :Array # [TileUnitPath]

var _hidden :bool # permanent invisible
var _spotted :bool # visible or not, but be overide by _hidden
var _current_visible :bool # current state of visible, this dont set value to visible

# for nav and targeting
var tile_map :BaseTileMap

# unit_position is refrence
# change value it also change the root variable value
# for tracking purposes
var unit_position :Dictionary = {} # {Vector2 : [BaseTileUnit]}
var enemy = null # cycle warning set to null
var attack_move :bool
var spotting_area :Array

# multiplayer data to sync
puppet var _puppet_current_tile :Vector2
puppet var _puppet_translation :Vector3

func _ready():
	if is_combatan:
		update_spotting()
		Global.connect("on_global_tick", self, "_on_global_tick")
		connect("on_current_tile_updated", self, "_on_current_tile_updated")
		connect("on_finish_travel", self, "_on_current_tile_updated")

func move_to(tile_id :Vector2):
	if is_dead:
		return
		
	if not _is_master or not is_instance_valid(tile_map):
		return
		
	enemy = null
	
	var v :Array = _get_tile_path(tile_id)
	if v.empty():
		return
		
	_is_moving = true
	_paths.clear()
	_paths.append_array(v)
	
func is_moving() -> bool:
	return _is_moving
	
func _get_tile_path(to :Vector2) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = tile_map.get_navigation(current_tile, to, [], false)
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
	
# only mechanic for puppet side only
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
	
func is_selected() -> bool:
	return _is_selected
	
remote func _stop():
	_is_moving = false
	_paths.clear()
	
func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_current_tile", current_tile)
		
func last_sync_update() -> void:
	.last_sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset("_puppet_translation", global_position)
		rset("_puppet_current_tile", current_tile)
		
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	var pos :Vector3 = global_position
	if is_instance_valid(enemy):
		if not _is_enemy_in_range():
			enemy = null
			_on_no_enemy()
			return
			
		_on_enemy_in_range(delta, pos, enemy.global_position)
		return
	
	if _paths.empty():
		return
	
	var new_to :Vector3 = _paths.front().pos
	new_to.y = pos.y
	
	if  pos.distance_to(new_to) < margin:
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
	
func _on_enemy_in_range(_delta :float, _pos :Vector3, _enemy_pos :Vector3):
	pass
	
func _on_no_enemy():
	pass
	
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
	
# for active enemy spotting
func _on_global_tick():
	if _is_master and not _is_moving:
		_scan_area()

func _on_current_tile_updated(_unit, _from_id :Vector2, _to_id :Vector2):
	if not _is_master:
		return
		
	update_spotting()
	
	if attack_move:
		_scan_area()
	
func update_spotting():
	spotting_area = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), current_tile, spotting_range
	)
	
# check wheter enemy stil in spotting range or not
func _is_enemy_in_range() -> bool:
	if enemy.is_dead or unit_position.empty():
		return false
		
	for pos in spotting_area:
		if not unit_position.has(pos):
			continue
			
		var unit_positions :Array = unit_position[pos]
		if unit_positions.has(enemy):
			return true
		
	return false
	
func _scan_area():
	if unit_position.empty() or is_instance_valid(enemy):
		return
		
	for pos in spotting_area:
		if not unit_position.has(pos):
			continue
			
		var unit_positions :Array = unit_position[pos]
		if unit_positions.empty():
			continue
			
		for unit in unit_positions:
			if is_instance_valid(unit):
				if unit.team != team:
					enemy = unit
					return
		
func take_damage(damage :int):
	if is_dead:
		return
		
	hp = int(clamp(hp - damage, 0, max_hp))
	rpc_unreliable("_taking_damage", damage, hp)
	
	if hp <= 0:
		set_dead()
	
remotesync func _taking_damage(damage :int, hp_left: int):
	hp = hp_left
	taking_damage(damage, hp, max_hp)
	
func taking_damage(_damage :int, _hp: int, _max_hp :int):
	pass
	
func set_dead(use_rpc :bool = true):
	if is_dead:
		return
	
	if use_rpc:
		rpc("_set_dead")
	else:
		_set_dead()
	is_dead = true # safeguard, make faster
	
func on_dead():
	emit_signal("on_unit_dead", self)

remotesync func _set_dead():
	is_dead = true
	on_dead()

# just for decoration
func clone_mesh() -> Spatial:
	return null








