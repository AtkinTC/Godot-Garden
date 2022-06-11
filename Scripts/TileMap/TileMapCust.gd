class_name TileMapCust
extends TileMap

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
	for i in tile_set.get_source_count():
		var source_id : int = tile_set.get_source_id(i)
		var source : TileSetSource = tile_set.get_source(source_id)
		for j in source.get_tiles_count():
			var tile_id : Vector2i = source.get_tile_id(j)
			var tile_data : TileData = source.get_tile_data(tile_id, 0)
			
			# organize tiles by custom data TILE_NAME_KEY
			var tile_name = tile_data.get_custom_data(TILE_NAME_KEY)
			if(tile_name != null && tile_name.length() > 0):
				var tiles_array = tiles_by_tile_name.get(tile_name, [])
				tiles_array.append([source_id, tile_id])
				tiles_by_tile_name[tile_name] = tiles_array
