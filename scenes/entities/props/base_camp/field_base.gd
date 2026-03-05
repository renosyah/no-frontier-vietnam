extends Spatial

export var player_id :String

func _ready():
	var spots = get_spots()
	for i in spots:
		i.player_id = player_id
		
func get_spots():
	return [$reload_spot_a, $reload_spot_b, $heal_spot_a, $heal_spot_b]

func _on_reload_spot_a_out_of_stock():
	$ammo_caches_a.queue_free()
	$weapon_caches_a.queue_free()
	$reload_spot_a.queue_free()
	
func _on_reload_spot_b_out_of_stock():
	$ammo_caches_b.queue_free()
	$weapon_caches_b.queue_free()
	$reload_spot_b.queue_free()
	
func _on_heal_spot_a_out_of_stock():
	$med_caches_a.queue_free()
	$heal_spot_a.queue_free()
	
func _on_heal_spot_b_out_of_stock():
	$med_caches_b.queue_free()
	$med_caches_b2.queue_free()
	$heal_spot_b.queue_free()
