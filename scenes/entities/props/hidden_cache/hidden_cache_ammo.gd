extends Spatial
export var player_id :String

func _ready():
	$reload_spot.player_id = player_id
	
func _on_reload_spot_out_of_stock():
	$ammo_caches2.queue_free()
	$ammo_caches.queue_free()
	$weapon_caches3.queue_free()
	$reload_spot.queue_free()
