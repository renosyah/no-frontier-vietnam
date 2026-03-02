extends Control

func _ready():
	yield(_unload_preset_map(),"completed")
	Global.change_scene("res://menu/main/main.tscn", true, 3)

func _unload_preset_map():
	yield(get_tree(), "idle_frame")
	var existing :PoolStringArray = Utils.get_all_resources("user://%s/" % Global.map_dir, ["manifest"])
	if not existing.empty():
		return
		
	yield(Global.copy_preset_map(),"completed")
