extends Node
class_name SoldierPotraits

const macv_potrait_path = "res://assets/soldier_potraits/macv"
const nva_potrait_path = "res://assets/soldier_potraits/nva"
##
static func generate_macv_potraits() -> Array:
	var list = [[],[],[]]
	for i in range(1, 5):
		list[0].append("%s/crew_%s.png" % [macv_potrait_path, i])
		
	for i in range(1,5):
		list[1].append("%s/heli_pilot_%s.png" % [macv_potrait_path, i])
		
	for i in range(1, 10):
		list[2].append("%s/riflement_%s.png" % [macv_potrait_path, i])
		
	return list
	
# 0 crew, 1 heli, 2 gi
static func get_macv_potrait(i :int) -> Resource:
	var list = generate_macv_potraits()
	var s = list[i]
	return load(s[randi() % s.size()])
	
##
static func generate_nva_potraits() -> Array:
	var list = [[],[]]
	
	for i in range(1, 5):
		list[0].append("%s/crew_%s.png" % [nva_potrait_path, i])
		
	for i in range(1, 10):
		list[1].append("%s/riflement_%s.png" % [nva_potrait_path, i])
		
	return list
	
# 0 crew, 1 gi
static func get_nva_potrait(i :int) -> Resource:
	var list = generate_nva_potraits()
	var s = list[i]
	return load(s[randi() % s.size()])
