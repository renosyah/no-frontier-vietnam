extends Weapon

const bullet_scene = preload("res://scenes/entities/projectiles/bullet/bullet.tscn")

onready var barrel = $barrel
onready var animation_player = $AnimationPlayer
onready var queue_task = $queue_task

var bullets :Array = []

func _ready():
	for i in 32:
		var bullet = bullet_scene.instance()
		add_child(bullet)
		bullets.append(bullet)

func _get_ready_bullet() -> BaseProjectile:
	for i in bullets:
		if i.is_ready:
			return i
			
	return null

# override
func fire_weapon():
	queue_task.add_task(self, "_bang")
	
func _on_weapon_fired():
	shot_from = barrel.global_position
	._on_weapon_fired()
	
func stop_firing():
	queue_task.task_queue.clear()
	
func firing() -> bool:
	return not queue_task.task_queue.empty()
	
func _on_fire_at(pos :Vector3):
	._on_fire_at(pos)
	
	var bullet = _get_ready_bullet()
	if bullet != null:
		bullet.translation = shot_from
		bullet.to = pos
		bullet.launch()
		
func _bang():
	if is_master:
		if not has_ammo():
			yield(get_tree(), "idle_frame")
			return
			
		ammo = int(clamp(ammo - 1, 0, capacity))
		
	animation_player.play("bang")
	yield(animation_player, "animation_finished")
	
	emit_signal("weapon_fired")
