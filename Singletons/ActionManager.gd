extends Node

signal actions_status_updated()
signal selected_action_changed()

var selected_action_key : String

# setup initial state of objects
func initialize():
	selected_action_key = ""

func apply_current_action_to_plot(plot_coord : Vector2):
	apply_action_to_plot(selected_action_key, plot_coord)

# apply an action to a plot cell
# will call the plot's function that corresponds to the specified action_key
func apply_action_to_plot(action_key : String, plot_coord : Vector2):
	var action_dict = Database.get_entry(Const.ACTION, action_key)
	if(action_dict == null || action_dict.size() == 0):
		return false
	if(action_dict.get(Const.TARGET_TYPE, "") != "PlotVO"):
		return false
	var plot : PlotVO = GardenManager.get_plot(plot_coord)
	if(!plot.has_method(action_dict.get(Const.FUNC_NAME, ""))):
		return false
	
	plot.call(action_dict.get(Const.FUNC_NAME))
	return true

# get the list of action_keys that can be displayd and selected
func get_available_action_keys() -> Array:
	var available_keys = []
	for key in Database.get_keys(Const.ACTION):
		if(Database.get_entry_attr(Const.ACTION, key, Const.DISPLAY, false)):
			available_keys.append(key)
	return available_keys

func get_action_type(action_type_key : String) -> Dictionary:
	return Database.get_entry(Const.ACTION, action_type_key)

func set_selected_action_key(action_type_key : String):
	selected_action_key = action_type_key
	selected_action_changed.emit()

func get_selected_action_key() -> String:
	return selected_action_key
