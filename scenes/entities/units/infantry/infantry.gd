extends BaseTileUnit
class_name Infantry

const punch = preload("res://assets/sounds/weapons/punch.wav")
const reload_sound = preload("res://assets/sounds/weapons/reload.wav")
const shot_sounds = [
	preload("res://assets/sounds/weapons/shot_1.wav"),
	preload("res://assets/sounds/weapons/shot_2.wav"),
	preload("res://assets/sounds/weapons/shot_3.wav")
]
const dead_sounds = [
	preload("res://assets/sounds/infantry/dead_1.wav"),
	preload("res://assets/sounds/infantry/dead_2.wav"),
	preload("res://assets/sounds/infantry/dead_3.wav"),
	preload("res://assets/sounds/infantry/dead_4.wav"),
	preload("res://assets/sounds/infantry/dead_5.wav")
]

const rocket_projectile_scene = preload("res://scenes/entities/projectiles/rocket/rocket_projectile.tscn")
const grenade_projectile_scene = preload("res://scenes/entities/projectiles/grenade/grenade.tscn")
const selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")

export var role :int
export var skin_material :SpatialMaterial
export var uniform_material :SpatialMaterial
export var team_color_material :SpatialMaterial
export var hat_scene :PackedScene
export var bag_scene :PackedScene
export var vest_scene :PackedScene
export var weapon_scene :PackedScene
export var launcher_scene :PackedScene
export var uniform_style :int

# MUST SET
export var overlay_ui :NodePath
export var camera :NodePath

onready var _cam :Camera = get_node_or_null(camera)
onready var _overlay_ui :Control = get_node_or_null(overlay_ui)

onready var pivot = $pivot
onready var arrow = $circle/arrow
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var circle = $circle
onready var weapon_holder = $pivot/weapon_holder
onready var single_use_weapon = $pivot/single_use_weapon
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var bag_holder = $pivot/body/bag
onready var headgear_holder = $pivot/body/head/headgear
onready var vest_holder = $pivot/body/vest
onready var attack_time = $attack_time
onready var infantry_hit_register = $infantry_hit_register
onready var floating_unit_info = $floating_unit_info
onready var pending_task = $pending_task

onready var meshes = [
	$pivot/body/head/h, # head : 0=skin, 1:hair
	$pivot/body/Body, # body : 0=uniform
	$pivot/body/l_arm/a, # left arm : 0=skin, 1:uniform
	$pivot/body/r_arm/a, # right arm : 0=skin, 1:uniform
	$pivot/legs/l/leg, # left leg :  0:uniform, 1:booth
	$pivot/legs/r/leg # right leg : 0:uniform, 1:booth
]

puppet var _puppet_rotation_y :float
puppet var _puppet_anim :String

var _weapon_aimed :bool # this force anim to focus on fire mode
var _using_ability :bool # like luncher or grenade

var _current_anim :String = "iddle"
var _weapon :Weapon
var _melee_range :Array = []
var _special_projectile :BaseProjectile

var squad :BaseSquad

var grenade :int = 3
var launcher :int = 0

# set from stats
var discipline :int
var accuracy :int

var burst_min :float = 3.0
var burst_max :float = 6.0

var min_fire_rate :float = 1.7
var max_fire_rate :float = 3.3

func _ready():
	arrow.visible = _is_selected
	circle.set_surface_material(0, team_color_material)
	
	_weapon = weapon_scene.instance()
	bag_holder.add_child(bag_scene.instance())
	headgear_holder.add_child(hat_scene.instance())
	vest_holder.add_child(vest_scene.instance())
	set_uniform_style(skin_material, uniform_material, uniform_style)
	
	_weapon.is_master = _is_master
	_weapon.connect("weapon_fired", self, "_on_weapon_fired")
	_weapon.connect("weapon_update", self, "_on_weapon_update")
	_weapon.connect("weapon_finish_firing", self, "_on_weapon_finish_firing")
	
	weapon_holder.add_child(_weapon)
	single_use_weapon.add_child(launcher_scene.instance())
	
	infantry_hit_register.unit = self
	
	remove_child(floating_unit_info)
	_overlay_ui.add_child(floating_unit_info)
	floating_unit_info.init_bar(color, max_hp, _weapon.capacity)
	floating_unit_info.visible = false
	
