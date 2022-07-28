class_name TileDefinition
extends Resource
	
var source_id : int
var tile_id : Vector2i
var alt_id : int
var custom_data : Dictionary

func _init(_source_id : int, _tile_id : Vector2i, _alt_id : int, _custom_data : Dictionary = {}):
	source_id = _source_id
	tile_id = _tile_id
	alt_id = _alt_id
	custom_data = _custom_data

func get_custom_data(data_key : String, default : Variant = null) -> Variant:
	return custom_data.get(data_key, default)

func get_key() -> String:
	return str(source_id) + ":" + str(tile_id) + ":" + str(alt_id)

func _to_string() -> String:
	return str(source_id) + ":" + str(tile_id) + ":" + str(alt_id) + " -> " + str(custom_data)
