extends MarginContainer

signal pressed
var data :GrandMapFileManifest
onready var texture_rect = $Button/TextureRect
onready var label = $Button/VBoxContainer/Label

func _ready():
	var img = Image.new()
	img.load(data.map_image_file_path)
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	texture_rect.texture = tex
	label.text = data.map_name

func _on_Button_pressed():
	emit_signal("pressed", data)
