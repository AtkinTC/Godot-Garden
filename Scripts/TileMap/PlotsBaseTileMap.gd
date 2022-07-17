class_name PlotsBaseTileMap
extends TileMapCust

const BASE_LAYER_NAME := "base"
const FEATURE_LAYER_NAME := "feature"

var base_type_map : Dictionary
var feature_type_map : Dictionary

func _ready():
	initialize()

func initialize():
	super.initialize()
	
	base_type_map = {}
	feature_type_map = {}
	
	assert(tiles_by_full_key.has(BASE_KEY + "_" + ERROR_KEY))
	assert(tiles_by_full_key.has(FEATURE_KEY + "_" + ERROR_KEY))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
	var coords : Array = GardenManager.get_used_plot_coords()
	
	for coord in coords:
		var coord_i : Vector2i = coord
		var plot : PlotVO = GardenManager.get_plot(coord_i)
		
		# base_type_key defaults to BASE_ERROR if the tile type isn't recognized
		var base_type_key = BASE_KEY + "_" + plot.base_type
		if(!tiles_by_full_key.has(base_type_key)):
			base_type_key = BASE_KEY + "_" + ERROR_KEY
		
		# sets the base tile if its type differs from what the type already recorded in base_type_map
		if(!base_type_map.has(coord_i) || base_type_map.get(coord_i) != base_type_key):
			base_type_map[coord_i] = base_type_key
			var tiles_array = tiles_by_full_key.get(base_type_key, null)
			if(tiles_array == null || tiles_array.size() == 0):
				print_debug("ERROR :: could not retrieve base tile " + base_type_key)
			else:
				var random_i = randi_range(0, tiles_array.size()-1)
				set_cell_from_tile_identifier(coord_i, tiles_array[random_i], layers_by_name[BASE_LAYER_NAME])
		
		# feature_type_key defaults to FEATURE_ERROR if the tile type isn't recognized
		var feature_type_key = FEATURE_KEY + "_" + plot.plot_type
		if(!tiles_by_full_key.has(feature_type_key)):
			feature_type_key = FEATURE_KEY + "_" + ERROR_KEY

		# sets the feature tile if its type differs from what the type already recorded in feature_type_map
		if(!feature_type_map.has(coord_i) || feature_type_map.get(coord_i) != feature_type_key):
			feature_type_map[coord_i] = feature_type_key
			var tiles_array = tiles_by_full_key.get(feature_type_key, null)
			if(tiles_array == null || tiles_array.size() == 0):
				print_debug("ERROR :: could not retrieve feature tile " + feature_type_key)
			else:
				var random_i = randi_range(0, tiles_array.size()-1)
				set_cell_from_tile_identifier(coord_i, tiles_array[random_i], layers_by_name[FEATURE_LAYER_NAME])
		
		unused_cells.erase(coord_i)
	
	# erase any previously set tiles for plots that no longer exist
	for coord in unused_cells:
		var coord_i : Vector2i = coord
		erase_cell(0, coord_i)
		base_type_map.erase(coord_i)
		feature_type_map.erase(coord_i)