func set_uniform_style(skin:SpatialMaterial, uniform:SpatialMaterial, mode :int):
	
	# normal
	if mode == 0:
		meshes[0].set_surface_material(0, skin)
		meshes[1].set_surface_material(0, uniform)
		meshes[2].set_surface_material(0, skin)
		meshes[2].set_surface_material(1, uniform)
		meshes[3].set_surface_material(0, skin)
		meshes[3].set_surface_material(1, uniform)
		meshes[4].set_surface_material(0, uniform)
		meshes[5].set_surface_material(0, uniform)
		
	# tank top
	elif mode == 1:
		meshes[0].set_surface_material(0, skin)
		meshes[1].set_surface_material(0, uniform)
		meshes[2].set_surface_material(0, skin)
		meshes[2].set_surface_material(1, skin)
		meshes[3].set_surface_material(0, skin)
		meshes[3].set_surface_material(1, skin)
		meshes[4].set_surface_material(0, uniform)
		meshes[5].set_surface_material(0, uniform)
		
	# no top
	elif mode == 2:
		meshes[0].set_surface_material(0, skin)
		meshes[1].set_surface_material(0, skin)
		meshes[2].set_surface_material(0, skin)
		meshes[2].set_surface_material(1, skin)
		meshes[3].set_surface_material(0, skin)
		meshes[3].set_surface_material(1, skin)
		meshes[4].set_surface_material(0, uniform)
		meshes[5].set_surface_material(0, uniform)
		
func set_selected(v :bool):
	.set_selected(v)
	
	if is_selectable:
		circle.set_surface_material(0, selected_area_material if _is_selected else team_color_material)
		arrow.visible = _is_selected
	
func move_to(tile_id :Vector2):
	.move_to(tile_id)
	
	if is_dead:
		return
		
	_weapon_aimed = false
	_using_ability = false
	_weapon.stop_firing()
	
	if not attack_time.is_stopped():
		attack_time.stop()
	
func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		rset_unreliable("_puppet_anim", _current_anim)
		
# overide move_to_path
func _move_to_path(delta :float, _pos :Vector3, to :Vector3):
	var t:Transform = transform.looking_at(to, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	translation += -transform.basis.z * speed * delta
	rotation.x = 0
	rotation.z = 0
	
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_range(delta, pos, enemy_pos)
	
	var look = enemy_pos
	look.y = pos.y
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	
	var dir_to :Vector3 = pos.direction_to(look)
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align :bool = foward_dir.dot(dir_to) > 0.85
	
	if is_align and attack_time.is_stopped():
		attack_time.wait_time = _get_fire_rate()
		attack_time.start()
		
		if _in_melee() and pos.y == enemy_pos.y:
			peform_melee()
			return
			
		fire_weapon(enemy_pos)
	
func _on_enemy_melee():
	if is_instance_valid(enemy):
		enemy.take_damage(1)
		audio_stream_player_3d.stream = punch
		audio_stream_player_3d.play()
		
func _in_melee() -> bool:
	return _melee_range.has(enemy.current_tile)
	
func update_spotting():
	.update_spotting()
	
	_melee_range = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		current_tile, 1
	)
	
func get_weapon() -> Weapon:
	return _weapon
	
func heal(amount :int):
	if _is_master:
		hp = int(clamp(hp + amount, 0 , max_hp))
		rpc_unreliable("_heal", hp)
	
remotesync func _heal(hp :int):
	if not _is_master:
		hp = hp
		
	if visible:
		floating_unit_info.update_bar(hp, _weapon.ammo)
	
