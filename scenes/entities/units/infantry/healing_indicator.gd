extends Spatial

onready var animation_player = $AnimationPlayer

func healed():
	if animation_player.is_playing():
		return
		
	animation_player.play("healed")
