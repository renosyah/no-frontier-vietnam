extends Node
class_name BattleMapDirector

signal spawn_battle_map(tile_id)
signal despawn_battle_map(tile_id)

export var limit_battle_map :int = 2

var grand_map :BaseTileMap # refrence from gameplay
var unit_position_manager :UnitPositionManager # refrence from gameplay
var zoomable_battle_map :Dictionary # [Vector2 : TileMapData (grand map)] refrence from gameplay
var battle_map_pos :Dictionary = {} # [Vector2 : Vector3] refrence from gameplay
var contested_battle_map :Dictionary # refrence from gameplay

onready var _rng :RandomNumberGenerator = RandomNumberGenerator.new()
onready var _dynamic_battle_maps :Array = [] # this just prevent more spawning battle map out of control
onready var _timer = $Timer

func _ready():
	_rng.randomize()
	_timer.start()
	
func _on_Timer_timeout():
	_rng.randomize()
	_timer.start()
	
	if _dynamic_battle_maps.size() < limit_battle_map:
		_spawn_battle_map()
		
	else:
		_despawn_battle_map()
	
func battle_map_spawned(tile_id :Vector2 ):
	_dynamic_battle_maps.append(tile_id)
	
func _despawn_battle_map():
	emit_signal("despawn_battle_map", _dynamic_battle_maps.front())
	_dynamic_battle_maps.pop_front()
	
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
























