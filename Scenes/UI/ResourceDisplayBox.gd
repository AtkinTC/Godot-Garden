extends VBoxContainer
class_name ResourceDisplayBox

@onready var resource_display_scene : PackedScene = preload("res://Scenes/UI/ResourceDisplay.tscn")

func _ready():
	for child in get_children():
		child.queue_free()

	for resource_key in ResourceManager.get_resource_keys():
		var resource_display : ResourceDisplay = resource_display_scene.instantiate()
		resource_display.set_resource_key(resource_key)
		add_child(resource_display)
