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

const TILE_NAME_KEY := "tile_name"

var tiles_by_tile_name : Dictionary
var layers_by_name : Dictionary

func _ready():
	initialize()

func initialize():
	clear()
	
	# build reference dictionary of layers for quick reference
	for i in get_layers_count():
		var layer_name = get_layer_name(i)
		layers_by_name[layer_name] = i
	
	# build reference dictionary of tiles so they can be quickly referenced by a custom identifiers
	tiles_by_tile_name = {}
	for i_source in tile_set.get_source_count():
		var source_id : int = tile_set.get_source_id(i_source)
		var source : TileSetSource = tile_set.get_source(source_id)
		for i_tiles in source.get_tiles_count():
			var tile_id : Vector2i = source.get_tile_id(i_tiles)
			
			for i_alt in source.get_alternative_tiles_count(tile_id):
				var alt_id = source.get_alternative_tile_id(tile_id, i_alt)
				
				# organize tiles by custom data TILE_NAME_KEY
				var tile_data : TileData = source.get_tile_data(tile_id, alt_id)
				var tile_name = tile_data.get_custom_data(TILE_NAME_KEY)
				if(tile_name != null && tile_name.length() > 0):
					var tiles_array = tiles_by_tile_name.get(tile_name, [])
					tiles_array.append(TileIdentifier.new(source_id, tile_id, alt_id))
					tiles_by_tile_name[tile_name] = tiles_array

func set_cell_from_tile_identifier(coords: Vector2i, tile_identifier : TileIdentifier, layer : int = 0):
	set_cell(layer, coords, tile_identifier.source_id, tile_identifier.tile_id, tile_identifier.alt_id)
