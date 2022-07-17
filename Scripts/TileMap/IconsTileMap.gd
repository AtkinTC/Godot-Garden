class_name IconsTileMap
extends TileMapCust

const UNEXPLORED_ICON_NAME := "question"
const UNEXPLORED_ICON_KEY = ICON_KEY + "_" + UNEXPLORED_ICON_NAME

func _ready():
	initialize()

func initialize():
	super.initialize()
	assert(tiles_by_full_key.has(UNEXPLORED_ICON_KEY))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
	for coord in GardenManager.get_used_plot_coords():
		var coord_i : Vector2i = coord
		var plot : PlotVO = GardenManager.get_plot(coord_i)
		
		# show unexplored plot icons
		if(!plot.is_explored()):
			var tiles_array = tiles_by_full_key.get(UNEXPLORED_ICON_KEY, null)
			set_cell_from_tile_identifier(coord_i, tiles_array[0])
		else:
			erase_cell(0, coord_i)
		
		unused_cells.erase(coord_i)
	
	# erase any previously set tiles for plots that no longer exist
	for coord in unused_cells:
		var coord_i : Vector2i = coord
		erase_cell(0, coord_i)

