class_name CellDefinitionSet
extends Resource

const res_save_directory := "res://Assets/Resource/"
const res_suffix := ".tres"

static func load_cell_definition_set(_resource_name : String) -> CellDefinitionSet:
	var path : String = res_save_directory + _resource_name + res_suffix
	var result = load(path)
	if(result is CellDefinitionSet):
		return result
	return null

func save() -> bool:
	var dir = Directory.new()
	if(!dir.dir_exists(res_save_directory)):
		dir.make_dir_recursive(res_save_directory)
	
	if(resource_name == null || resource_name.length() == 0):
		return false
	if(cell_defs_dictionary == null || cell_defs_dictionary.size() == 0):
		return false
	
	var path : String = res_save_directory + resource_name + res_suffix
	var result = ResourceSaver.save(path, self)
	
	if(result != 0):
		print_debug("Failed to save with error : " + str(result) + " : " + str(error_string(result)))
		return false
		
	print_debug("CellDefinitionSet saved at : " + path)
	return true

@export var cell_defs_dictionary : Dictionary = {}
