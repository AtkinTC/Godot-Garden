extends Node

var resource_dict: Dictionary = {}

const NAV_CONTR = "navigation_controller"

func reset():
	resource_dict = {}
	
func set_resource_reference(_resource_name: String, _resource) -> void:
	resource_dict[_resource_name] = _resource
	
func get_resource_reference(_resource_name: String):
	return resource_dict.get(_resource_name)
