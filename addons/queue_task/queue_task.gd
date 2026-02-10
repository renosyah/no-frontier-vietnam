extends Node
class_name QueueTask

var task_queue = []
var is_running = false

func add_task(instance: Object,f :String, params: Array = []) -> void:
	var fn: FuncRef = funcref(instance, f)
	if fn == null:
		return
		
	if not fn.is_valid():
		return
		
	task_queue.append({"ref": fn, "params": params})
	if not is_running:
		_run_next()

func _run_next() -> void:
	if task_queue.empty():
		is_running = false
		return
		
	is_running = true
	var task: Dictionary = task_queue.front()
	yield(task["ref"].call_funcv(task["params"]), "completed")
	task_queue.pop_front()
	_run_next()
