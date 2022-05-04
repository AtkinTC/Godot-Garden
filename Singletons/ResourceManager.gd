extends Node

const DISPLAY_NAME := "display_name"
const INITIAL_AMOUNT := "initial_amount"
const AMOUNT := "amount"

var resource_types := {
	"MONEY" : {
		"display_name" : "money",
		"initial_amount" : 100.00
	},
	"RESOURCE_1" : {
		"display_name" : "test",
		"initial_amount" : 99999.99
	}
}

var resources := {}

func _ready():
	for resource_key in resource_types.keys():
		var dict : Dictionary = resource_types.get(resource_key, {})
		dict[AMOUNT] = dict.get(INITIAL_AMOUNT, 0.00)
		resources[resource_key] = dict

func get_resource_keys() -> Array:
	return resources.keys()

func set_resource_attribute(resource_key : String, attribute_key : String, value : Variant):
	var dict = resources.get(resource_key, null)
	if(!dict):
		return
	dict[attribute_key] = value

func get_resource_attribute(resource_key : String, attribute_key : String):
	return resources.get(resource_key, {}).get(attribute_key, null)
