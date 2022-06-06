extends Node

signal objects_status_updated()
signal selected_object_changed()

var selected_object_key: String

# setup initial state of objects
func initialize():
	SignalBus.locked_status_changed.connect(_on_locked_status_changed)
	selected_object_key = ""

func is_disabled(key : String) -> bool:
	return Database.get_entry_attr(Const.OBJECT, key, Const.DISABLED, false)

# get keys of all objects that are available for direct purchase
func get_available_object_keys() -> Array:
	var available_keys = []
	for key in Database.get_keys(Const.OBJECT):
		if(!is_disabled(key) && !LockUtil.is_locked(Const.OBJECT, key)):
			available_keys.append(key)
	return available_keys

func refresh_objects():
	if(selected_object_key not in get_available_object_keys()):
		selected_object_key = ""
	objects_status_updated.emit()

func get_object_type(key : String) -> Dictionary:
	return Database.get_entry(Const.OBJECT, key)

func get_object_type_attribute(object_type_key : String, attribute_key : String, default = null):
	return Database.get_entry_attr(Const.OBJECT, object_type_key, attribute_key, default)

func set_selected_object_key(object_key : String):
	selected_object_key = object_key
	selected_object_changed.emit()

func get_selected_object_key() -> String:
	return selected_object_key

func disable_object(key : String):
	Database.set_entry_attr(Const.OBJECT, key, Const.DISABLED, true)
	refresh_objects()

func set_object_count(key : String, count : int):
	Database.set_entry_attr(Const.OBJECT, key, Const.COUNT, count)
	refresh_objects()

func adjust_object_count(key : String, adj : int):
	var count : int = Database.get_entry_attr(Const.OBJECT, key, Const.COUNT, 0)
	set_object_count(key, count + adj)

func _on_locked_status_changed(category : String, _key : String):
	if(category == Const.OBJECT):
		refresh_objects()
