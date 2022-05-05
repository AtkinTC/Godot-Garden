extends ItemList
class_name PurchaseMenu

var objects_list_indexes := {}

func _ready():
	clear()
	
	var index := 0
	for object_key in ObjectsManager.get_available_object_keys():
		var object_type : Dictionary = ObjectsManager.get_object_type(object_key)
		add_item(str(object_type[ObjectsManager.DISPLAY_NAME]))
		objects_list_indexes[index] = object_key
		
		if(index == 0):
			ObjectsManager.set_selected_object_key(object_key)
			select(0)
		
		index += 1

func _on_purchase_menu_item_selected(index):
	ObjectsManager.set_selected_object_key(objects_list_indexes[index])
	ActionManager.set_selected_action_key("SET_OBJECT")
