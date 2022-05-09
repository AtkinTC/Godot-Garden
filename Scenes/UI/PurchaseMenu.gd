extends ItemList
class_name PurchaseMenu

var objects_list_indexes := {}

func _ready():
	ObjectsManager.objects_status_updated.connect(_objects_status_updated)
	reset_menu()

func reset_menu():
	clear()
	deselect_all()
	
	objects_list_indexes = {}
	var index := 0
	for object_key in ObjectsManager.get_available_object_keys():
		var object_type : Dictionary = ObjectsManager.get_object_type(object_key)
		add_item(str(object_type[Const.DISPLAY_NAME]))
		objects_list_indexes[index] = object_key
		
		index += 1

func _on_purchase_menu_item_selected(index):
	ObjectsManager.set_selected_object_key(objects_list_indexes[index])
	ActionManager.set_selected_action_key("PURCHASE_PLOT_OBJECT")

# rebuild the menu content whenever overall object status changes
func _objects_status_updated():
	reset_menu()
