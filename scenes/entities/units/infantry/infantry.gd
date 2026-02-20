extends BaseTileUnit
class_name Infantry

const uniform_green = preload("res://scenes/entities/units/infantry/uniform_green.tres")
const uniform_khaki = preload("res://scenes/entities/units/infantry/uniform_khaki.tres")

const skin_color_dark = preload("res://scenes/entities/units/infantry/skin_color_dark_material.tres")
const skin_color = preload("res://scenes/entities/units/infantry/skin_color_material.tres")

onready var arrow = $circle/arrow
onready var selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var input_detection = $input_detection
onready var area = $Area
onready var circle = $circle
onready var weapon_holder = $pivot/weapon_holder

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
var _current_anim :String = "iddle"
var _weapon :Weapon

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
	if team == 2:
		uniform = uniform_khaki
		_weapon = preload("res://scenes/entities/gear/weapons/type56/type56.tscn").instance()
		
	for i in b_leg:
		var m :MeshInstance = i
		m.set_surface_material(0, uniform)
		
	for i in arms:
		var m :MeshInstance = i
		m.set_surface_material(1, uniform)
		
	weapon_holder.add_child(_weapon)
	
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
	
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
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
		
	if _weapon_aimed:
		return
		
	_set_animation()
	animation_state.travel(_current_anim)
	
func fire_weapon():
	stop()
	_weapon_aimed = true
	_current_anim = "aim_weapon"
	animation_state.travel(_current_anim)
	
func _on_weapon_aimed():
	for i in 3:
		_weapon.fire_weapon()
		yield(_weapon, "weapon_fired")
		_current_anim = "fire_weapon"
		animation_state.travel("fire_weapon")
		
	_weapon_aimed = false
	
func use_launcher():
	rpc("_use_launcher")
	
remotesync func _use_launcher():
	_current_anim = "use_launcher"
	animation_state.travel(_current_anim)
	
func _on_launcher_fired():
	pass
	
func _set_animation():
	if not _weapon:
		_current_anim = "run_unarm" if _is_moving else "iddle"
		return
		
	_current_anim = "run_with_weapon" if _is_moving else "iddle_hold_weapon"
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
	animation_state.travel(_puppet_anim)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		set_selected(not _is_selected)
		emit_signal("on_unit_selected", self, _is_selected)
	
func _on_Area_input_event(_camera, event, _position, _normal, _shape_idx):
	if is_selectable:
		input_detection.check_input(event)
		

