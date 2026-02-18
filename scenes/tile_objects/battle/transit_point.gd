extends BaseTileObject
class_name BattleMapTransitPoint

signal transit_point_click(t)

var battle_map :BaseTileMap

# tile id if this transit map id tile
var battle_map_tile_id :Vector2

# what tile in grand map this transit point goes to
var grand_map_tile_id :Vector2

onready var label = $label
onready var area = $Area
onready var input_detection = $input_detection

func set_label(v :String):
	label.text = v

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	input_detection.check_input(event)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("transit_point_click", self)
