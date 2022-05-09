extends Node

signal objects_status_updated()

var object_types : Dictionary
var selected_object_key: String

# setup initial state of objects
func initialize():
	object_types = ObjectData.object_types
	for key in object_types.keys():
		object_types[key][Const.PURCHASABLE] = object_types[key].get(Const.PURCHASABLE, false)
		object_types[key][Const.LOCKED] = object_types[key].get(Const.LOCKED, false)
		object_types[key][Const.DISABLED] = object_types[key].get(Const.DISABLED, false)

# get keys of all objects that are available for direct purchase
func get_available_object_keys() -> Array:
	var available_keys = []
	for object_key in object_types.keys():
		if(object_types[object_key].get(Const.PURCHASABLE, false) 
		&& !object_types[object_key].get(Const.LOCKED, false)
		&& !object_types[object_key].get(Const.DISABLED, false)):
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
	object_types[_key][Const.LOCKED] = false
	refresh_objects()

func disable_object(_key : String):
	object_types[_key][Const.DISABLED] = true
	refresh_objects()
