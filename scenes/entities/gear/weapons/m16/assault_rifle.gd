extends Weapon

const bullet_scene = preload("res://scenes/entities/projectiles/bullet/bullet.tscn")

const shot_sounds = [
	preload("res://assets/sounds/weapons/shot_1.wav"),
	preload("res://assets/sounds/weapons/shot_2.wav"),
	preload("res://assets/sounds/weapons/shot_3.wav")
]

onready var barrel = $barrel
onready var animation_player = $AnimationPlayer
onready var queue_task = $queue_task

var _bullets :Array = []

func _ready():
	queue_task.connect("finish", self, "_on_queue_task_finish")
	
	for i in 32:
		var bullet = bullet_scene.instance()
		add_child(bullet)
		_bullets.append(bullet)
		
func get_shot_sound() -> AudioStream:
	return shot_sounds.pick_random()
	
func _get_ready_bullet() -> BaseProjectile:
	for i in _bullets:
		if i.is_ready:
			return i
			
	return null

func _on_queue_task_finish():
	emit_signal("weapon_finish_firing")

# override
func fire_weapon(count :int):
	shot_from = barrel.global_position
	var dist = shot_from.distance_to(shot_at)
	
	if is_master:
		if _rng.randf() < durability_damage_chance:
			durability = clamp(durability - durability_decrease_rate, 0, max_durability)
	
	for i in count:
		var to = random_point_around(shot_at, dispersion)
		queue_task.add_task(self, "_bang", [dist, to])
	
func stop_firing():
	queue_task.clear()
	
func firing() -> bool:
	return queue_task.is_running
	
func _bang(dist :float, to :Vector3):
	if is_master:
		ammo = int(clamp(ammo - 1, 0, capacity))
		
	animation_player.play("bang")
	yield(animation_player, "animation_finished")
	
	var bullet = _get_ready_bullet()
	if bullet != null:
		bullet.translation = shot_from
		bullet.to = to
		bullet.max_range = dist
		bullet.launch()
		
	emit_signal("weapon_fired")
