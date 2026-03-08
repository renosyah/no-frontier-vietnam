extends BaseSquad
class_name InfantrySquad

signal on_infantry_squad_member_died(squad, member)
signal on_infatry_squad_task_enter_vehicle(squad, vehicle)

onready var mesh_instances = [
	$decoration_icon/MeshInstance, $decoration_icon/MeshInstance2,
	$decoration_icon/MeshInstance4, $decoration_icon/MeshInstance5,
	$decoration_icon/MeshInstance3
]
onready var decoration_icon = $decoration_icon
onready var task_checker = $task_checker
onready var rng = RandomNumberGenerator.new()

var members :Array = [] # [ Infantry ]

var _on_stealth_mode :bool

func _ready():
	rng.randomize()
	
	for i in mesh_instances:
		i.set_surface_material(0, team_color_material)
		
func get_avg_pos() -> Vector3:
	var pos :Vector3 = Vector3.ZERO
	var count :int = 0
	for i in members:
		if is_instance_valid(i):
			count += 1
			pos += i.global_position
			
	return (pos / count) + Vector3(0, 1, 0)
	
func _on_global_tick():
	#._on_global_tick()
	
	if not task_checker.is_stopped() or _current_visible:
		return
		
	_check_member_spacing()
	
func _check_member_spacing():
	for i in members:
		var infantry :Infantry = i
		if infantry.is_moving():
			continue
			
		var unit_pos :Dictionary = infantry.unit_position
		if _is_need_spacing(infantry, unit_pos):
			_find_spacing(infantry, infantry.tile_map, unit_pos)
			return
	
func _find_spacing(infantry :Infantry, bm :BaseTileMap, unit_pos :Dictionary):
	var arounds :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		infantry.current_tile,
		1
	)
	
	Utils.shuffle_array(rng, arounds)
	
	for id in arounds:
		if unit_pos.has(id):
			if _is_empty_here(id, unit_pos):
				if bm.has_tile(id) and bm.is_nav_enable(id):
					infantry.move_to(id)
					return
	
func _is_empty_here(id :Vector2, unit_pos :Dictionary, unit = null):
	if unit_pos[id].empty():
		return true
		
	var count_inside :int = 0
	for soldier in unit_pos[id]:
		if not is_instance_valid(soldier):
			return
			
		if unit != null:
			if soldier == unit:
				continue
				
		if soldier.is_moving():
			continue
			
		count_inside += 1
		
	return count_inside == 0
	
func _is_need_spacing(infantry :Infantry, unit_pos :Dictionary) -> bool:
	var id :Vector2 = infantry.current_tile
	if not unit_pos.has(id):
		return false
		
	return not _is_empty_here(id, unit_pos, infantry)
	
func exit_battle_map(at_battle_map_id :Vector2, to_grand_map_id :Vector2):
	if not task_checker.is_stopped():
		return
		
	var _task_completed :bool = false
	while not _task_completed:
		var _all_arived :bool = true
		for i in members:
			var infantry :Infantry = i
			if is_instance_valid(infantry):
				if infantry.current_tile != at_battle_map_id:
					_all_arived = false
					
				else:
					
					# hide unit
					# somewhere far LOL
					infantry.stop()
					infantry.translation = Vector3(-100, -100, -100)
					infantry.set_sync(false)
				
		_task_completed = _all_arived
		
		task_checker.start()
		yield(task_checker,"timeout")
		
	.exit_battle_map(at_battle_map_id, to_grand_map_id)

# i cant declare vehicle type class
# it errr cycle if i do
# at_battle_map_id id is just a id tile on battle map, dont confuse it
func enter_vehicle(at_battle_map_id :Vector2, vehicle):
	if not task_checker.is_stopped():
		return
		
	# case if vehicle is dead
	if not is_instance_valid(vehicle):
		_reasemble_member_around(at_battle_map_id)
		return
		
	var _task_completed :bool = false
	while not _task_completed:
		var _all_arived :bool = true
		for i in members:
			var infantry :Infantry = i
			if is_instance_valid(infantry):
				if infantry.current_tile != at_battle_map_id:
					_all_arived = false
					
				else:
					
					# hide unit
					# somewhere far LOL
					i.stop()
					infantry.translation = Vector3(-100, -100, -100)
					
		_task_completed = _all_arived
		
		task_checker.start()
		yield(task_checker,"timeout")
		
	# case if vehicle is dead
	if not is_instance_valid(vehicle):
		_reasemble_member_around(at_battle_map_id)
		return
		
	for i in members:
		i.set_sync(false)
		
	emit_signal("on_infatry_squad_task_enter_vehicle", self, vehicle)
	
func _reasemble_member_around(tile_id :Vector2 = Vector2.ZERO):
	var arounds :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		tile_id,
		2
	)
	
	for i in members:
		var infantry :Infantry = i
		infantry.current_tile = tile_id
		infantry.is_selectable = true
		infantry.stop()
		
		var bm :BaseTileMap = infantry.tile_map
		var def_pos = bm.get_tile_instance(tile_id)
		var front = arounds.front()
		
		if bm.has_tile(front) and bm.is_nav_enable(front):
			infantry.current_tile = front
			infantry.translation = bm.get_tile_instance(front).global_position
			
		else:
			infantry.translation = def_pos.global_position
			
		arounds.pop_front()
		
func enter_stealth_mode(v :bool):
	if _is_moving:
		return
		
	if _is_master:
		rpc("_enter_stealth_mode", v)
		
remotesync func _enter_stealth_mode(v :bool):
	_on_stealth_mode = v
	
func is_stealth_mode() -> bool:
	return _on_stealth_mode
	
# cannot move on stealth mode
func move_to(tile_id :Vector2):
	if is_stealth_mode():
		return
	
	.move_to(tile_id)
	
# cannot be spotted on stealth mode
func set_spotted(v :bool):
	if is_stealth_mode():
		return
	
	.set_spotted(v)
	
	decoration_icon.visible = _current_visible
	
func set_hidden(v :bool):
	.set_hidden(v)
	
	decoration_icon.visible = _current_visible
	
func _on_member_dead(unit):
	if members.has(unit):
		members.erase(unit)
		
	if members.empty():
		emit_signal("on_squad_destroyed", self)
		return
		
	emit_signal("on_infantry_squad_member_died", self , unit)
	
