extends BaseTileUnit
class_name Infantry

const uniform_green = preload("res://scenes/entities/units/infantry/uniform_green.tres")
const uniform_khaki = preload("res://scenes/entities/units/infantry/uniform_khaki.tres")

const skin_color_dark = preload("res://scenes/entities/units/infantry/skin_color_dark_material.tres")
const skin_color = preload("res://scenes/entities/units/infantry/skin_color_material.tres")

const selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")

onready var arrow = $circle/arrow
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var input_detection = $input_detection
onready var area = $Area
onready var circle = $circle
onready var weapon_holder = $pivot/weapon_holder
onready var single_use_weapon = $pivot/single_use_weapon

# skin set at 0
onready var h_arms = [
	$pivot/body/l_arm/a,
	$pivot/body/r_arm/a,
	$pivot/body/head/h
]

# uniform set at 0
onready var b_leg = [
	$pivot/body/Body,
	$pivot/legs/l/leg,
	$pivot/legs/r/leg
]
# uniform set at 1
onready var arms = [
	$pivot/body/l_arm/a,
	$pivot/body/r_arm/a,
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
	area.connect("input_event", self, "_on_Area_input_event")
	arrow.visible = _is_selected
	circle.set_surface_material(0, Global.spatial_team_colors[team])
	
	# temps weapon spawn by team
	var uniform :SpatialMaterial
	
	if team == 1:
		uniform = uniform_green
		_weapon = preload("res://scenes/entities/gear/weapons/m16/m16.tscn").instance()
		_launcher = preload("res://scenes/entities/gear/weapons/m72/m72law.tscn").instance()
		
	if team == 2:
		uniform = uniform_khaki
		_weapon = preload("res://scenes/entities/gear/weapons/type56/type56.tscn").instance()
		_launcher = preload("res://scenes/entities/gear/weapons/rpg2/rpg2.tscn").instance()
		
	for i in b_leg:
		var m :MeshInstance = i
		m.set_surface_material(0, uniform)
		
	for i in arms:
		var m :MeshInstance = i
		m.set_surface_material(1, uniform)
		
	_weapon.is_master = _is_master
	_weapon.connect("weapon_fired", self, "_on_weapon_fired")
	
	weapon_holder.add_child(_weapon)
	single_use_weapon.add_child(_launcher)
	
func set_selected(v :bool):
	.set_selected(v)
	
	if not is_selectable:
		return
		
	circle.set_surface_material(0, selected_area_material if _is_selected else Global.spatial_team_colors[team])
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
	_current_anim = "fire_weapon"
	animation_state.travel(_current_anim)
	
func reload_weapon():
	if not _is_master:
		return
		
	_weapon.reload()
	_current_anim = "reload_weapon"
	animation_state.travel(_current_anim)
	
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
		

