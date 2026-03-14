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
	battle_map_director.contested_tile_object = contested_tile_object
	battle_map_director.blocked_grand_map_tiles = blocked_grand_map_tiles

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
	
func _on_battle_map_director_spawn_battle_map(tile_id :Vector2):
	rpc("_spawn_battle_map", tile_id, battle_map_pos[tile_id])
	
func _on_battle_map_director_captured_battle_map(tile_id):
	bot_stats_bonus = int(clamp(bot_stats_bonus + 1, -8, 2))
	bot_hp_bonus = int(clamp(bot_hp_bonus + 1, -4, 4))
	rpc("_captured_battle_map", tile_id)

func _on_battle_map_director_update_contested_points(values :Array):
	rpc_unreliable("_update_contested_points", values)

var bot_stats_bonus :int = -8
var bot_hp_bonus :int = -4

func _on_battle_map_director_spawn_unit_to_battle_map(tile_id :Vector2, bot_count :int):
	var bot_id :String = "BOT_1"
	var infantry_squad :InfantrySquadData = preload("res://data/unit_data/squad/infantry_squad.tres").duplicate()
	infantry_squad.player_network_id = 1
	infantry_squad.player_id = bot_id
	infantry_squad.unit_name = "squad_infantry_%s" % Utils.create_unique_id()
	infantry_squad.team = 0
	infantry_squad.current_tile = tile_id
	infantry_squad.position = grand_map.get_tile_instance(tile_id).global_position
	infantry_squad.unit_voice = 2
	
	infantry_squad.members = []
	for i in bot_count:
		var stats :UnitStatsData = UnitStatsData.new()
		stats.soldier_name = SoldierNames.get_random_viet_name()
		stats.randomize_stats(bot_stats_bonus)
		
		var infantry :InfantryData = preload("res://data/unit_data/infantry/nva_riflement.tres").duplicate()
		infantry.player_network_id = 1
		infantry.player_id = bot_id
		infantry.unit_name = "infantry_%s_%s" % [Utils.create_unique_id(), i]
		infantry.team = 0
		infantry.current_tile = Vector2.ZERO
		infantry.speed = 1.3
		infantry.position = Vector3.ZERO
		infantry.scene_index = 0
		
		infantry.modified_max_hp = stats.get_max_hp(3 + bot_hp_bonus) 
		infantry.modified_speed = stats.get_speed_multiplier()
		infantry.stats = stats
		infantry.role = infantry.role_riflement
		infantry.faction = 0 # no faction
		infantry.make_variant()
		
		infantry_squad.members.append(infantry)
		
	rpc("_spawn_grand_map_infantry_squad", infantry_squad.to_bytes())



















