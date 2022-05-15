extends Node

signal objects_data_updated(key)

var database : Dictionary

# setup initial state of objects
func initialize():
	database[Const.ACTION] = ActionData.action_types.duplicate(true)
	database[Const.OBJECT] = ObjectData.object_types.duplicate(true)
	database[Const.SUPPLY] = SupplyData.supply_types.duplicate(true)
	database[Const.ENHANCEMENT] = EnhancementData.upgrade_types.duplicate(true)

func get_category(category : String):
	return database.get(category, {}).duplicate(true)

func get_keys(category : String) -> Array:
	return get_category(category).keys()

func get_entry(category : String, key : String) -> Dictionary:
	return get_category(category).get(key, {}).duplicate(true)

func get_entry_attr(category : String, key : String, attr : String, default = {}):
	return get_entry(category, key).get(attr, default)

func set_entry_attr(category : String, key : String, attr : String, value):
	var entry := get_entry(category, key)
	entry[attr] = value
	database[category][key] = entry
