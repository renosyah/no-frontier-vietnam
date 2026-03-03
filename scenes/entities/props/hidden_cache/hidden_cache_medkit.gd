extends Spatial

func _on_heal_spot_out_of_stock():
	$weapon_caches.queue_free()
	$heal_spot.queue_free()
