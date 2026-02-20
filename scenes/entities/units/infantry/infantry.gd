extends BaseTileUnit
class_name Infantry

onready var arrow = $circle/arrow
onready var selected_area_material = preload("res://assets/tile_highlight/selected_material.tres")
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var input_detection = $input_detection
onready var area = $Area
onready var circle = $circle
onready var weapon_holder = $pivot/weapon_holder

puppet var _puppet_rotation_y :float
puppet var _puppet_anim :String

var _current_anim :String = "iddle"
var _weapon :Weapon

var squad :BaseSquad

func _ready():
	area.connect("input_event", self, "_on_Area_input_event")
	arrow.visible = _is_selected
	circle.set_surface_material(0, Global.spatial_team_colors[team])
	
	_weapon = preload("res://scenes/entities/gear/weapons/m16/m16.tscn").instance()
	weapon_holder.add_child(_weapon)
	
func set_selected(v :bool):
	.set_selected(v)
	
	if not is_selectable:
		return
		
	circle.set_surface_material(0, selected_area_material if _is_selected else Global.spatial_team_colors[team])
	arrow.visible = _is_selected
	
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
		
	_set_animation()
	animation_state.travel(_current_anim)
	
func _set_animation():
	if not _weapon:
		_current_anim = "run_unarm" if _is_moving else "iddle"
		return
		
	if is_instance_valid(enemy) and not _is_moving:
		_current_anim = "aim_weapon"
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
		
func move_to(tile_id :Vector2):
	.move_to(tile_id)
	
	_weapon.stop_firing()
