extends CanvasLayer

onready var _animation_player = $AnimationPlayer
onready var _texture_rect = $transision_screen/TextureRect

const bgs = [
	preload("res://assets/background/editor.png"),
	preload("res://assets/background/main_menu.png"),
	preload("res://assets/background/pre_match.png"),
	preload("res://assets/background/splash_bg.png")
]

var _has_session :bool = false

func change_scene(scene :String, use :bool = false, bg_idx :int = 1):
	if use:
		_texture_rect.texture = bgs[bg_idx]
		_animation_player.play("show")
		
		yield(_animation_player,"animation_finished")
		yield(get_tree().create_timer(1), "timeout")
		_has_session = true
	
	get_tree().change_scene(scene)
	
func hide_transition():
	if _has_session:
		_animation_player.play_backwards("show")
		_has_session = false
