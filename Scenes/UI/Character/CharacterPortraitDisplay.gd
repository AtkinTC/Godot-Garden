class_name CharacterPortraitDisplay
extends MarginContainer

@export_node_path(TextureRect) var portrait_texture_node_path
@export_dir var portraits_directory : String

@onready var portrait_texture_node : TextureRect = get_node(portrait_texture_node_path) if portrait_texture_node_path else null

var portrait_name : String
var portrait_texture : Texture2D

var needs_update : bool = true

func _ready() -> void:	
	ready()

func ready():
	needs_update = true
	update_display()

func _process(_delta) -> void:
	update_display()

func update_display() -> void:
	if(!needs_update):
		return
	if(portrait_texture == null):
		portrait_texture = ResourceLoader.load(portraits_directory + "/portrait_default.png", "Texture2D")
	if(portrait_texture_node):
		portrait_texture_node.set_texture(portrait_texture)
	
	needs_update = false

func set_portrait(_portrait_texture : Texture2D) -> void:
	portrait_texture = _portrait_texture
	needs_update = true

func set_portrait_name(_portrait_name : String) -> void:
	portrait_name = _portrait_name
	if(ResourceLoader.exists(portraits_directory + "/" + portrait_name, "Texture2D")):
		portrait_texture = ResourceLoader.load(portraits_directory + "/" + portrait_name, "Texture2D")
	else:
		portrait_texture = ResourceLoader.load(portraits_directory + "/portrait_default.png", "Texture2D")
	needs_update = true
