extends BaseTileMap

const non_walkable_mud_tile_scene = preload("res://scenes/tiles/battle_tile/non_walkable_mud_tile.tscn")
const non_walkable_water_tile_scene = preload("res://scenes/tiles/battle_tile/non_walkable_water_tile.tscn")
const walkable_grass_tile_scene = preload("res://scenes/tiles/battle_tile/walkable_grass_tile.tscn")
const walkable_mud_tile_scene = preload("res://scenes/tiles/battle_tile/walkable_mud_tile.tscn")
const walkable_sand_tile_scene = preload("res://scenes/tiles/battle_tile/walkable_sand_tile.tscn")
 
# override
func _spawn_tile(data :TileMapData) -> BaseTile:
	var tile_scene
	match data.tile_type:
		1:
			tile_scene = walkable_grass_tile_scene
		2:
			tile_scene = walkable_mud_tile_scene
		3:
			tile_scene = walkable_sand_tile_scene
		4:
			tile_scene = non_walkable_water_tile_scene
		5:
			tile_scene = non_walkable_mud_tile_scene
			
	var tile :BaseTile = tile_scene.instance()
	add_child(tile)
	tile.translation = data.pos
	return tile
	
# override
func _spawn_object(data :MapObjectData) -> BaseTileObject:
	var obj :BaseTileObject = data.scene.instance()
	add_child(obj)
	obj.name = 'obj_%s' % data.id
	obj.translation = data.pos
	
	return obj

