extends Node
class_name ReservedTile

static func get_base_reseved_tiles(at :Vector2, _spaces :int = 0) -> Array:
	var tiles :Array = []
	var hq = [
		at, at + Vector2.RIGHT,
		at + Vector2.DOWN, at + Vector2.RIGHT + Vector2.DOWN
	]
	var directions = TileMapUtils.get_directions()
	for i in directions:
		for x in hq:
			tiles.append(x + i * (2 + _spaces))
		
	return tiles + hq
 
static func get_transit_point_reseved_tiles(dirs :Array, map_size :int = 1) -> Array:
	var v = []
	for i in dirs:
		v.append(i * map_size)
		
	return v
