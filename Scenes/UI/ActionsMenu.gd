extends ItemList
class_name ActionsMenu

var action_list_indexes := {}
var selected_action_key : String

func _ready():
	clear()
	
	# connect to action_selected signal for automatic updates
	ActionManager.connect_action_selected(_on_action_selected)
	
	var index := 0
	for action_key in ActionManager.get_action_type_keys():
		var action_type : Dictionary = ActionManager.get_action_type(action_key)
		add_item(action_type[Const.DISPLAY_NAME])
		action_list_indexes[index] = action_key
		
		index += 1

# send selected action to ActionManager
func select_action(index : int):
	ActionManager.set_selected_action_key(action_list_indexes[index])

# update selection UI when triggered by action_selection signal
func _on_action_selected(_action_key : String):
	if(_action_key != selected_action_key):
		for index in action_list_indexes.keys():
			if(action_list_indexes[index] == _action_key):
				select(index)
				selected_action_key = _action_key
				break

func _on_actions_menu_item_selected(index):
	select_action(index)
