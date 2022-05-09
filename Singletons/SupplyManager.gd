extends Node

signal supplies_status_updated()

const DISPLAY_NAME := "display_name"
const QUANTITY_BASE := "quantity_base"
const QUANTITY := "quantity"
const CAPACITY_BASE := "base_capacity"
const CAPACITY := "capacity"

const DISPLAY_COLORS := "display_colors"

const LOCKED := "locked"

var supply_types := {
	"AIR_ESS" : {
		DISPLAY_NAME : "essence of air",
		DISPLAY_COLORS : [Color(0.45, 0.6, 0.7), Color(0.3, 0.4, 0.4)],
		CAPACITY_BASE : 10,
	},
	"EARTH_ESS" : {
		DISPLAY_NAME : "essence of earth",
		DISPLAY_COLORS : [Color(0.7, 0.6, 0.5), Color(0.3, 0.2, 0.15)],
		CAPACITY_BASE : 10,
	},
	"FIRE_ESS" : {
		DISPLAY_NAME : "essence of fire",
		DISPLAY_COLORS : [Color(0.7, 0.4, 0.0), Color(0.3, 0.0, 0.0)],
		CAPACITY_BASE : 10,
	},
	"WATER_ESS" : {
		DISPLAY_NAME : "essence of water",
		DISPLAY_COLORS : [Color(0.0, 0.0, 0.6), Color(0.0, 0.0, 0.2)],
		CAPACITY_BASE : 10,
	},
	"MIND_ESS" : {
		DISPLAY_NAME : "essence of the mind",
		LOCKED : true,
		CAPACITY_BASE : 10
	}
}

var supplies := {}

# setup initial state of supplies
func initialize():
	supplies = {}
	for key in supply_types.keys():
		var dict : Dictionary = supply_types.get(key, {})
		var supply := Supply.new(key, dict)
		supplies[key] = supply
		
func get_supply_type_keys() -> Array:
	return supplies.keys()

func get_visible_supply_type_keys() -> Array:
	var visible_keys = []
	for key in supplies.keys():
		if(!supplies[key].is_locked()):
			visible_keys.append(key)
	return visible_keys

func get_supply(_key : String) -> Supply:
	return supplies.get(_key)

func unlock_supply(_key : String):
	get_supply(_key).set_locked(false)
	supplies_status_updated.emit()

func connect_to_supply_quantity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_quantity_changed.connect(_callable)
		
func connect_to_supply_capacity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_capacity_changed.connect(_callable)
