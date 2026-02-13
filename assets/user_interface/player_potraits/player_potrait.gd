extends Node
class_name PlayerPotrait

const macv_officers = [
	preload("res://assets/user_interface/player_potraits/macv_officer_1.png"),
	preload("res://assets/user_interface/player_potraits/macv_officer_2.png"),
	preload("res://assets/user_interface/player_potraits/macv_officer_3.png"),
	preload("res://assets/user_interface/player_potraits/macv_officer_4.png"),
	preload("res://assets/user_interface/player_potraits/macv_officer_5.png")
]
const nva_officers = [
	preload("res://assets/user_interface/player_potraits/nva_officer_1.png"),
	preload("res://assets/user_interface/player_potraits/nva_officer_2.png"),
	preload("res://assets/user_interface/player_potraits/nva_officer_3.png"),
	preload("res://assets/user_interface/player_potraits/nva_officer_4.png"),
	preload("res://assets/user_interface/player_potraits/nva_officer_5.png")
]

static func get_potrait(team:int, idx:int):
	return macv_officers[idx] if team == 1 else nva_officers[idx]
