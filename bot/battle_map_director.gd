extends Node
class_name BattleMapDirector

signal update_contested_points(values)
signal spawn_battle_map(tile_id)
signal despawn_battle_map(tile_id)

export var limit_battle_map :int = 2
export var capture_point_value :int = 10

var grand_map :BaseTileMap # refrence from gameplay
var unit_position_manager :UnitPositionManager # refrence from gameplay
var zoomable_battle_map :Dictionary # [Vector2 : TileMapData (grand map)] refrence from gameplay
var battle_map_pos :Dictionary  # [Vector2 : Vector3] refrence from gameplay
var contested_tile_object :Dictionary # refrence from gameplay

onready var _rng :RandomNumberGenerator = RandomNumberGenerator.new()
onready var _dynamic_battle_maps :Array = [] # this just prevent more spawning battle map out of control
onready var _timer = $Timer

func _ready():
	_rng.randomize()
	_timer.start()
	
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
	var values :Array = [] # [ [tile_object node_path, team_capturing, team_owner, point] ]
	for tile_id in contested_tile_object.keys():
		var team_capturing :int = _get_team_capture_tile(tile_id)
		var tile_object :ContestedTile = contested_tile_object[tile_id]
		
		# dont do shit if none capture
		if team_capturing == 0 and tile_object.team != 0:
			continue
			
		var max_point =  tile_object.max_point
		
		if tile_object.point == 0:
			tile_object.team = team_capturing
		
		if tile_object.team == team_capturing:
			if tile_object.point < max_point:
				
				# before reach actual max
				# check then notify
				if (tile_object.point + capture_point_value) == max_point:
					# notify only if actual player team capturing
					if tile_object.team != 0:
						_on_point_fully_captured(tile_id)
				
				tile_object.point = tile_object.point + capture_point_value
				
		else:
			if tile_object.point > 0:
				tile_object.point = tile_object.point - capture_point_value
			
		values.append([
			tile_id,
			tile_object.get_path(),
			tile_object.team,
			tile_object.point
		])
		
	emit_signal("update_contested_points", values)
	
func _on_point_fully_captured(tile_id :Vector2):
	
	# will only despawn dynamic battle map
	# it will not touch bases or capture point
	if _dynamic_battle_maps.has(tile_id):
		_dynamic_battle_maps.erase(tile_id)
		emit_signal("despawn_battle_map", tile_id)

# check if squad from each team is present on said tile_id
# if none or more than one, dont return 0
func _get_team_capture_tile(tile_id :Vector2) -> int:
	var unit_position :Dictionary = unit_position_manager.get_positions(grand_map)
	if not unit_position.has(tile_id):
		return 0
	
	var teams :Array = _get_teams(unit_position[tile_id])
	if teams.size() == 1:
		return teams[0]
		
	return 0
	
func _get_teams(units :Array) -> Array:
	var teams :Array = []
	for i in units:
		var unit :BaseTileUnit = i
		if not is_instance_valid(unit):
			continue
			
		if not teams.has(unit.team):
			teams.append(unit.team)
			
	return teams
	
func _on_Timer_timeout():
	_rng.randomize()
	_timer.start()
	
	if _dynamic_battle_maps.size() < limit_battle_map:
		_spawn_battle_map()
	
func battle_map_spawned(tile_id :Vector2 ):
	_dynamic_battle_maps.append(tile_id)
	
func _despawn_battle_map(tile_id :Vector2):
	emit_signal("despawn_battle_map", tile_id)
	
func _spawn_battle_map():
	var clean :Array = []
	for key in battle_map_pos.keys():
		if zoomable_battle_map.has(key):
			continue
			
		clean.append(key)
		
	if clean.empty():
		return
		
	Utils.shuffle_array(_rng, clean)
	emit_signal("spawn_battle_map", clean.pick_random())
























