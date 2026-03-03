extends BaseTileUnit
class_name Infantry

const punch = preload("res://assets/sounds/weapons/punch.wav")
const reload_sound = preload("res://assets/sounds/weapons/reload.wav")
const shot_sounds = [
	preload("res://assets/sounds/weapons/shot_1.wav"),
	preload("res://assets/sounds/weapons/shot_2.wav"),
	preload("res://assets/sounds/weapons/shot_3.wav")
]
const selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")

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
onready var blood = $blood

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
var _special_move_perform :bool # this force anim to focus on special attack
var _on_melee_perform :bool # this force anim to focus on melee

var _current_anim :String = "iddle"
var _weapon :Weapon
var _launcher :Spatial
var _melee_range :Array = []

var _floating_info

var squad :BaseSquad

func _ready():
	arrow.visible = _is_selected
	circle.set_surface_material(0, team_color_material)
	
	_weapon = weapon_scene.instance()
	_launcher = launcher_scene.instance()
	bag_holder.add_child(bag_scene.instance())
	headgear_holder.add_child(hat_scene.instance())
	vest_holder.add_child(vest_scene.instance())
	set_uniform_style(skin_material, uniform_material, uniform_style)
	
	_weapon.is_master = _is_master
	_weapon.connect("weapon_fired", self, "_on_weapon_fired")
	_weapon.connect("weapon_update", self, "_on_weapon_update")
	_weapon.unit_owner = self
	_weapon.team = team
	
	weapon_holder.add_child(_weapon)
	single_use_weapon.add_child(_launcher)
	
	infantry_hit_register.unit = self
	
	_floating_info = preload("res://assets/user_interface/icons/floating_infantry_info/floating_infantry_info.tscn").instance()
	_overlay_ui.add_child(_floating_info)
	_floating_info.init_bar(color, max_hp, _weapon.capacity)
	_floating_info.visible = false
	
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
	
	if not is_selectable:
		return
		
	circle.set_surface_material(0, selected_area_material if _is_selected else team_color_material)
	arrow.visible = _is_selected
	
func move_to(tile_id :Vector2):
	.move_to(tile_id)
	
	if is_dead:
		return
		
	_weapon_aimed = false
	_weapon.stop_firing()
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
	
	if is_align and _in_melee() and pos.y == enemy_pos.y:
		_on_melee_perform = true
		_current_anim = "melee_weapon"
		animation_state.travel(_current_anim)
		return
		
	_on_melee_perform = false
	
	if is_align and attack_time.is_stopped():
		_weapon.shot_at = enemy_pos
		fire_weapon()
		attack_time.wait_time = rand_range(1, 4)
		attack_time.start()

func _on_enemy_melee():
	_on_melee_perform = false
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
		
	_floating_info.update_bar(hp, _weapon.ammo)
	
func _on_no_enemy():
	._on_no_enemy()
	
	_weapon_aimed = false
	_weapon.stop_firing()
	
	if not attack_time.is_stopped():
		attack_time.stop()
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	_set_animation()
	animation_state.travel(_current_anim)
	
func fire_weapon():
	if _weapon_aimed:
		_on_weapon_aimed()
		return
		
	_weapon_aimed = true
	
func _on_weapon_aimed():
	if not _is_master or _weapon.firing():
		return
		
	if not _weapon.has_ammo():
		reload_weapon()
		return
		
	# master just do it here
	var burst_count = min(int(rand_range(3, 4)), _weapon.ammo)
	_weapon.fire_weapon(burst_count)
		
	rpc_unreliable("_fire_weapon", burst_count, _weapon.shot_at) # fire for puppet
	
remotesync func _fire_weapon(count :int, shot_at :Vector3):
	if _is_master:
		return
		
	_weapon.shot_at = shot_at
	_weapon.fire_weapon(count)
		
func _on_weapon_fired():
	if is_dead:
		return
		
	if not _weapon.has_ammo() and _is_master:
		reload_weapon()
		return
		
	audio_stream_player_3d.stream =  shot_sounds[randi() % shot_sounds.size()]
	audio_stream_player_3d.play()
	
	_current_anim = "fire_weapon"
	animation_state.travel(_current_anim)
	
	_floating_info.update_bar(hp, _weapon.ammo)
	
func reload_weapon():
	if _is_master:
		_weapon.reload()
		_current_anim = "reload_weapon"
		animation_state.travel(_current_anim)
	
func _on_reloading():
	audio_stream_player_3d.stream = reload_sound
	audio_stream_player_3d.play()
	
	_floating_info.update_bar(hp, _weapon.ammo)
	
func _on_weapon_update():
	_floating_info.update_bar(hp, _weapon.ammo)
	
func use_launcher(_at :Vector3):
	stop()
	_weapon_aimed = false
	_weapon.stop_firing()
	
	if _is_master:
		rpc("_fire_launcher")
		
remotesync func _fire_launcher():
	_special_move_perform = true
	_current_anim = "use_launcher"
	animation_state.travel(_current_anim)
	
func _on_launcher_fired():
	_special_move_perform = false
	
func use_grenade(_at :Vector3):
	stop()
	_weapon_aimed = false
	_weapon.stop_firing()
	
	if _is_master:
		rpc("_use_grenade")
		
remotesync func _use_grenade():
	_special_move_perform = true
	_current_anim = "use_grenade"
	animation_state.travel(_current_anim)
	
func _on_grenade_use():
	_special_move_perform = false
	
func _set_animation():
	if _special_move_perform or _on_melee_perform:
		return
		
	if _weapon_aimed:
		_current_anim = "aim_weapon"
		return
		
	if not _weapon:
		_current_anim = "run_unarm" if _is_moving else "iddle"
		return
		
	_current_anim = "run_with_weapon" if _is_moving else "iddle_hold_weapon"
	
func _exit_tree():
	_floating_info.queue_free()
	
func moving(_delta):
	.moving(_delta)
	
	_track_floating_info(_cam, global_position + Vector3.UP)
	
func _track_floating_info(_active_cam :Camera, pos :Vector3):
	if not _overlay_ui.visible:
		return
		
	if not visible:
		_floating_info.visible = false
		return
		
	if _active_cam.is_position_behind(pos):
		return
		
	var screen_pos = _active_cam.unproject_position(pos)
	_floating_info.rect_global_position = screen_pos - _floating_info.rect_pivot_offset
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
	
	if not _special_move_perform:
		animation_state.travel(_puppet_anim)
		
func clone_mesh():
	#.clone_mesh()
	
	var new_pivot = Utils.clone_spatial(pivot)
	new_pivot.name = "dead_%s" % new_pivot.name
	return new_pivot
	
func taking_damage(_damage :int, _hp: int, _max_hp :int):
	.taking_damage(_damage, _hp, _max_hp)
	
	blood.translation = global_position
	blood.display()
	
	_floating_info.update_bar(hp, _weapon.ammo)
	
func on_dead():
	# called later after
	# animation finished
	#.on_dead()
	
	circle.visible = false
	_current_anim = "die_hold_weapon"
	animation_state.travel(_current_anim)
	
func _on_dead_animation_finished():
	.on_dead()
	
func _on_infantry_hit_register_on_click():
	if not is_dead:
		emit_signal("on_unit_clicked", self)
