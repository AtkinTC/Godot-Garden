# SignalBus Singleton
# globally accessable signals to allow signal connections between nodes with minimal coupling

extends Node

# signal used to trigger the creation of a new effect scene
signal spawn_effect(effect_scene_path : String, effect_attributes : Dictionary)

signal node_selected(inst_id : int)
signal node_deselected(inst_id : int)
signal node_mouse_entered(inst_id : int)
signal node_mouse_exited(inst_id : int)
