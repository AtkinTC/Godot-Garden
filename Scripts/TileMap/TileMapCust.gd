class_name TileMapCust
extends TileMap

class TileIdentifier:
	var source_id : int
	var tile_id : Vector2i
	var alt_id : int
	
	func _init(_source_id : int, _tile_id : Vector2i, _alt_id : int):
		source_id = _source_id
		tile_id = _tile_id
		alt_id = _alt_id
	
	func _to_string() -> String:
		return str(source_id) + ":" + str(tile_id) + ":" + str(alt_id)

const TILE_NAME_KEY := "tile_name"
const TILE_TYPE_KEY := "tile_type"

const BASE_KEY := "base"
const FEATURE_KEY := "feature"
const ICON_KEY := "icon"

const ERROR_KEY := "ERROR"

var tiles_by_full_key : Dictionary

var layers_by_name : Dictionary

func _ready():
	initialize()

func initialize():
	# build reference dictionary of layers for quick reference
	for i in get_layers_count():
		var layer_name = get_layer_name(i)
		layers_by_name[layer_name] = i
	
	# build reference dictionary of tiles so they can be quickly referenced by a custom identifiers
	tiles_by_full_key = {}
	for i_source in tile_set.get_source_count():
		var source_id : int = tile_set.get_source_id(i_source)
		var source : TileSetSource = tile_set.get_source(source_id)
		for i_tiles in source.get_tiles_count():
			var tile_id : Vector2i = source.get_tile_id(i_tiles)
			
			for i_alt in source.get_alternative_tiles_count(tile_id):
				var alt_id = source.get_alternative_tile_id(tile_id, i_alt)
				
				var tile_data : TileData = source.get_tile_data(tile_id, alt_id)
				var tile_identifier : TileIdentifier = TileIdentifier.new(source_id, tile_id, alt_id)
				
				var tile_name = tile_data.get_custom_data(TILE_NAME_KEY)
				var tile_type = tile_data.get_custom_data(TILE_TYPE_KEY)
				
				var tile_error := false
				if(!(tile_name is String) || tile_name.length() == 0):
					print_debug("ERROR :: invalid tile_name for tile " + str(tile_identifier))
					tile_error = true
				if(!(tile_type is String) || tile_type.length() == 0):
					print_debug("ERROR :: invalid tile_type for tile " + str(tile_identifier))
					tile_error = true
				
				# organize tiles by a compiled tile string <TILE_TYPE_KEY>_<TILE_NAME_KEY>
				if(!tile_error):
					var tile_full_key := str(tile_type) + "_" + str(tile_name)
					var tiles_array = tiles_by_full_key.get(tile_full_key, [])
					tiles_array.append(tile_identifier)
					tiles_by_full_key[tile_full_key] = tiles_array

func set_cell_from_tile_identifier(coords: Vector2i, tile_identifier : TileIdentifier, layer : int = 0):
	set_cell(layer, coords, tile_identifier.source_id, tile_identifier.tile_id, tile_identifier.alt_id)

func get_tile_key_for_cell(coord: Vector2i, layer_name : String = "") -> String:
	var layer_id : int = layers_by_name[layer_name]
	var source_id : int = get_cell_source_id(layer_id, coord, false)
	var tile_id: Vector2i = get_cell_atlas_coords(layer_id, coord, false)
	var alt_id : int = get_cell_alternative_tile(layer_id, coord, false)
	for tile_key in tiles_by_full_key.keys():
		var tiles : Array = tiles_by_full_key[tile_key]
		for tile in tiles:
			if(tile.source_id == source_id && tile.tile_id == tile_id && tile.alt_id == alt_id):
				return tile_key
	return ""
