extends Weapon

const bullet_scene = preload("res://scenes/entities/projectiles/bullet/bullet.tscn")

onready var barrel = $barrel
onready var animation_player = $AnimationPlayer
onready var queue_task = $queue_task

var bullets :Array = []

func _ready():
	queue_task.connect("finish", self, "_on_queue_task_finish")
	
	for i in 32:
		var bullet = bullet_scene.instance()
		add_child(bullet)
		bullets.append(bullet)
		
func _get_ready_bullet() -> BaseProjectile:
	for i in bullets:
		if i.is_ready:
			return i
			
	return null

func _on_queue_task_finish():
	emit_signal("weapon_finish_firing")

# override
func fire_weapon(count :int):
	shot_from = barrel.global_position
	var to = random_point_around(shot_at, dispersion)
	
	if is_master:
		_hit_detection(to)
		
	for i in count:
		queue_task.add_task(self, "_bang", [to])
		to = random_point_around(shot_at, dispersion)

func _hit_detection(to):
	var result :Dictionary = get_world().direct_space_state.intersect_ray(
		shot_from, to, [unit_owner], 1, false, true
	)
	if result.empty():
		return
		
	if result["collider"] is HitRegister:
		var hr :HitRegister = result["collider"]
		hr.take_damage(damage, team)
		
func stop_firing():
	queue_task.clear()
	
func firing() -> bool:
	return queue_task.is_running
	
func _bang(to :Vector3):
	if is_master:
		ammo = int(clamp(ammo - 1, 0, capacity))
		
	animation_player.play("bang")
	yield(animation_player, "animation_finished")
	
	var bullet = _get_ready_bullet()
	if bullet != null:
		bullet.translation = shot_from
		bullet.to = to
		bullet.launch()
		
	emit_signal("weapon_fired")
