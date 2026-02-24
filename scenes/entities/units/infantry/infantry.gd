extends BaseTileUnit
class_name Infantry

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

onready var arrow = $circle/arrow
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var input_detection = $input_detection
onready var area = $Area
onready var circle = $circle
onready var weapon_holder = $pivot/weapon_holder
onready var single_use_weapon = $pivot/single_use_weapon
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var bag_holder = $pivot/body/bag
onready var headgear_holder = $pivot/body/head/headgear
onready var vest_holder = $pivot/body/vest

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

var _weapon_aimed :bool
var _launcher_firing :bool

var _current_anim :String = "iddle"
var _weapon :Weapon
var _launcher :Spatial

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
	
	weapon_holder.add_child(_weapon)
	single_use_weapon.add_child(_launcher)
	
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
	
	_weapon_aimed = false
	_weapon.stop_firing()
	
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
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	_set_animation()
	animation_state.travel(_current_anim)
	
func fire_weapon():
	stop()
	
	if _weapon_aimed:
		_on_weapon_aimed()
		return
		
	_weapon_aimed = true
	
func _on_weapon_aimed():
	if _is_master:
		if not _weapon.has_ammo():
			reload_weapon()
			return
		
		var burst_count = min(int(rand_range(3, 6)), _weapon.ammo)
		rpc("_fire_weapon", burst_count, _weapon.ammo)
		
remotesync func _fire_weapon(count :int, ammo_remain :bool):
	if not _is_master:
		_weapon.ammo = ammo_remain
	
	for i in count:
		_weapon.fire_weapon()
		
func _on_weapon_fired():
	audio_stream_player_3d.stream =  shot_sounds[randi() % shot_sounds.size()]
	audio_stream_player_3d.play()
	
	_current_anim = "fire_weapon"
	animation_state.travel(_current_anim)
	
func reload_weapon():
	if not _is_master:
		return
		
	_weapon.reload()
	_current_anim = "reload_weapon"
	animation_state.travel(_current_anim)
	
func _on_reloading():
	audio_stream_player_3d.stream = reload_sound
	audio_stream_player_3d.play()
	
func use_launcher(at :Vector3):
	stop()
	_weapon_aimed = false
	_weapon.stop_firing()
	
	if _is_master:
		rpc("_fire_launcher")
		
remotesync func _fire_launcher():
	_launcher_firing = true
	_current_anim = "use_launcher"
	animation_state.travel(_current_anim)
	
func _on_launcher_fired():
	_launcher_firing = false
	
func use_grenade(at :Vector3):
	stop()
	_weapon_aimed = false
	_weapon.stop_firing()
	
	if _is_master:
		rpc("_use_grenade")
		
remotesync func _use_grenade():
	_launcher_firing = true
	_current_anim = "use_grenade"
	animation_state.travel(_current_anim)
	
func _on_grenade_use():
	_launcher_firing = false
	
func _set_animation():
	if _launcher_firing:
		return
		
	if _weapon_aimed:
		_current_anim = "aim_weapon"
		return
		
	if not _weapon:
		_current_anim = "run_unarm" if _is_moving else "iddle"
		return
		
	_current_anim = "run_with_weapon" if _is_moving else "iddle_hold_weapon"
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
	
	if not _launcher_firing:
		animation_state.travel(_puppet_anim)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		set_selected(not _is_selected)
		emit_signal("on_unit_selected", self, _is_selected)
	
func _on_Area_input_event(_camera, event, _position, _normal, _shape_idx):
	if is_selectable:
		input_detection.check_input(event)
		

