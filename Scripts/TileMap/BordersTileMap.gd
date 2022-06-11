class_name BordersTileMap
extends TileMapCust

const BORDER_TILE_NAME := "border"

var display_borders : bool = true

func _ready():
	initialize()

func initialize():
	super.initialize()
	assert(tiles_by_tile_name.has(BORDER_TILE_NAME))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
	for coord in GardenManager.get_used_plots():
		var coord_i : Vector2i = coord
		var plot : Plot = GardenManager.get_plot(coord_i)
		
		# set border tiles
		var tiles_array = tiles_by_tile_name.get(BORDER_TILE_NAME, null)
		var tile : Array = tiles_array[0]
		set_cell(0, coord_i, tile[0], tile[1])
		
		unused_cells.erase(coord_i)
	
	# erase any previously set tiles for plots that no longer exist
	for coord in unused_cells:
		var coord_i : Vector2i = coord
		erase_cell(0, coord_i)

