extends VBoxContainer
class_name SupplyDisplayContainer

@onready var supply_display_scene : PackedScene = preload("res://Scenes/UI/SupplyDisplay.tscn")

var supply_displays_dict: Dictionary = {}

func _ready():
	# remove any demo display elements
	for child in get_children():
		child.queue_free()

	for key in SupplyManager.get_visible_supply_type_keys():
		add_supply_display(key)

# create display scene for a supply if it hasn't already been added
func add_supply_display(_key: String) -> bool:
	if(supply_displays_dict.has(_key)):
		return false
	
	var supply_display : SupplyDisplay = supply_display_scene.instantiate()
	supply_display.set_key(_key)
	add_child(supply_display)
	return true
