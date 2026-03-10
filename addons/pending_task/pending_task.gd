extends Node
class_name PendingTask

export var max_task :int = 1
var task_queue = []
var is_running = false

func has_task() -> bool:
	return not task_queue.empty()

func add_task(instance: Object,f :String, params: Array = []) -> void:
	if is_running:
		return
		
	var fn: FuncRef = funcref(instance, f)
	if fn == null:
		return
		
	if not fn.is_valid() or task_queue.size() >= max_task:
		return
		
	task_queue.append({"ref": fn, "params": params})
	
func run() -> void:
	if is_running:
		return
		
	is_running = true
	
	while not task_queue.empty():
		var task: Dictionary = task_queue.front()
		yield(task["ref"].call_funcv(task["params"]), "completed")
		task_queue.pop_front()
		
	is_running = false
