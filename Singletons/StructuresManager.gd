extends Node

signal structures_updated()
signal selected_structure_updated()

var selected_structure_key : String

func initialize():
	SignalBus.locked_status_changed.connect(_on_locked_status_changed)
	selected_structure_key = ""

func get_available_structure_keys() -> Array:
	var available_keys = []
	for structure_key in Database.get_keys(Const.OBJECT):
		var structure_data := StructureDAO.new(structure_key)
		if(structure_data.is_locked() || structure_data.is_disabled()):
			continue
		if(structure_data.get_build_data().size() == 0):
			continue
		if(structure_data.get_build_limit() >= 0 && structure_data.get_build_limit() <= structure_data.get_count()):
			continue
		available_keys.append(structure_key)
		
	return available_keys

func set_selected_structure_key(structure_key : String):
	if(selected_structure_key != structure_key):
		selected_structure_key = structure_key
		selected_structure_updated.emit()

func get_selected_structure_key() -> String:
	return selected_structure_key

func get_structure_type(structure_key : String) -> Dictionary:
	return Database.get_entry(Const.OBJECT, structure_key)

func get_structure_type_attribute(structure_key : String, attribute_key : String, default = null):
	return Database.get_entry_attr(Const.OBJECT, structure_key, attribute_key, default)

func refresh_structures():
	if(selected_structure_key not in get_available_structure_keys()):
		set_selected_structure_key("")
	structures_updated.emit()

func set_structure_count(structure_key : String, count : int):
	Database.set_entry_attr(Const.OBJECT, structure_key, Const.COUNT, count)
	refresh_structures()

func adjust_structure_count(structure_key : String, adj : int):
	var count : int = Database.get_entry_attr(Const.OBJECT, structure_key, Const.COUNT, 0)
	set_structure_count(structure_key, count + adj)

func _on_locked_status_changed(category : String, _key : String):
	if(category == Const.OBJECT):
		refresh_structures()
