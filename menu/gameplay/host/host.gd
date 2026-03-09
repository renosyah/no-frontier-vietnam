extends BaseGameplay

onready var battle_map_bot = $battle_map_bot

func _ready():
	battle_map_bot.team = 3
	battle_map_bot.unit_position = unit_position

func on_grand_map_squad_spawned(squad :BaseSquad):
	.on_grand_map_squad_spawned(squad)
	
	if squad.player_id == "BOT_1" and squad is InfantrySquad:
		battle_map_bot.units.append_array(squad.members)
		
	if squad.player_id == "BOT_1" and squad is VehicleSquad:
		battle_map_bot.units.append(squad.vehicle)