func _on_no_enemy():
	._on_no_enemy()
	
	_weapon_aimed = false
	_using_ability = false
	_weapon.stop_firing()
	
	if not attack_time.is_stopped():
		attack_time.stop()
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	if _weapon_aimed or _using_ability:
		return
		
	if not _weapon:
		_current_anim = "run_unarm" if _is_moving else "iddle"
		
	else:
		_current_anim = "run_with_weapon" if _is_moving else "iddle_hold_weapon"
		
	animation_state.travel(_current_anim)
	
func peform_melee():
	if is_dead:
		return
	
	if not _is_master:
		return
		
	if not _weapon_aimed:
		_weapon_aimed = true
		
	_current_anim = "melee_weapon"
	animation_state.travel(_current_anim)
	
func fire_weapon(enemy_pos):
	if is_dead:
		return
	
	if not _is_master:
		return
		
	if not _weapon_aimed:
		_weapon_aimed = true
		
		_current_anim = "aim_weapon"
		animation_state.travel(_current_anim)
		return
	
	if not _weapon.has_ammo():
		reload_weapon()
		return
		
	if _weapon.is_weapon_jammed():
		reload_weapon()
		return
		
	if _weapon.firing():
		return
		
	# master just do it here
	_weapon.shot_at = enemy_pos + Vector3(0, 0.25, 0)
	var burst_count :int = min(_get_burst_count(), _weapon.ammo)
	_weapon.fire_weapon(burst_count)
	
	rpc_unreliable("_fire_weapon", burst_count, _weapon.ammo, _weapon.shot_at) # fire for puppet
	
remotesync func _fire_weapon(count :int, ammo :int, shot_at :Vector3):
	if is_dead:
		return
		
	if _is_master:
		return
		
	_weapon.shot_at = shot_at
	_weapon.ammo = ammo
	_weapon.fire_weapon(count)
	
func _on_weapon_fired():
	if is_dead:
		return
		
	if _is_master:
		if _weapon.check_hit(accuracy):
			if is_instance_valid(enemy):
				enemy.take_damage(_weapon.damage)
		
	audio_stream_player_3d.stream = shot_sounds[randi() % shot_sounds.size()]
	audio_stream_player_3d.play()
	
	_current_anim = "fire_weapon"
	animation_state.travel(_current_anim)
	
	if visible:
		floating_unit_info.update_bar(hp, _weapon.ammo)
	
func _on_weapon_finish_firing():
	if is_dead or not _is_master:
		return
		
	if pending_task.has_task():
		pending_task.run()
		return
		
	if not _weapon.has_ammo():
		reload_weapon()
		return
		
	_current_anim = "aim_weapon"
	animation_state.travel(_current_anim)
	
func reload_weapon():
	if is_dead:
		return
		
	if _is_master:
		_current_anim = "reload_weapon"
		animation_state.travel(_current_anim)
	
func _on_reloading():
	_weapon.reload()
	
	audio_stream_player_3d.stream = reload_sound
	audio_stream_player_3d.play()
	
	if visible:
		floating_unit_info.update_bar(hp, _weapon.ammo)
	
func _on_weapon_update():
	if visible:
		floating_unit_info.update_bar(hp, _weapon.ammo)
	
func use_launcher():
	if launcher == 0:
		return
		
	stop()
	
	# currently firing
	# just add to pending task
	# after firing it will lob grenade
	if _weapon.firing():
		pending_task.add_task(self, "_task_use_launcher")
		return
		
	_task_use_launcher()
	
func _task_use_launcher():
	yield(get_tree(),"idle_frame")
	
	if _is_master:
		var to = global_position + (-global_transform.basis.z) * 5
		if is_instance_valid(enemy):
			to = enemy.global_position
			
		rpc("_fire_launcher", to)
		
remotesync func _fire_launcher(to):
	_using_ability = true
	_current_anim = "use_launcher"
	animation_state.travel(_current_anim)
	
	if is_instance_valid(_special_projectile):
		_special_projectile.queue_free()
		_special_projectile = null
		
	_special_projectile = rocket_projectile_scene.instance()
	_special_projectile.is_master = _is_master
	_special_projectile.to = to + Vector3(0, 0.25, 0)
	_special_projectile.max_range = global_position.distance_to(to)
	get_parent().add_child(_special_projectile)
	_special_projectile.translation = global_position
	
