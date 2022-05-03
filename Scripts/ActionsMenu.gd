extends ItemList
class_name ActionsMenu

var action_list_indexes := {}

func _ready():
	clear()
	
	var index := 0
	for action_key in ActionManager.get_action_type_keys():
		var action_type : Dictionary = ActionManager.get_action_type(action_key)
		add_item(action_type[ActionManager.DISPLAY_NAME])
		action_list_indexes[index] = action_key
		
		if(index == 0):
			ActionManager.set_selected_action_key(action_key)
			select(0)
		
		index += 1

func _on_actions_menu_item_selected(index):
	ActionManager.set_selected_action_key(action_list_indexes[index])
