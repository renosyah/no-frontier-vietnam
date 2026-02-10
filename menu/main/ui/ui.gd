extends Control

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().quit()
	
func _on_editor_pressed():
	Global.change_scene("res://menu/editor_menu/editor_menu.tscn")

func _on_play_pressed():
	Global.change_scene("res://menu/lobby/lobby.tscn", true, 2)



