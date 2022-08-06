class_name LevelLoader
extends Node2D

@export var level_scene : PackedScene
var level : Level

var level_ready : bool = false

func _ready():
	level = get_node_or_null("Level")
	
	if(level_scene != null):
		load_level(level_scene)
	elif(level is Level):
		_on_level_ready()
	else:
		#do nothing
		pass

func load_level(_level_scene : PackedScene):
	if(!_level_scene || !_level_scene.can_instantiate()):
		print_debug("cannot load level " + _level_scene.resource_path)
		return
	level_scene = _level_scene
	
	if(level != null):
		level.queue_free()
	level = level_scene.instantiate()
	level.ready.connect(_on_level_ready)
	add_child(level)
		
func _on_level_ready():
	level.show_behind_parent = true
	level_ready = true
	print("level " + level_scene.resource_path + " ready")

func _process(_delta):
	pass

