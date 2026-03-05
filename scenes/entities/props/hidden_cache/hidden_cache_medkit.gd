extends Spatial
export var player_id :String

func _ready():
	$heal_spot.player_id = player_id
	
func _on_heal_spot_out_of_stock():
	$weapon_caches.queue_free()
	$heal_spot.queue_free()
