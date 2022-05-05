extends Node

const DISPLAY_NAME := "display_name"

const PURCHASABLE := "purchasable"
const PURCHASE_BASE_COST := "purchase_base_cost"

const JOB_LENGTH := "job_length"
const JOB_REQUIREMENTS := "job_requirements"
const JOB_RESOURCE_COST := "job_resource_cost"
const JOB_RESOURCE_CONSUMPTION := "job_resource_consumption"
const JOB_SATISFACTION_NEEDS := "job_satisfaction_need"
const JOB_SPEED_SATISFIED := "job_speed_satisfied"
const JOB_SPEED_UNSATISFIED := "job_speed_unsatisfied"
const JOB_COMPLETION_REWARD := "job_completion_reward"

const GROW_CAPACITY := "grow_capacity"
const GROW_SPEED_UNSATISFIED = "grow_speed_unsatisfied"
const GROW_SPEED_SATISFIED = "grow_speed_satisfied"
const WATER_CONSUMPTION = "water_consumption"
const PURCHASE_PRICE = "purchase_price"
const SELL_PRICE = "sell_price"

var object_types := {
	"FOCUS_BASIC" : {
		DISPLAY_NAME : "focus",
		PURCHASABLE : false,
		JOB_LENGTH : 15,
		JOB_SPEED_SATISFIED : 1,
		JOB_COMPLETION_REWARD : {
			"AIR_ESS" : 1,
			"EARTH_ESS" : 1,
			"FIRE_ESS" : 1,
			"WATER_ESS" : 1
		}
	},
	"WATER_SOURCE_BASIC" : {
		DISPLAY_NAME : "simple well",
		PURCHASABLE : true,
		PURCHASE_BASE_COST : {
			"EARTH_ESS" : 10,
			"WATER_ESS" : 10
		},
		JOB_LENGTH : 15,
		JOB_SPEED_SATISFIED : 1,
		JOB_COMPLETION_REWARD : {
			"WATER_ESS" : 1
		}
	},
	"FIRE_SOURCE_BASIC" : {
		DISPLAY_NAME : "small fire",
		PURCHASABLE : true,
		PURCHASE_BASE_COST : {
			"AIR_ESS" : 10,
			"FIRE_ESS" : 10
		},
		JOB_LENGTH : 20,
		JOB_SPEED_SATISFIED : 1,
		JOB_COMPLETION_REWARD : {
			"FIRE_ESS" : 1
		}
	},
	
}

var selected_object_key: String

# get keys of all objects that are available for purchase
func get_available_object_keys() -> Array:
	var available_keys = []
	for object_key in object_types.keys():
		if(object_types[object_key].get(PURCHASABLE)):
			available_keys.append(object_key)
	return available_keys

func get_object_type_keys() -> Array:
	return object_types.keys()

func get_object_type(object_type_key : String) -> Dictionary:
	return object_types.get(object_type_key, {})

func get_object_type_attribute(object_type_key : String, attribute_key : String):
	return object_types.get(object_type_key, {}).get(attribute_key, null)

func set_selected_object_key(object_key : String):
	selected_object_key = object_key

func get_selected_object_key() -> String:
	return selected_object_key