func _on_launcher_fired():
	_using_ability = false
	
	if _is_master and not god_mode:
		launcher = int(clamp(launcher - 1, 0, 2))
	
	if is_instance_valid(_special_projectile):
		_special_projectile.launch()
		_special_projectile = null
	
func use_grenade():
	if grenade == 0:
		return
		
	stop()
	
	# currently firing
	# just add to pending task
	# after firing it will lob grenade
	if _weapon.firing():
		pending_task.add_task(self, "_task_use_grenade")
		return
		
	_task_use_grenade()
	
func _task_use_grenade():
	yield(get_tree(),"idle_frame")
	
	if _is_master:
		var to = global_position + (-global_transform.basis.z) * 2
		if is_instance_valid(enemy):
			to = enemy.global_position 
		
		rpc("_use_grenade", to)
	
remotesync func _use_grenade(to :Vector3):
	_using_ability = true
	_current_anim = "use_grenade"
	animation_state.travel(_current_anim)
	
	if is_instance_valid(_special_projectile):
		_special_projectile.queue_free()
		_special_projectile = null
		
	_special_projectile = grenade_projectile_scene.instance()
	_special_projectile.is_master = _is_master
	_special_projectile.to = to
	_special_projectile.max_range = global_position.distance_to(to)
	get_parent().add_child(_special_projectile)
	_special_projectile.translation = global_position
	
func _on_grenade_use():
	_using_ability = false
	
	if _is_master and not god_mode:
		grenade = int(clamp(grenade - 1, 0, 3))
		
	if is_instance_valid(_special_projectile):
		_special_projectile.launch()
		_special_projectile = null
	
func _exit_tree():
	floating_unit_info.queue_free()
	
func moving(_delta):
	.moving(_delta)
	
	if not _overlay_ui.visible:
		return
		
	if not visible:
		floating_unit_info.visible = false
		return
		
	var pos :Vector3 = global_position + Vector3.UP
	if _cam.is_position_behind(pos):
		return
		
	var screen_pos = _cam.unproject_position(pos)
	floating_unit_info.rect_global_position = screen_pos - floating_unit_info.rect_pivot_offset
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
	
	if not _using_ability:
		animation_state.travel(_puppet_anim)
	
func clone_mesh():
	#.clone_mesh()
	
	var new_pivot = Utils.clone_spatial(pivot)
	new_pivot.name = "dead_%s" % new_pivot.name
	return new_pivot
	
func taking_damage(_damage :int, _hp: int, _max_hp :int):
	.taking_damage(_damage, _hp, _max_hp)
	
	if visible:
		floating_unit_info.update_bar(hp, _weapon.ammo)
	
func on_dead():
	# called later after
	# animation finished
	#.on_dead()
	
	audio_stream_player_3d.stream = dead_sounds[randi() % dead_sounds.size()]
	audio_stream_player_3d.play()
	
	circle.visible = false
	_current_anim = "die_hold_weapon"
	animation_state.travel(_current_anim)
	
func _on_dead_animation_finished():
	.on_dead()
	
func _on_infantry_hit_register_on_click():
	if is_dead:
		return
		
	emit_signal("on_unit_clicked", self)
		
func _get_burst_count() -> int:
	var d = clamp(discipline, 1, 10)
	var t = float(d - 1) / 9.0
	var max_min_bonus = 1
	var max_max_bonus = 2
	var MAX_BURST_CAP = 8
	var reverse_t = 1.0 - t
	var min_burst = burst_min + round(max_min_bonus * reverse_t)
	var max_burst = burst_max + round(max_max_bonus * reverse_t)
	max_burst = min(max_burst, MAX_BURST_CAP)
	return randi() % int((max_burst - min_burst + 1.0) + min_burst)
	
func _get_fire_rate() -> float:
	var d = clamp(discipline, 1, 10)
	var t = float(d - 1) / 9.0
	var base = lerp(max_fire_rate, min_fire_rate, t)
	return rand_range(base * 0.9, base * 1.1)
	
