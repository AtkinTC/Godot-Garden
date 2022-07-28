class_name TileMapCust
extends TileMap

@export var custom_data_layer_names : Array[String] = []

var layers_by_name : Dictionary

var tile_defs : Dictionary
var tiles_by_custom_data : Dictionary

func _ready():
	initialize()

func initialize():
	# build reference dictionary of layers for quick reference
	layers_by_name = {}
	for i in get_layers_count():
		var layer_name = get_layer_name(i)
		layers_by_name[layer_name] = i
	
	tile_defs = {}
	tiles_by_custom_data = {}
	# build reference dictionary of tiles so they can be quickly referenced by a custom identifiers
	for i_source in tile_set.get_source_count():
		var source_id : int = tile_set.get_source_id(i_source)
		var source : TileSetSource = tile_set.get_source(source_id)
		for i_tiles in source.get_tiles_count():
			var tile_id : Vector2i = source.get_tile_id(i_tiles)
			
			for i_alt in source.get_alternative_tiles_count(tile_id):
				var alt_id = source.get_alternative_tile_id(tile_id, i_alt)
				
				var tile_data : TileData = source.get_tile_data(tile_id, alt_id)
				
				var custom_data := {}
				for key in custom_data_layer_names:
					var custom_data_layer_data = tile_data.get_custom_data(key)
					custom_data[key] = custom_data_layer_data
				
#				var custom_data := {}
#				for i_data in tile_set.get_custom_data_layers_count():
#					var custom_data_layer_name = tile_data.get_custom_data_name(i_data)
#					var custom_data_layer_data = tile_data.get_custom_data_by_layer_id(i_data)
#					custom_data[custom_data_layer_name] = custom_data_layer_data
				
				var tile_def := TileDefinition.new(source_id, tile_id, alt_id, custom_data)
				
				tile_defs[tile_def.get_key()] = tile_def
				for key in custom_data.keys():
					var value : Variant = custom_data[key]
					var custom_data_dic : Dictionary = tiles_by_custom_data.get(key, {})
					var tiles : Array = custom_data_dic.get(value, [])
					
					tiles.append(tile_def)
					
					custom_data_dic[value] = tiles
					tiles_by_custom_data[key] = custom_data_dic

func set_cell_from_tile_identifier(coords: Vector2i, tile_def : TileDefinition, layer : int = 0):
	set_cell(layer, coords, tile_def.source_id, tile_def.tile_id, tile_def.alt_id)

func get_tile_size() -> Vector2i:
	return get_tileset().get_tile_size()

func get_tile_identifier_for_cell(coord: Vector2i, layer_name : String = "") -> TileDefinition:
	var layer_id : int = layers_by_name[layer_name]
	var source_id : int = get_cell_source_id(layer_id, coord, false)
	var tile_id: Vector2i = get_cell_atlas_coords(layer_id, coord, false)
	var alt_id : int = get_cell_alternative_tile(layer_id, coord, false)
	var temp_tile_def : TileDefinition = TileDefinition.new(source_id, tile_id, alt_id)
	return tile_defs.get(temp_tile_def.get_key(), null)
