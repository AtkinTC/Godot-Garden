extends TileMap

const TILE_NAME_KEY := "tile_name"
const PLOT_TYPE_KEY := "plot_type"

const ERR_PLOT_TYPE := "ERROR"
const BORDER_TILE_NAME := "border"
const UNEXPLORED_ICON_NAME := "question"

var PLOT_LAYER := "plots"
var BORDER_LAYER := "borders"
var ICON_LAYER := "icons"

var tiles_by_tile_name : Dictionary
var tiles_by_plot_type : Dictionary
var layers_by_name : Dictionary

var plot_type_map : Dictionary

var display_borders : bool = true

func _ready():
	clear()
	
	# build reference dictionary of layers for quick reference
	for i in get_layers_count():
		var layer_name = get_layer_name(i)
		layers_by_name[layer_name] = i
	
	assert(layers_by_name.has(PLOT_LAYER))
	assert(layers_by_name.has(ICON_LAYER))
	
	# build reference dictionaries of tiles so they can be quickly referenced by a custom identifiers
	tiles_by_tile_name = {}
	tiles_by_plot_type = {}
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
			
			# organize tiles by custom data ERR_TILE_TYPE
			var tile_plot_type = tile_data.get_custom_data(PLOT_TYPE_KEY)
			if(tile_plot_type != null && tile_plot_type.length() > 0):
				var tiles_array = tiles_by_plot_type.get(tile_plot_type, [])
				tiles_array.append([source_id, tile_id])
				tiles_by_plot_type[tile_plot_type] = tiles_array
	
	assert(tiles_by_plot_type.has(ERR_PLOT_TYPE))
	assert(tiles_by_tile_name.has(BORDER_TILE_NAME))
	assert(tiles_by_tile_name.has(UNEXPLORED_ICON_NAME))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
	if(!display_borders):
		clear_layer(layers_by_name[BORDER_LAYER])
	
	for coord in GardenManager.get_used_plots():
		var coord_i : Vector2i = coord
		var plot : Plot = GardenManager.get_plot(coord_i)
		
		# tile_type defaults to ERR_PLOT_TYPE if the tile type isn't recognized
		var tile_type = ERR_PLOT_TYPE
		if(tiles_by_plot_type.has(plot.plot_type)):
			tile_type = plot.plot_type
		
		# sets the plot tile if its type differs from what the type already recorded in plot_type_map
		if(!plot_type_map.has(coord_i) || plot_type_map.get(coord_i) != tile_type):
			plot_type_map[coord_i] = tile_type
			var tiles_array = tiles_by_plot_type.get(tile_type, null)
			if(tiles_array == null || tiles_array.size() == 0):
				print("ERROR - PlotsMap::_process - could not retrieve tile")
			else:
				var random_i = randi_range(0, tiles_array.size()-1)
				var tile : Array = tiles_array[random_i]
				set_cell(layers_by_name[PLOT_LAYER], coord_i, tile[0], tile[1])
		
		# set border tiles
		if(display_borders):
			var tiles_array = tiles_by_tile_name.get(BORDER_TILE_NAME, null)
			var tile : Array = tiles_array[0]
			set_cell(layers_by_name[BORDER_LAYER], coord_i, tile[0], tile[1])
		
		# show unexplored plot icons
		if(!plot.explored):
			var tiles_array = tiles_by_tile_name.get(UNEXPLORED_ICON_NAME, null)
			var tile : Array = tiles_array[0]
			set_cell(layers_by_name[ICON_LAYER], coord_i, tile[0], tile[1])
		else:
			erase_cell(layers_by_name[ICON_LAYER], coord_i)
		
		unused_cells.erase(coord_i)
	
	# erase any previously set tiles for plots that no longer exist
	for coord in unused_cells:
		var coord_i : Vector2i = coord
		erase_cell(layers_by_name[PLOT_LAYER], coord_i)
		erase_cell(layers_by_name[BORDER_LAYER], coord_i)
		erase_cell(layers_by_name[ICON_LAYER], coord_i)
		plot_type_map.erase(coord_i)

