extends MarginContainer

onready var potrait = $Control2/TextureRect/potrait
onready var unit_name = $Control3/TextureRect/unit_name

func show_stats(stats :UnitStatsData):
	unit_name.text = stats.soldier_name
	potrait.texture = Global.infantry_potraits[stats.soldier_potrait_index]
