extends BaseGameplay

onready var battle_map_bot = $battle_map_bot
onready var battle_map_director = $battle_map_director

func _ready():
	battle_map_bot.team = 3
	battle_map_bot.unit_position_manager = unit_position_manager
	
	battle_map_director.grand_map = grand_map
	battle_map_director.unit_position_manager = unit_position_manager
	battle_map_director.battle_map_pos = battle_map_pos
	battle_map_director.zoomable_battle_map = zoomable_battle_map
	battle_map_director.contested_battle_map = contested_battle_map
	battle_map_director.capture_points = capture_points

func on_grand_map_squad_spawned(squad :BaseSquad):
	.on_grand_map_squad_spawned(squad)
	
	if squad.player_id == "BOT_1" and squad is InfantrySquad:
		battle_map_bot.units.append_array(squad.members)
		
	if squad.player_id == "BOT_1" and squad is VehicleSquad:
		battle_map_bot.units.append(squad.vehicle)
		
# because this function is called via RPC
# imidiately enter a battle map
# call function via non rpc
func on_dynamic_battle_map_spawned(tile_id :Vector2, battle_map :BaseTileMap):
	.on_dynamic_battle_map_spawned(tile_id, battle_map)
	
	battle_map_director.battle_map_spawned(tile_id)
	
	for i in spawned_squad:
		var squad :BaseSquad = i
		if squad.current_tile == tile_id:
			squad.stop(false)
			squad.set_hidden(true)
			order_squad_to_enter_battle_map(squad, tile_id, tile_id)
			
func _on_battle_map_director_spawn_battle_map(tile_id :Vector2):
	rpc("_spawn_battle_map", tile_id, battle_map_pos[tile_id])

func _on_battle_map_director_despawn_battle_map(tile_id):
	rpc("_despawn_battle_map", tile_id)



















