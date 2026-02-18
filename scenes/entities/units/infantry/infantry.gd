extends BaseTileUnit
class_name Infantry

onready var animation_state = $AnimationTree.get("parameters/playback")
onready var input_detection = $input_detection
onready var area = $Area

puppet var _puppet_rotation_y :float
puppet var _puppet_anim :String

var _current_anim :String = "iddle"

func _ready():
	if is_selectable:
		area.connect("input_event", self, "_on_Area_input_event")

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		rset_unreliable("_puppet_anim", _current_anim)
		
# overide move_to_path
func move_to_path(delta :float, pos :Vector3, to :Vector3):
	var t:Transform = transform.looking_at(to, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	translation += -transform.basis.z * speed * delta
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	_current_anim = "run_unarm" if _is_moving else "iddle"
	animation_state.travel(_current_anim)
	
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
	
func _on_Area_input_event(camera, event, position, normal, shape_idx):
	input_detection.check_input(event)
