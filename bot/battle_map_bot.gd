extends Node
class_name BattleMapBot

export var attack_chance :float = 0.4
export var move_chance :float = 0.7

var team :int
var units :Array = [] # [ BaseTileUnit ]
var battle_map_unit_positions :Dictionary = {} # { BaseTileMap (battle map):{Vector2:[ BaseTileUnit ] }}

var _rng :RandomNumberGenerator
onready var _timer = $Timer

func _ready():
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	_timer.start()

func _on_Timer_timeout():
	_timer.start()
	
	if units.empty():
		return
		
	if _rng.randf() < attack_chance:
		_order_unit_attack()
		return
		
	if _rng.randf() < move_chance:
		_order_unit_move()
		return

func _order_unit_move():
	var unit :BaseTileUnit = units.pick_random()
	if not is_instance_valid(unit):
		units.erase(unit)
		return
		
	var unit_map :BaseTileMap = unit.tile_map
	var range_move :int = int(_rng.randf_range(2, 5))
	var tiles :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), unit.current_tile, range_move)
	
	var cop = []
	for i in tiles:
		if not unit_map.is_nav_enable(i):
			continue
			
		if is_occupied(i):
			continue
			
		cop.append(i)
		
	unit.attack_move = false
	unit.move_to(cop.pick_random())
	
func is_occupied(id :Vector2) -> bool:
	for i in units:
		var unit :BaseTileUnit = i
		if not is_instance_valid(unit):
			return false
		
		if unit.current_tile == id:
			return true
		
	return false
	
func _order_unit_attack():
	var unit :BaseTileUnit = units.pick_random()
	if not is_instance_valid(unit):
		units.erase(unit)
		return
		
	var enemy = _get_enemy(unit.tile_map)
	if not is_instance_valid(enemy):
		return
		
	unit.attack_move = true
	unit.move_to(enemy.current_tile)
		
func _get_enemy(battle_map :BaseTileMap) -> BaseTileUnit:
	if not battle_map_unit_positions.has(battle_map):
		return null
		
	var unit_positions :Dictionary = battle_map_unit_positions[battle_map]
	for id in unit_positions.keys():
		if unit_positions[id].empty():
			continue
			
		for i in unit_positions[id]:
			var unit :BaseTileUnit = i
			if not is_instance_valid(unit):
				return null
				
			if unit.team != team:
				return i
				
	return null
