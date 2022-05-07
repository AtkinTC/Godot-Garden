extends Node

const DISPLAY_NAME := "display_name"
const QUANTITY_BASE := "quantity_base"
const QUANTITY := "quantity"
const CAPACITY_BASE := "base_capacity"
const CAPACITY := "capacity"

const DISPLAY_COLORS := "display_colors"

var supply_types := {
	"AIR_ESS" : {
		DISPLAY_NAME : "essence of air",
		CAPACITY_BASE : 10,
		DISPLAY_COLORS : [Color(0.45, 0.6, 0.7), Color(0.3, 0.4, 0.4)]
	},
	"EARTH_ESS" : {
		DISPLAY_NAME : "essence of earth",
		CAPACITY_BASE : 10,
		DISPLAY_COLORS : [Color(0.7, 0.6, 0.5), Color(0.3, 0.2, 0.15)]
	},
	"FIRE_ESS" : {
		DISPLAY_NAME : "essence of fire",
		CAPACITY_BASE : 10,
		DISPLAY_COLORS : [Color(0.7, 0.4, 0.0), Color(0.3, 0.0, 0.0)]
	},
	"WATER_ESS" : {
		DISPLAY_NAME : "essence of water",
		CAPACITY_BASE : 10,
		DISPLAY_COLORS : [Color(0.0, 0.0, 0.6), Color(0.0, 0.0, 0.2)]
	},
}

var supplies := {}

func _ready():
	supplies = {}
	for key in supply_types.keys():
		var dict : Dictionary = supply_types.get(key, {})
		var supply := Supply.new(key, dict)
		supplies[key] = supply

func get_supply_type_keys() -> Array:
	return supplies.keys()

func get_supply(_key : String) -> Supply:
	return supplies.get(_key)

func connect_to_supply_quantity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_quantity_changed.connect(_callable)
