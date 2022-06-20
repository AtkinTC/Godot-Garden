class_name HighlightsTileMap
extends TileMapCust

const BORDER_TILE_NAME := "border"
const SELECTED_TILE_NAME := "border_selected"

var display_borders : bool = true

var highlighted : bool = false
var highlighted_cell : Vector2i

func _ready():
	initialize()

func initialize():
	super.initialize()
	assert(tiles_by_tile_name.has(BORDER_TILE_NAME))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
	for coord in GardenManager.get_used_plots():
		var coord_i : Vector2i = coord
		
		# set border tiles
		var tiles_array = tiles_by_tile_name.get(BORDER_TILE_NAME, null)
		set_cell_from_tile_identifier(coord_i, tiles_array[0])
		
		unused_cells.erase(coord_i)
	
	if(highlighted):
		var tiles_array = tiles_by_tile_name.get(SELECTED_TILE_NAME, null)
		set_cell_from_tile_identifier(highlighted_cell, tiles_array[0])
	
	# erase any previously set tiles for plots that no longer exist
	for coord in unused_cells:
		var coord_i : Vector2i = coord
		erase_cell(0, coord_i)

func _on_highlight_cell_changed(_cell : Vector2i):
	highlighted_cell = _cell
	highlighted = true

func _on_highlight_cleared():
	highlighted = false
