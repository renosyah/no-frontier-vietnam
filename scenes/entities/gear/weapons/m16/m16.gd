extends Weapon

onready var barrel = $barrel
onready var animation_player = $AnimationPlayer
onready var queue_task = $queue_task

func fire_weapon():
	.fire_weapon()
	
	var pos = barrel.global_position
	var to = barrel.global_position + (-barrel.global_transform.basis.z * 10)
	queue_task.add_task(self, "_bang", [pos, to])
	
func stop_firing():
	queue_task.task_queue.clear()

func _bang(_from, _to):
	animation_player.play("bang")
	yield(animation_player, "animation_finished")
