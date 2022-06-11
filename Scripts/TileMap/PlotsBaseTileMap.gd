class_name PlotsBaseTileMap
extends TileMapCust

const PLOT_TYPE_KEY := "plot_type"
const ERR_PLOT_TYPE := "ERROR"

var tiles_by_plot_type : Dictionary
var plot_type_map : Dictionary

func _ready():
	initialize()

func initialize():
	super.initialize()
	
	# build reference dictionary of tiles so they can be quickly referenced by a custom identifiers
	for i_source in tile_set.get_source_count():
		var source_id : int = tile_set.get_source_id(i_source)
		var source : TileSetSource = tile_set.get_source(source_id)
		for i_tiles in source.get_tiles_count():
			var tile_id : Vector2i = source.get_tile_id(i_tiles)
			
			for i_alt in source.get_alternative_tiles_count(tile_id):
				var alt_id = source.get_alternative_tile_id(tile_id, i_alt)
				
				# organize tiles by custom data PLOT_TYPE_KEY
				var tile_data : TileData = source.get_tile_data(tile_id, alt_id)
				var tile_plot_type = tile_data.get_custom_data(PLOT_TYPE_KEY)
				if(tile_plot_type != null && tile_plot_type.length() > 0):
					var tiles_array = tiles_by_plot_type.get(tile_plot_type, [])
					tiles_array.append(TileIdentifier.new(source_id, tile_id, alt_id))
					tiles_by_plot_type[tile_plot_type] = tiles_array
	
	assert(tiles_by_plot_type.has(ERR_PLOT_TYPE))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
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
				#var tile : Array = tiles_array[random_i]
				#set_cell(0, coord_i, tile[0], tile[1], tile[2])
				set_cell_from_tile_identifier(coord_i, tiles_array[random_i])
		
		unused_cells.erase(coord_i)
	
	# erase any previously set tiles for plots that no longer exist
	for coord in unused_cells:
		var coord_i : Vector2i = coord
		erase_cell(0, coord_i)
		plot_type_map.erase(coord_i)

