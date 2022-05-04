extends Node

signal action_selected(action_key:String)

const DISPLAY_NAME := "display_name"
const TARGET_TYPE := "target_type"
const FUNC_NAME := "func_name"

var selected_action_key : String

var action_types := {
	"PLANT" : {
		"display_name" : "Plant Seed",
		"target_type" : "GardenPlot",
		"func_name" : "plant_plot"
	},
	"WATER_BASIC" : {
		"display_name" : "Water",
		"target_type" : "GardenPlot",
		"func_name" : "water_plot"
	}
}

func apply_current_action_to_garden_plot(garden_plot : GardenPlot):
	apply_action_to_garden_plot(selected_action_key, garden_plot)

func apply_action_to_garden_plot(action_key : String, garden_plot : GardenPlot):
	var action_dict = action_types.get(action_key)
	if(action_dict == null || action_dict.size() == 0):
		return false
	if(action_dict.get(TARGET_TYPE, "") != "GardenPlot"):
		return false
	if(!garden_plot.has_method(action_dict.get(FUNC_NAME, ""))):
		return false
	
	garden_plot.call(action_dict.get(FUNC_NAME))
	return true

func get_action_type_keys() -> Array:
	return action_types.keys()

func get_action_type(action_type_key : String) -> Dictionary:
	return action_types.get(action_type_key, {})

func set_selected_action_key(action_type_key : String):
	selected_action_key = action_type_key
	action_selected.emit(selected_action_key)

func get_selected_action_key() -> String:
	return selected_action_key

func connect_action_selected(reciever):
	action_selected.connect(reciever._on_action_selected)
