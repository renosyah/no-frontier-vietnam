extends Node
class_name BattleMapDirector

signal spawn_battle_map(tile_id)
signal despawn_battle_map(tile_id)

export var limit_battle_map :int = 2
export var capture_point_value :int = 1

var grand_map :BaseTileMap # refrence from gameplay
var unit_position_manager :UnitPositionManager # refrence from gameplay
var zoomable_battle_map :Dictionary # [Vector2 : TileMapData (grand map)] refrence from gameplay
var battle_map_pos :Dictionary  # [Vector2 : Vector3] refrence from gameplay
var capture_points :Dictionary # refrence from gameplay
var contested_battle_map :Dictionary # refrence from gameplay

onready var _rng :RandomNumberGenerator = RandomNumberGenerator.new()
onready var _dynamic_battle_maps :Array = [] # this just prevent more spawning battle map out of control
onready var _timer = $Timer

func _ready():
	_rng.randomize()
	_timer.start()
	
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
	if not _dynamic_battle_maps.empty():
		for id in _dynamic_battle_maps:
			var team :int = _get_team_capture_tile(id)
			# tile id = id
			# team & capture_point_value
			
	if not capture_points.empty():
		for id in capture_points.keys():
			var team :int = _get_team_capture_tile(id)
			# tile id = id
			# team & capture_point_value
			
	# notify gameplay
	# ???
	# TODO

func _get_team_capture_tile(tile_id :Vector2) -> int:
	var unit_position :Dictionary = unit_position_manager.get_positions(grand_map)
	if not unit_position.has(tile_id):
		return 0
	
	for tile_id in unit_position.keys():
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
























