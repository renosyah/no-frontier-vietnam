extends Node

const allow_nav = preload("res://assets/tile_highlight/allow_nav_material.tres")
const blocked_nav = preload("res://assets/tile_highlight/blocked_nav_material.tres")

onready var ui = $ui
onready var movable_camera_custom = $movable_camera_custom
onready var grand_map = $grand_map
onready var clickable_floor = $clickable_floor
onready var selection = $selection
onready var border = $grand_map/border
onready var camera = $movable_camera_custom/Camera

onready var nav_highlight_holder = {}

# refrence variable, modified this, in global it got modified too
onready var grand_map_manifest_data = Global.grand_map_manifest_data
onready var grand_map_data = Global.grand_map_data
onready var grand_map_mission_data = Global.grand_map_mission_data
onready var battle_map_datas = Global.battle_map_datas

func _ready():
	Global.camera_limit_bound = Vector3(grand_map_manifest_data.map_size + 1, 0, grand_map_manifest_data.map_size)
	
	ui.movable_camera_ui.camera_limit_bound = Global.camera_limit_bound
	ui.movable_camera_ui.target = movable_camera_custom
	ui.movable_camera_ui.center_pos = grand_map.global_position + Vector3(0, 0, 2)
	ui.movable_camera_ui.camera_limit_bound = Global.camera_limit_bound
	ui.save_button.visible = false
	
	ui.map_name.text = grand_map_manifest_data.map_name
	update_base_point_quota()
	
	border.scale = Vector3.ONE * ((grand_map_manifest_data.map_size * 2) + 1.5)
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	grand_map.generate_from_data(grand_map_data, true)
	
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
	get_tree().change_scene("res://menu/editor_menu/editor_menu.tscn")

func update_base_point_quota():
	var base_qty = grand_map_mission_data.bases.size()
	var point_qty = grand_map_mission_data.points.size()
	ui.base_qty.text = "%s" %  (2 - base_qty)
	ui.point_qty.text = "%s" % (3 - point_qty)
	
	var edited_map :bool = not grand_map_mission_data.edited_battle_maps.values().has(false)
	var mission_esential :bool = (base_qty >= Global.req_base_count) and (point_qty >= Global.req_point_count)
	var edited_battle_map = 0
	for key in grand_map_mission_data.edited_battle_maps.keys():
		if not grand_map_mission_data.edited_battle_maps[key]:
			edited_battle_map += 1
			
	ui.battle_map_edited.text = "%s" % edited_battle_map
	ui.save_button.visible = mission_esential and edited_map
	
func show_selection(at :Vector3,show :bool):
	selection.visible = show
	selection.translation = at

func _on_clickable_floor_on_floor_clicked(_pos):
	pass

func _on_ui_on_update_tile(data :TileMapData):
	var old_tile = grand_map.get_closes_tile(data.pos)
	data.id = old_tile.id
	data.pos = old_tile.pos
	grand_map.update_spawned_tile(data)
	show_selection(old_tile.pos, false)
	
	if data.tile_type == 1:
		grand_map.update_navigation_tile(data.id, true)
		battle_map_datas[data.id] = TileMapUtils.generate_empty_tile_map(Global.battle_map_size, false)
		grand_map_mission_data.edited_battle_maps[data.id] = false
		
	elif data.tile_type == 2:
		grand_map.update_navigation_tile(data.id, false)
		grand_map.remove_spawned_object(data.id)
		
		if grand_map_mission_data.edited_battle_maps.has(data.id):
			grand_map_mission_data.edited_battle_maps.erase(data.id)
		
		if grand_map_mission_data.bases.has(data.id):
			grand_map_mission_data.bases.erase(data.id)
			
		if grand_map_mission_data.points.has(data.id):
			grand_map_mission_data.points.erase(data.id)
			
		
	update_base_point_quota()
	
func _on_ui_on_add_object(data :MapObjectData):
	show_selection(Vector3.ZERO, false)
	
	var tile = grand_map.get_closes_tile(data.pos)
	var obj = grand_map.get_object(tile.id)
	if tile.tile_type == 2 or is_instance_valid(obj):
		return
		
	data.id = tile.id
	data.pos = tile.pos
	grand_map.update_spawned_object(data)

