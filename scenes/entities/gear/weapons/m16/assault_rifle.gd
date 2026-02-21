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
	if not has_ammo():
		yield(get_tree(),"idle_frame")
		emit_signal("weapon_fired")
		return
		
	animation_player.play("bang")
	yield(animation_player, "animation_finished")
	emit_signal("weapon_fired")
