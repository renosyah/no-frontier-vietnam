extends Spatial
onready var animation_player = $AnimationPlayer

func tap():
	animation_player.play("tap")
