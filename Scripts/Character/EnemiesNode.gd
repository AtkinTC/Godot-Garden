class_name EnemiesNode
extends Node2D

@onready var world : World = self.get_parent()

var enemies_dict : Dictionary
var next_char_id : int

@export var world_unit_scene : PackedScene

func _init() -> void:
	enemies_dict = {}
	next_char_id = 0

func _ready() -> void:
	# clear out test content
	for child in get_children():
		child.queue_free()

# trigger the creation of a WorldUnitNode when a new WorldUnitVO is created
func _on_world_unit_created(id : int):
	pass

# instantiate new
func create_enemy(enemy_scene : PackedScene, params : Dictionary = {}) -> int:
	var new_id : int = max(params.get("id", 0), next_char_id)
	next_char_id = new_id + 1
	
	if(!params.has("id")):
		params["id"] = new_id
	
	if(!params.has("world") && world != null):
		params["world"] = world
	
	var enemy: Node2D = enemy_scene.instantiate()
	if(enemy.has_method("set_setup_params")):
		enemy.set_setup_params(params)
	
	enemy.tree_exiting.connect(_on_enemy_exiting.bind(new_id))
	
	add_child(enemy)
	enemies_dict[new_id] = enemy
	
	return new_id

func get_enemies() -> Array:
	return enemies_dict.values()

func get_enemy_ids() -> Array:
	return enemies_dict.keys()

func get_enemy(enemy_id : int) -> Node2D:
	return enemies_dict.get(enemy_id, null)

func _on_enemy_exiting(enemy_id : int):
	if(enemies_dict.has(enemy_id)):
		enemies_dict.erase(enemy_id)
