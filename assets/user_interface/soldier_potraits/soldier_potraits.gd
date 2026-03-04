extends Node
class_name SoldierPotraits

const macv_potrait_path = "res://assets/user_interface/soldier_potraits/macv"
const nva_potrait_path = "res://assets/user_interface/soldier_potraits/nva"
##
static func generate_macv_potraits() -> Array:
	var list = [[],[],[]]
	var idx = 1
	
	for _i in 5:
		list[0].append("%s/crew_%s.png" % [macv_potrait_path, idx])
		idx += 1
		
	idx = 1
	for _i in 5:
		list[1].append("%s/heli_pilot_%s.png" % [macv_potrait_path, idx])
		idx += 1
		
	idx = 1
	for _i in 10:
		list[2].append("%s/riflement_%s.png" % [macv_potrait_path, idx])
		idx += 1
		
	idx = 1
	for _i in 10:
		list[2].append("%s/sog_%s.png" % [macv_potrait_path, idx])
		idx += 1
		
	return list
	
# 0 crew, 1 heli, 2 gi, 3 sogs
static func get_macv_potraits(idx :int) -> Array:
	var list = generate_macv_potraits()
	var s = list[idx]
	var data = []
	for i in s:
		data.append(load(i))
		
	return data
	
##
static func generate_nva_potraits() -> Array:
	var list = [[],[]]
	var idx = 1
	
	for _i in 5:
		list[0].append("%s/crew_%s.png" % [nva_potrait_path, idx])
		idx += 1
		
	idx = 1
	for _i in 10:
		list[1].append("%s/riflement_%s.png" % [nva_potrait_path, idx])
		idx += 1
		
	return list
	
# 0 crew, 1 gi
static func get_nva_potraits(idx :int) -> Array:
	var list = generate_nva_potraits()
	var s = list[idx]
	var data = []
	for i in s:
		data.append(load(i))
		
	return data
