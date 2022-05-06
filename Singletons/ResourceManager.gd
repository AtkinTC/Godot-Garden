extends Node

signal resource_quantity_changed(resource_key, old_quantity, new_quantity)

const DISPLAY_NAME := "display_name"
const QUANTITY_BASE := "quantity_base"
const QUANTITY := "quantity"
const CAPACITY_BASE := "base_capacity"
const CAPACITY := "capacity"

const DISPLAY_COLORS := "display_colors"

var resource_types := {
	"MONEY" : {
		DISPLAY_NAME : "money",
		CAPACITY_BASE : 20,
		QUANTITY_BASE : 1.00
	},
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

var resources := {}

func _ready():
	for resource_key in resource_types.keys():
		var dict : Dictionary = resource_types.get(resource_key, {})
		dict[QUANTITY] = dict.get(QUANTITY_BASE, 0.00)
		dict[CAPACITY] = dict.get(CAPACITY_BASE, -1)
		resources[resource_key] = dict

func get_resource_keys() -> Array:
	return resources.keys()

func set_resource_attribute(resource_key : String, attribute_key : String, value : Variant):
	var dict = resources.get(resource_key, null)
	if(dict == null || dict.size() == 0):
		return
	dict[attribute_key] = value

func get_resource_attribute(resource_key : String, attribute_key : String, default = null):
	return resources.get(resource_key, {}).get(attribute_key, default)

func change_resource_quantity(_resource_key: String, _change: float):
	var old_quantity = get_resource_attribute(_resource_key, QUANTITY, 0.0)
	set_resource_quantity(_resource_key, old_quantity + _change)

func set_resource_quantity(_resource_key: String, _quantity: float):
	var old_quantity = get_resource_attribute(_resource_key, QUANTITY, 0.0)
	if(_quantity != old_quantity):
		set_resource_attribute(_resource_key, QUANTITY, _quantity)
		resource_quantity_changed.emit(_resource_key, old_quantity, _quantity)
