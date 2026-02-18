extends BaseTileObject
class_name BattleMapTransitPoint

# tile id if this transit map id tile
var battle_map_tile_id :Vector2

# what tile in grand map this transit point goes to
var grand_map_tile_id :Vector2

onready var label = $label

func set_label(v :String):
	label.text = v
