extends MarginContainer
class_name DragableCard

signal on_grab
signal on_draging
signal on_release
signal on_cancel

var _dragging = false
var _drag_offset = Vector2()
var _drag_pos = Vector2()

onready var color_rect = $ColorRect

func _ready():
	connect("gui_input", self, "_on_dragable_card_gui_input")

func _on_dragable_card_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			_dragging = true
			_drag_offset = rect_global_position - event.position
			_drag_pos = event.position + _drag_offset
			emit_signal("on_grab", self, _drag_pos)
			color_rect.visible = true
			
		else:
			_dragging = false
			if not _is_point_inside_area(_drag_pos):
				emit_signal("on_release", self, _drag_pos)
			else:
				emit_signal("on_cancel", self)
			color_rect.visible = false
			
	elif event is InputEventScreenDrag:
		if _dragging:
			_drag_pos = event.position + _drag_offset + color_rect.rect_pivot_offset
			emit_signal("on_draging", self,  _drag_pos)
			
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
