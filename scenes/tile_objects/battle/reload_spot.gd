extends MeshInstance

export var usage_rate :int = 30
export var ammo_supply :int = 750
export var max_ammo_supply :int = 750

onready var collision_shape = $CollisionShape
onready var audio_stream_player_3d = $AudioStreamPlayer3D

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
	if ammo_supply <= 0:
		return
	
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(collision_shape.shape)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1
	query.transform = collision_shape.global_transform
	
	var results :Array = get_world().direct_space_state.intersect_shape(query, 1)
	if results.empty():
		return
		
	for result in results:
		if result["collider"] is HitRegister:
			var i :HitRegister = result["collider"]
			if i.unit is Infantry:
				_resupply_squad(i.unit)
				audio_stream_player_3d.play()
				return
				
func _resupply_squad(unit :Infantry):
	var squad :InfantrySquad = unit.squad
	for i in squad.members:
		if ammo_supply <= 0:
			return
			
		if is_instance_valid(i):
			var w :Weapon = i.get_weapon()
			if w.reserve_ammo >= w.max_reserve_ammo:
				continue
				
			w.reserve_ammo = int(clamp(w.reserve_ammo + usage_rate, 0, w.max_reserve_ammo))
			ammo_supply = int(clamp(ammo_supply - usage_rate, 0, max_ammo_supply))
			w.weapon_update()










