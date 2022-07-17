class_name HighlightsTileMap
extends TileMapCust

const BORDER_TILE_NAME := "border"
const SELECTED_TILE_NAME := "border_selected"

const BORDER_ICON_KEY = ICON_KEY + "_" + BORDER_TILE_NAME
const SELECTED_BORDER_ICON_KEY = ICON_KEY + "_" + SELECTED_TILE_NAME

var display_borders : bool = true

var highlighted : bool = false
var highlighted_cell : Vector2i

func _ready():
	initialize()

func initialize():
	super.initialize()
	
	assert(tiles_by_full_key.has(BORDER_ICON_KEY))
	assert(tiles_by_full_key.has(SELECTED_BORDER_ICON_KEY))

func _process(_delta):
	var unused_cells = get_used_cells(0)
	
	for coord in GardenManager.get_used_plot_coords():
		var coord_i : Vector2i = coord
		
		# set border tiles
		var tiles_array = tiles_by_full_key.get(BORDER_ICON_KEY, null)
		set_cell_from_tile_identifier(coord_i, tiles_array[0])
		
		unused_cells.erase(coord_i)
	
	if(highlighted):
		var tiles_array = tiles_by_full_key.get(SELECTED_BORDER_ICON_KEY, null)
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
