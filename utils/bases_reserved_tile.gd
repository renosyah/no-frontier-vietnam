extends Node
class_name BaseReservedTile

static func getBaseResevedTiles(at :Vector2, _spaces :int = 0) -> Array:
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
 
