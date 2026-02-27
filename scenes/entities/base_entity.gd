extends Spatial
class_name BaseEntity

# this is entity that can sync in network enviroment
# only basic mechanic to setup & prepare as network entity

# owner
var player_id :String

# performace
var _visibility_notifier :VisibilityNotifier

# misc network
var _network_timmer :Timer
var _is_online :bool = false
var _is_master :bool = false
var _sync :bool = true

############################################################
# multiplayer func
func set_sync(v :bool):
	if not _is_master:
		return
		
	_sync = v
	
	# if sync disable
	# to make sure your entity got critical
	# last update to avoid unsync
	if _is_online and not _sync:
		last_sync_update() # send last update

func _network_timmer_timeout() -> void:
	_is_online = _is_network_running()
	if _sync:
		sync_update()
	
func sync_update() -> void:
	pass
	
func last_sync_update() -> void:
	
	pass
func _on_camera_entered(_camera: Camera):
	visible = true
	
func _on_camera_exited(_camera: Camera):
	visible = false
	
############################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_is_online = _is_network_running()
	_is_master = _is_network_master()
	
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 20
	_visibility_notifier.connect("camera_entered", self, "_on_camera_entered")
	_visibility_notifier.connect("camera_exited", self , "_on_camera_exited")
	add_child(_visibility_notifier)
	
	# add little delay
	# just in case all its puppet created in time
	yield(get_tree().create_timer(1),"timeout")
	_setup_network_timer()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta :float) -> void:
	moving(delta)
	
	if not _is_online:
		return
		
	if _is_master:
		master_moving(delta)
	else:
		puppet_moving(delta)
	
func moving(_delta :float) -> void:
	pass
	
func master_moving(_delta :float) -> void:
	pass
	
func puppet_moving(_delta :float) -> void:
	pass
	
############################################################
# multiplayer func
func _is_network_running() -> bool:
	var _peer :NetworkedMultiplayerPeer = get_tree().network_peer
	if not is_instance_valid(_peer):
		return false
		
	if _peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		return false
		
	return true
	
func _is_network_master() -> bool:
	if not get_tree().network_peer:
		return false
		
	if not is_network_master():
		return false
		
	return true
	
func _setup_network_timer() -> void:
	
	# only master can send data
	# to all their pupets!
	if not _is_master:
		return
		
	if is_instance_valid(_network_timmer):
		_network_timmer.stop()
		_network_timmer.queue_free()
		
	_network_timmer = Timer.new()
	_network_timmer.wait_time = Network.LATENCY_DELAY
	_network_timmer.connect("timeout", self , "_network_timmer_timeout")
	_network_timmer.autostart = true
	add_child(_network_timmer)
	


