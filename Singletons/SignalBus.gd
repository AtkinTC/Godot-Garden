# SignalBus Singleton
# globally accessable signals to allow signal connections between nodes with minimal coupling

extends Node

# signal used to trigger the creation of a new effect scene
signal spawn_effect(effect_scene_path : String, effect_attributes : Dictionary)
