extends Node
class_name TileMapUtils

const ARROW_DIRECTIONS = [
	Vector2.UP, Vector2.DOWN, 
	Vector2.LEFT, Vector2.RIGHT,
]

const DIAGONAL_DIRECTIONS = [
	Vector2.UP + Vector2.LEFT,
	Vector2.UP + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.DOWN + Vector2.RIGHT,
]

# size is range of tile map
# for example : 
# 2 → 5 × 5
# 4 → 9 × 9
# 6 → 13 × 13
# 8 → 17 × 17
static func generate_basic_tile_map(size :int, is_grand_map :bool = true) -> TileMapFileData:
	var tiles = get_adjacent_tiles(get_directions(), Vector2.ZERO, size)
	tiles.push_front(Vector2.ZERO)
	
	var tile_datas = []
	var navigations = []
	var tile_ids = {}
	var objects = []
	
	for id in tiles:
		var data :TileMapData = TileMapData.new()
		data.tile_type = 1
		data.id = id
		data.pos = Vector3(id.x, 0, id.y) * (1.02 if is_grand_map else 1.0)
		tile_datas.append(data)
		
		var nav_id = tile_datas.size()
		tile_ids[id] = nav_id
		
	for id in tiles:
		var nav_data :NavigationData = NavigationData.new()
		nav_data.id = id
		nav_data.navigation_id = tile_ids[id]
		nav_data.enable = not Vector2.ZERO
		nav_data.neighbors = []
		
		var _tiles = get_adjacent_tiles(ARROW_DIRECTIONS if is_grand_map else get_directions(), id)
		for i in _tiles:
			if tile_ids.has(i):
				nav_data.neighbors.append(tile_ids[i])
				
		navigations.append(nav_data)
		
	var map_data :TileMapFileData = TileMapFileData.new()
	map_data.tiles = tile_datas
	map_data.tile_ids = tile_ids
	map_data.objects = objects
	map_data.navigations = navigations
	
	return map_data
	
	
# return all adjacent tiles
# with range and type of direction
# only returned tile that registered in Astar navigation
static func get_astar_adjacent_tile(nav :AStar2D, navigation_id: int, radius: int = 1, blocked_nav_ids :Array = []) -> Array:
	var visited := {}
	var result := []
	var queue := [navigation_id]
	visited[navigation_id] = 0
	
	while not queue.empty():
		var current_id = queue.pop_front()
		var current_depth = visited[current_id]
		
		if current_depth >= radius:
			continue
			
		for neighbor_id in nav.get_point_connections(current_id):
			if neighbor_id in visited:
				continue
				
			if nav.is_point_disabled(neighbor_id):
				continue
				
			if blocked_nav_ids.has(neighbor_id):
				continue
				
			visited[neighbor_id] = current_depth + 1
			queue.append(neighbor_id)
			result.append(nav.get_point_position(neighbor_id))
			
	visited.clear()
	queue.clear()
	
	return result # [Vector2]
	
# return all adjacent tiles
# with range and type of direction
static func get_adjacent_tiles(directions :Array, from: Vector2 = Vector2.ZERO, radius: int = 1) -> Array:
	var visited := {}
	var frontier := [from]
	visited[from] = true
	
	for _step in range(radius):
		var next_frontier := []
		for current in frontier:
			for dir in directions:
				var neighbor = current + dir
				if not visited.has(neighbor):
					visited[neighbor] = true
					next_frontier.append(neighbor)
		frontier = next_frontier
		
	# just remove from
	visited.erase(from)
	
	var tiles :Array = visited.keys().duplicate()
	visited.clear()
	
	return tiles # [Vector2]
	
static func get_directions() -> Array:
	return ARROW_DIRECTIONS + DIAGONAL_DIRECTIONS
	
