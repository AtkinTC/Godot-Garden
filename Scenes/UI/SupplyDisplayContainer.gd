extends VBoxContainer
class_name SupplyDisplayContainer

@export var supply_display_scene : PackedScene

var supply_displays_dict : Dictionary = {}

func _ready():
	SupplyManager.supplies_status_updated.connect(_supplies_status_updated)
	reset_contents()

# reset display contents, removing all display and recreating them based on current supply status
func reset_contents():
	supply_displays_dict = {}
	
	# remove any demo display elements
	for child in get_children():
		child.queue_free()

	for key in SupplyManager.get_visible_supply_type_keys():
		add_supply_display(key)
		
# create display scene for a supply if it hasn't already been added
func add_supply_display(_key: String) -> bool:
	if(supply_displays_dict.has(_key)):
		return false
	
	var supply_display : LargeSupplyDisplay = supply_display_scene.instantiate()
	supply_display.set_key(_key)
	add_child(supply_display)
	return true

# rebuild the display content whenever overall supplies status changes
func _supplies_status_updated():
	reset_contents()
