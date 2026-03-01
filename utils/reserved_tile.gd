extends Node
class_name ReservedTile

static func get_hq_tiles(at :Vector2 = Vector2(-1, -1)) -> Array:
	return [
		at, at + Vector2.RIGHT,
		at + Vector2.DOWN, 
		at + Vector2.RIGHT + Vector2.DOWN
	]

# this will get 2x2 with up and side each 3
# not really proposional, this is abandond now!
static func get_base_reseved_tiles(at :Vector2 = Vector2(-1, -1), _spaces :int = 0) -> Array:
	var tiles :Array = []
	var hq = get_hq_tiles(at)
	var directions = TileMapUtils.get_directions()
	for i in directions:
		for x in hq:
			tiles.append(x + i * (2 + _spaces))
		
	return tiles + hq
