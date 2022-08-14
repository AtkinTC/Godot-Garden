extends Node

var resource_dict: Dictionary = {}

const NAV_CONTR = "navigation_controller"
const WORLD = "world"

func reset():
	resource_dict = {}
	
func set_resource_reference(_resource_name: String, _resource) -> void:
	resource_dict[_resource_name] = _resource
	
func get_resource_reference(_resource_name: String):
	return resource_dict.get(_resource_name)


func set_current_game_world(world : World) -> void:
	resource_dict[WORLD] = world

func get_current_game_world() -> World:
	return resource_dict.get(WORLD, null)
