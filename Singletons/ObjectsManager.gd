extends Node

signal objects_status_updated()

const DISPLAY_NAME := "display_name"

const LOCKED := "locked"
const DISABLED := "disabled"

const PURCHASABLE := "purchasable" 
const PURCHASE_COST := "purchase_cost"

const REMOVABLE := "removable"

const BUILD := "build"
const BUILD_LENGTH := "build_length"
const BUILD_COST := "build_cost"

const JOB := "job"
const JOB_LENGTH := "job_length"
const JOB_REQUIREMENTS := "job_requirements"
const JOB_COST := "job_cost"
const JOB_CONSUMPTION := "job_consumption"
const JOB_SATISFACTION_NEEDS := "job_satisfaction_need"
const JOB_SPEED_SATISFIED := "job_speed_satisfied"
const JOB_SPEED_UNSATISFIED := "job_speed_unsatisfied"
const JOB_COMPLETION_REWARD := "job_completion_reward"

const CAPACITY := "capacity"

const PASSIVE := "passive"
const PASSIVE_GAIN := "passive_gain"

const UPGRADE := "upgrade"
const UPGRADE_OBJECT := "upgrade_object"
const UPGRADE_LENGTH := "upgrade_length"
const UPGRADE_COST := "upgrade_cost"

var object_types := {
	"FOCUS_BASIC" : {
		DISPLAY_NAME : "focus lv.1",
		PURCHASABLE : false,
		REMOVABLE : false,
		PASSIVE_GAIN : {
			"AIR_ESS" : 1,
			"EARTH_ESS" : 1,
			"FIRE_ESS" : 1,
			"WATER_ESS" : 1
		},
		UPGRADE_OBJECT : "FOCUS_BASIC_LV2",
		UPGRADE_LENGTH : 10,
		UPGRADE_COST : {
			"AIR_ESS" : 20,
			"EARTH_ESS" : 20,
			"FIRE_ESS" : 20,
			"WATER_ESS" : 20
		},
		
	},
	"FOCUS_BASIC_LV2" : {
		DISPLAY_NAME : "focus lv.2",
		PURCHASABLE : false,
		REMOVABLE : false,
		PASSIVE_GAIN : {
			"AIR_ESS" : 2,
			"EARTH_ESS" : 2,
			"FIRE_ESS" : 2,
			"WATER_ESS" : 2
		},
		CAPACITY : {
			"AIR_ESS" : 25,
			"EARTH_ESS" : 25,
			"FIRE_ESS" : 25,
			"WATER_ESS" : 25
		}
	},
	"AIR_SOURCE_BASIC" : {
		DISPLAY_NAME : "air rune",
		PURCHASABLE : true,
		BUILD_COST : {
			"EARTH_ESS" : 10,
			"AIR_ESS" : 10
		},
		BUILD_LENGTH : 5,
		PASSIVE_GAIN : {
			"AIR_ESS" : 1
		},
		CAPACITY : {
			"AIR_ESS" : 10
		}
	},
	"EARTH_SOURCE_BASIC" : {
		DISPLAY_NAME : "earth rune",
		PURCHASABLE : true,
		BUILD_COST : {
			"EARTH_ESS" : 10,
		},
		BUILD_LENGTH : 5,
		PASSIVE_GAIN : {
			"EARTH_ESS" : 1
		},
		CAPACITY : {
			"EARTH_ESS" : 10
		}
	},
	"FIRE_SOURCE_BASIC" : {
		DISPLAY_NAME : "fire rune",
		PURCHASABLE : true,
		BUILD_COST : {
			"AIR_ESS" : 10,
			"FIRE_ESS" : 10
		},
		BUILD_LENGTH : 5,
		PASSIVE_GAIN : {
			"FIRE_ESS" : 1
		},
		CAPACITY : {
			"FIRE_ESS" : 10
		}
	},
	"WATER_SOURCE_BASIC" : {
		DISPLAY_NAME : "water rune",
		PURCHASABLE : true,
		BUILD_COST : {
			"EARTH_ESS" : 10,
			"WATER_ESS" : 10
		},
		BUILD_LENGTH : 5,
		PASSIVE_GAIN : {
			"WATER_ESS" : 1
		},
		CAPACITY : {
			"WATER_ESS" : 10
		}
	},
	"MIND_SOURCE_BASIC" : {
		DISPLAY_NAME : "mind rune",
		LOCKED : true,
		PURCHASABLE : true,
		BUILD_COST : {
			"EARTH_ESS" : 10,
			"AIR_ESS" : 10
		},
		BUILD_LENGTH : 5,
		PASSIVE_GAIN : {
			"MIND_ESS" : 1
		},
		CAPACITY : {
			"MIND_ESS" : 10
		}
	}
}

var selected_object_key: String

# setup initial state of objects
func initialize():
	for key in object_types.keys():
		object_types[key][PURCHASABLE] = object_types[key].get(PURCHASABLE, false)
		object_types[key][LOCKED] = object_types[key].get(LOCKED, false)
		object_types[key][DISABLED] = object_types[key].get(DISABLED, false)

# get keys of all objects that are available for direct purchase
func get_available_object_keys() -> Array:
	var available_keys = []
	for object_key in object_types.keys():
		if(object_types[object_key].get(PURCHASABLE, false) 
		&& !object_types[object_key].get(LOCKED, false)
		&& !object_types[object_key].get(DISABLED, false)):
			available_keys.append(object_key)
	return available_keys

func refresh_objects():
	if(selected_object_key not in get_available_object_keys()):
		selected_object_key = ""
	objects_status_updated.emit()

func get_object_type_keys() -> Array:
	return object_types.keys()

func get_object_type(object_type_key : String) -> Dictionary:
	return object_types.get(object_type_key, {})

func get_object_type_attribute(object_type_key : String, attribute_key : String, default = null):
	return object_types.get(object_type_key, {}).get(attribute_key, default)

func set_selected_object_key(object_key : String):
	selected_object_key = object_key

func get_selected_object_key() -> String:
	return selected_object_key

func unlock_object(_key : String):
	object_types[_key][LOCKED] = false
	refresh_objects()

func disable_object(_key : String):
	object_types[_key][DISABLED] = true
	refresh_objects()
