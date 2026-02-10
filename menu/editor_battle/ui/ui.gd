extends Control

signal on_card_dragging
signal on_update_tile
signal on_add_object
signal on_remove_object
signal on_cancel
signal on_toggle_nav
signal on_randomize

onready var floating_image_card = $CanvasLayer/floating_image_card
onready var movable_camera_ui = $CanvasLayer/movable_camera_ui
onready var map_name = $CanvasLayer/Control/VBoxContainer/HBoxContainer/ColorRect/map_name
onready var tile_options = [$CanvasLayer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/ground_tile, $CanvasLayer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/water_tile, $CanvasLayer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/object_bush, $CanvasLayer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/object_forest, $CanvasLayer/Control/VBoxContainer/HBoxContainer2/VBoxContainer/object_rock]
onready var show_nav = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/VBoxContainer2/show_nav
onready var card_containers = [$CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer1, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer2, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer3, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer4, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer5]
onready var cards = [
	$CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer1/ground_tile_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer1/mud_tile_card2, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer1/sand_tile_card3,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer2/water_tile_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer2/mud_tile_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer3/object_bush_1_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer3/object_bush_2_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer3/object_bush_3_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer4/object_tree_1_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer4/object_tree_2_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer4/object_tree_3_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer4/object_tree_4_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer5/object_rock_1_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer5/object_rock_2_card, $CanvasLayer/Control/VBoxContainer/HBoxContainer6/HBoxContainer5/object_rock_3_card
]
onready var object_remove_card = $CanvasLayer/Control/VBoxContainer/HBoxContainer6/object_remove_card

func _ready():
	var card_idx = 0
	for i in tile_options:
		var btn : Button = i
		btn.connect("pressed", self, "_on_toggle_button_pressed", [btn, card_containers[card_idx]])
		card_idx += 1
		
	for i in cards + [object_remove_card]:
		var card :DragableCard = i
		var icon :StreamTexture = (card.get_child(1) as TextureRect).texture
		card.connect("on_grab", self, "_on_card_grab", [icon])
		card.connect("on_draging", self, "_on_card_grab_draging")
		card.connect("on_release", self, "_on_card_grab_release")
		card.connect("on_cancel", self, "_on_card_grab_cancel")
	
	hide_cards()
	
func untoggle_buttons(exc):
	for i in tile_options:
		i.set_toggle_button(false)
		
	exc.set_toggle_button(true)
	
func hide_cards():
	for i in card_containers:
		i.visible = false
		
func _on_toggle_button_pressed(btn, card_container):
	untoggle_buttons(btn)
	hide_cards()
	card_container.visible = true
	
func on_card_release(card :DragableCard, at :Vector2):
	if card == object_remove_card:
		var pos3 = Utils.screen_to_world(get_viewport().get_camera(), at, false, 4)
		emit_signal("on_remove_object", pos3)
		return
		
	if card == cards[0]:
		update_tile(at, 1) # grass
	elif card == cards[1]:
		update_tile(at, 2) # mud
	elif card == cards[2]:
		update_tile(at, 3) # sand
		
	if card == cards[3]:
		update_tile(at, 4) # water non
	elif card == cards[4]:
		update_tile(at, 5) # mud non
		
	# uses scene 
	# from MapObjectData.scenes
	if card == cards[5]:
		add_object(at, 4, false) # bush 1
	elif card == cards[6]:
		add_object(at, 5, false) # bush 2
	elif card == cards[7]:
		add_object(at, 6, false) # bush 3
		
	# uses scene 
	# from MapObjectData.scenes
	if card == cards[8]:
		add_object(at, 7, true) # tree 1
	elif card == cards[9]:
		add_object(at, 8, true) # tree 2
	elif card == cards[10]:
		add_object(at, 9, true) # tree 3
	elif card == cards[11]:
		add_object(at, 10, true) # tree 4
		
	# uses scene 
	# from MapObjectData.scenes
	if card == cards[12]:
		add_object(at, 11, true) # rock 1
	elif card == cards[13]:
		add_object(at, 12, true) # rock 2
	elif card == cards[14]:
		add_object(at, 13, true) # rock 3
		
# for tile land & water
func update_tile(at :Vector2, type_tile :int):
	var pos3 = Utils.screen_to_world(get_viewport().get_camera(), at, false, 4)
	var data :TileMapData = TileMapData.new()
	data.tile_type = type_tile
	data.id = Vector2.ZERO
	data.pos = pos3
	
	emit_signal("on_update_tile", data)
	
func add_object(at :Vector2, scene_idx :int, is_blocking :bool):
	var pos3 = Utils.screen_to_world(get_viewport().get_camera(), at, false, 4)
	var data :MapObjectData = MapObjectData.new()
	data.id = Vector2.ZERO
	data.pos = pos3
	data.scene_idx = scene_idx
	data.is_blocking = is_blocking
	data.rotation = rand_range(0, 360)
	emit_signal("on_add_object", data)
	
func _on_card_grab(_card :DragableCard, pos :Vector2, icon :StreamTexture):
	var pos2 = pos # - floating_image_card.rect_pivot_offset
	floating_image_card.texture = icon
	floating_image_card.visible = true
	floating_image_card.rect_position = pos2
	
func _on_card_grab_draging(_card :DragableCard, pos :Vector2):
	var pos2 = pos # - floating_image_card.rect_pivot_offset
	floating_image_card.rect_position = pos2
	var pos3 = Utils.screen_to_world(get_viewport().get_camera(), pos2, false, 4)
	emit_signal("on_card_dragging", pos3)
	
func _on_card_grab_release(card :DragableCard, pos :Vector2):
	floating_image_card.visible = false
	var pos2 = pos # - floating_image_card.rect_pivot_offset
	on_card_release(card, pos2)
	
func _on_card_grab_cancel(_card :DragableCard):
	floating_image_card.visible = false
	emit_signal("on_cancel")
	
func _on_menu_button_pressed():
	get_tree().change_scene("res://menu/editor/editor.tscn")

func _on_random_map_pressed():
	emit_signal("on_randomize")

func _on_show_nav_pressed():
	emit_signal("on_toggle_nav", not show_nav.is_toggle)
