extends Node

const allow_nav = preload("res://assets/tile_highlight/allow_nav_material.tres")
const blocked_nav = preload("res://assets/tile_highlight/blocked_nav_material.tres")

onready var movable_camera_custom = $movable_camera_custom
onready var ui = $ui
onready var battle_map = $battle_map
onready var clickable_floor = $clickable_floor
onready var selection = $selection

onready var nav_highlight_holder = {}

var grand_map_manifest_data :GrandMapFileManifest
var battle_map_data :TileMapFileData

# Called when the node enters the scene tree for the first time.
func _ready():
	grand_map_manifest_data = Global.grand_map_manifest_data
	battle_map_data = Global.battle_map_data
	
	Global.camera_limit_bound = Vector3(grand_map_manifest_data.battle_map_size + 1, 0, grand_map_manifest_data.battle_map_size)
	
	ui.movable_camera_ui.camera_limit_bound = Global.camera_limit_bound
	ui.map_name.text = Global.battle_map_name
	ui.movable_camera_ui.target = movable_camera_custom
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	battle_map.generate_from_data(battle_map_data, true)
	
func _process(_delta):
	var cam_pos = movable_camera_custom.translation
	clickable_floor.translation = cam_pos * Vector3(1,0,1)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().change_scene("res://menu/editor/editor.tscn")
	
func show_selection(at :Vector3,show :bool):
	selection.visible = show
	selection.translation = at

func _on_battle_map_on_map_ready():
	for i in battle_map_data.navigations:
		var nav :NavigationData = i
		var nav_highlight = preload("res://assets/tile_highlight/nav_highlight.tscn").instance()
		add_child(nav_highlight)
		nav_highlight.set_text_label("%s\n%s" % [nav.id, nav.navigation_id])
		nav_highlight.set_surface_material(0, allow_nav if nav.enable else blocked_nav)
		nav_highlight.translation = battle_map.get_tile(nav.id).translation
		nav_highlight.visible = false
		nav_highlight_holder[nav.id] = nav_highlight
	
func _on_ui_on_card_dragging(pos):
	var tile = battle_map.get_closes_tile(pos)
	show_selection(tile.pos, true)

func _on_ui_on_cancel():
	show_selection(Vector3.ZERO, false)

func _on_ui_on_remove_object(pos):
	show_selection(Vector3.ZERO, false)
	
	var tile = battle_map.get_closes_tile(pos)
	var obj = battle_map.get_object(tile.id)
	if not is_instance_valid(obj):
		return
		
	# remove then
	# just enable back nav
	# object just shit on ground anyway
	battle_map.remove_spawned_object(tile.id)
	battle_map.update_navigation_tile(tile.id, true)

func _on_ui_on_toggle_nav(show):
	for i in nav_highlight_holder.values():
		i.visible = show

func _on_ui_on_add_object(data :MapObjectData):
	show_selection(Vector3.ZERO, false)
	
	var tile = battle_map.get_closes_tile(data.pos)
	var obj = battle_map.get_object(tile.id)
	if tile.tile_type in [4, 5] or is_instance_valid(obj):
		return
		
	data.id = tile.id
	data.pos = tile.pos
	data.rotation = rand_range(0, 360)
	battle_map.update_spawned_object(data)
	
	battle_map.update_navigation_tile(data.id, not data.is_blocking)
	
func _on_ui_on_update_tile(data :TileMapData):
	var old_tile = battle_map.get_closes_tile(data.pos)
	data.id = old_tile.id
	data.pos = old_tile.pos
	battle_map.update_spawned_tile(data)
	show_selection(old_tile.pos, false)
	
	battle_map.update_navigation_tile(data.id, data.tile_type in [1, 2, 3])
	
func _on_battle_map_on_navigation_updated(id :Vector2, data :NavigationData):
	nav_highlight_holder[id].set_surface_material(0, allow_nav if data.enable else blocked_nav)










