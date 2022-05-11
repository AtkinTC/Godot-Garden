extends Node

signal action_selected(action_key:String)

var action_types : Dictionary
var selected_action_key : String

# setup initial state of objects
func initialize():
	action_types = ActionData.action_types
	for key in action_types.keys():
		action_types[key][Const.LOCKED] = action_types[key].get(Const.LOCKED, false)
		action_types[key][Const.DISABLED] = action_types[key].get(Const.DISABLED, false)

func apply_current_action_to_plot(plot_coord : Vector2):
	apply_action_to_plot(selected_action_key, plot_coord)

# apply an action to a plot cell
# will call the plot's function that corresponds to the specified action_key
func apply_action_to_plot(action_key : String, plot_coord : Vector2):
	var action_dict = action_types.get(action_key)
	if(action_dict == null || action_dict.size() == 0):
		return false
	if(action_dict.get(Const.TARGET_TYPE, "") != "Plot"):
		return false
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot.has_method(action_dict.get(Const.FUNC_NAME, ""))):
		return false
	
	plot.call(action_dict.get(Const.FUNC_NAME))
	return true

func get_action_type_keys() -> Array:
	return action_types.keys()

# get the list of action_keys that can be displayd and selected
func get_available_action_keys() -> Array:
	var available_keys = []
	for key in action_types.keys():
		if(action_types[key].get(Const.DISPLAY, false)):
			available_keys.append(key)
	return available_keys

func get_action_type(action_type_key : String) -> Dictionary:
	return action_types.get(action_type_key, {})

func set_selected_action_key(action_type_key : String):
	selected_action_key = action_type_key
	action_selected.emit(selected_action_key)

func get_selected_action_key() -> String:
	return selected_action_key

func connect_action_selected(reciever_method : Callable):
	action_selected.connect(reciever_method)
