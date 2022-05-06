extends VBoxContainer
class_name ResourceDisplayContainer

@onready var resource_display_scene : PackedScene = preload("res://Scenes/UI/ResourceDisplay.tscn")

var resource_displays_dict: Dictionary = {}

func _ready():
	# remove any demo display elements
	for child in get_children():
		child.queue_free()

	for resource_key in ResourceManager.get_resource_keys():
		add_resource_display(resource_key)

# create display scene for a resource if it hasn't already been added
func add_resource_display(_resource_key: String) -> bool:
	if(resource_displays_dict.has(_resource_key)):
		return false
	
	var resource_display : ResourceDisplay = resource_display_scene.instantiate()
	resource_display.set_resource_key(_resource_key)
	add_child(resource_display)
	return true
