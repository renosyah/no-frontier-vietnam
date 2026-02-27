extends BaseGameplay

onready var battle_map_bot = $battle_map_bot

func _ready():
	battle_map_bot.team = 3
	battle_map_bot.battle_map_unit_positions = battle_map_unit_positions

func on_grand_map_squad_spawned(unit :BaseTileUnit):
	.on_grand_map_squad_spawned(unit)
	
	if unit.player_id == "BOT_1" and unit is InfantrySquad:
		battle_map_bot.units.append_array(unit.members)
		
	if unit.player_id == "BOT_1" and unit is VehicleSquad:
		battle_map_bot.units.append(unit.vehicle)
