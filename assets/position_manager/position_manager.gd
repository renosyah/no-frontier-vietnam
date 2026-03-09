extends Node
class_name UnitPositionManager

var _tile_map_unit_positions :Dictionary = {} # { BaseTileMap (battle map):{Vector2:[ BaseTileUnit ] }}

func get_positions(tile_map :BaseTileMap) -> Dictionary:
	if not has_set(tile_map):
		return {}
		
	return _tile_map_unit_positions[tile_map]

func init_position(tile_map :BaseTileMap, size :int):
	if not has_set(tile_map):
		_tile_map_unit_positions[tile_map] = {}
		
	# initiated empty positions
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		Vector2.ZERO,
		size
	)
	for id in tiles:
		_tile_map_unit_positions[tile_map][id] = []

func has_set(tile_map :BaseTileMap) -> bool:
	return _tile_map_unit_positions.has(tile_map)

func units_in_position(tile_map :BaseTileMap, tile :Vector2) -> Array:
	if not has_set(tile_map):
		return []
		
	if not _tile_map_unit_positions[tile_map].has(tile):
		return []
	
	return _tile_map_unit_positions[tile_map][tile]

func add_to_position(tile_map :BaseTileMap, unit :BaseTileUnit):
	if not has_set(tile_map):
		return
		
	var current_tile :Vector2 = unit.current_tile
		
	if not _tile_map_unit_positions[tile_map].has(current_tile):
		_tile_map_unit_positions[tile_map][current_tile] = []
		
	var pos_datas:Array = _tile_map_unit_positions[tile_map][current_tile]
	if pos_datas.has(unit):
		return
		
	pos_datas.append(unit)
	
func update_position(tile_map :BaseTileMap, unit :BaseTileUnit, from:Vector2, to:Vector2):
	if not _tile_map_unit_positions.has(tile_map):
		return
		
	var unit_pos :Dictionary = _tile_map_unit_positions[tile_map]
	if unit_pos.has(from):
		unit_pos[from].erase(unit)
		
	if not unit_pos.has(to):
		unit_pos[to] = []
		
	unit_pos[to].append(unit)

func remove_from_position(tile_map :BaseTileMap, unit :BaseTileUnit):
	if not has_set(tile_map):
		return
		
	var pos_datas:Array = _tile_map_unit_positions[tile_map][unit.current_tile]
	if not pos_datas.has(unit):
		return
		
	pos_datas.erase(unit)