func _on_ui_on_add_point(data :MapObjectData):
	show_selection(Vector3.ZERO, false)
	
	# must get id from tile!!
	var tile = grand_map.get_closes_tile(data.pos)
	var obj = grand_map.get_object(tile.id)
	var has_max = grand_map_mission_data.points.size() >= 3
	if is_instance_valid(obj) or has_max or tile.tile_type == 2:
		return
		
	data.id = tile.id
	data.pos = tile.pos
	grand_map.update_spawned_object(data)
	
	battle_map_datas[data.id] = TileMapUtils.generate_empty_tile_map(Global.battle_map_size, false)
	grand_map_mission_data.edited_battle_maps[data.id] = false
	
	grand_map_mission_data.points.append(data.id)
	update_base_point_quota()
	
func _on_ui_on_add_base(data :MapObjectData):
	show_selection(Vector3.ZERO, false)
	
	# must get id from tile!!
	var tile = grand_map.get_closes_tile(data.pos)
	var obj = grand_map.get_object(tile.id)
	var has_max = grand_map_mission_data.bases.size() >= 2
	if is_instance_valid(obj) or has_max or tile.tile_type == 2:
		return
	
	data.id = tile.id
	data.pos = tile.pos
	grand_map.update_spawned_object(data)
	
	battle_map_datas[data.id] = TileMapUtils.generate_empty_tile_map(Global.battle_map_size, false)
	grand_map_mission_data.edited_battle_maps[data.id] = false
	
	grand_map_mission_data.bases.append(data.id)
	update_base_point_quota()
	
func _on_ui_on_remove_object(pos):
	show_selection(Vector3.ZERO, false)
	
	var tile = grand_map.get_closes_tile(pos)
	grand_map.remove_spawned_object(tile.id)
	
	if grand_map_mission_data.bases.has(tile.id):
		grand_map_mission_data.bases.erase(tile.id)
		
	if grand_map_mission_data.points.has(tile.id):
		grand_map_mission_data.points.erase(tile.id)
		
	update_base_point_quota()
	
func _on_ui_on_card_dragging(pos):
	var tile = grand_map.get_closes_tile(pos)
	show_selection(tile.pos, true)

func _on_ui_on_cancel():
	show_selection(Vector3.ZERO, false)

func _on_grand_map_on_navigation_updated(id :Vector2, data :NavigationData):
	nav_highlight_holder[id].set_surface_material(0, allow_nav if data.enable else blocked_nav)
	
func _on_grand_map_on_map_ready():
	Global.hide_transition()
	
	for i in grand_map_data.navigations:
		var nav :NavigationData = i
		var nav_highlight = preload("res://assets/tile_highlight/nav_highlight.tscn").instance()
		add_child(nav_highlight)
		nav_highlight.set_text_label("%s\n%s" % [nav.id, nav.navigation_id])
		nav_highlight.set_surface_material(0, allow_nav if nav.enable else blocked_nav)
		nav_highlight.translation = grand_map.get_tile(nav.id).translation
		nav_highlight.visible = false
		nav_highlight_holder[nav.id] = nav_highlight
		
func _on_ui_on_toggle_nav(show):
	for i in nav_highlight_holder.values():
		i.visible = show

func _on_ui_on_zoom_tile(pos):
	show_selection(Vector3.ZERO, false)
	var tile = grand_map.get_closes_tile(pos)
	if battle_map_datas.has(tile.id):
		Global.battle_map_name = grand_map_manifest_data.battle_map_names[tile.id]
		Global.battle_map_data = battle_map_datas[tile.id]
		Global.battle_map_id = tile.id
		grand_map_mission_data.edited_battle_maps[tile.id] = true
		Global.change_scene("res://menu/editor_battle/editor_battle.tscn")
	
func _on_ui_on_save():
	ui.set_visible(false)
	movable_camera_custom.translation = Vector3(0, 5, 2)
	yield(get_tree().create_timer(0.6),"timeout")
	
	var disable_sectors :Array = []
	for key in battle_map_datas.keys():
		if not grand_map.is_nav_enable(key):
			disable_sectors.append(key)
			
	for i in disable_sectors:
		battle_map_datas.erase(i)
		
	yield(Global.save_edited_map(),"completed")
	on_back_pressed()








