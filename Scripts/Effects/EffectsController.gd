# EffectsController extends Node
# 	handles the creation of Effect nodes
# 	parent of all Effect nodes

class_name EffectsController
extends Node

var packed_scenes := {}

@onready var corpse_effect_layer : Node2D = get_node_or_null("%CorpseEffectsLayer")

func _ready() -> void:
	SignalBus.spawn_effect.connect(_on_spawn_effect)

func _on_spawn_effect(effect_scene_path : String, effect_attributes : Dictionary):
	var effect_scene : PackedScene = packed_scenes.get(effect_scene_path)
	if(effect_scene == null):
		effect_scene = load(effect_scene_path)
		packed_scenes[effect_scene_path] = effect_scene
	var effect : Effect = effect_scene.instantiate()
	effect.setup_from_attribute_dictionary(effect_attributes)
	effect.tree_exiting.connect(_on_effect_tree_exiting.bind(effect.get_instance_id()))
	
	if(effect is CorpseEffect && corpse_effect_layer):
		corpse_effect_layer.add_child(effect)
	else:
		add_child(effect)

func _on_effect_tree_exiting(_instance_id : int):
	#print("effect exiting tree " + str(_instance_id))
	pass
