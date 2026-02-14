extends BaseTileUnit

func set_paths(v :Array):
	.set_paths(v)
	
	if _is_master:
		Global.unit_responded(RadioChatters.COMMAND_ACKNOWLEDGEMENT)
		
func _on_squad_on_current_tile_updated(unit, from_id, to_id):
	if _is_master:
		Global.unit_responded(RadioChatters.MOVEMENT)

func _on_squad_on_finish_travel(unit):
	if _is_master:
		Global.unit_responded(RadioChatters.AREA_CLEAR)
