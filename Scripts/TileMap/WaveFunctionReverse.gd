extends Node2D

@onready var world : World = $World
@onready var map : TileMapCust = $World/PlotsBaseTileMap

const OPEN := "open"

const DIRECTIONS := Constants.DIRECTIONS
const DIR_OPPOSITE := Constants.DIR_OPPOSITE

@export var resource_name : String

var used_cells := []
var cell_defs := {}
var border_defs := {}
var coord_to_key := {}

var key_next : int = 0

func get_key_from_coord(coord : Vector2i) -> String:
	if(coord_to_key.has(coord)):
		return coord_to_key[coord]
	var key : String = map.get_tile_identifier_for_cell(coord).tile_name
	coord_to_key[coord] = key
	return key

func _ready():
	used_cells = map.get_used_cells(0)
	
	for coord in used_cells:
		read_in_map_cell(coord)
	
	var cell_keys : Array = cell_defs.keys()
	cell_keys.sort()
	for key in cell_keys:
		print(str(cell_defs[key])+",")
		#process_cell_def(cell_defs[key])
	print("cell_defs # : " + str(cell_defs.size()))
	
	var cell_def_set_res := CellDefinitionSet.new()
	cell_def_set_res.resource_name = resource_name
	cell_def_set_res.cell_defs_dictionary = cell_defs
	cell_def_set_res.save()

func read_in_map_cell(coord : Vector2i):
	var key : String = get_key_from_coord(coord)
	var cell_def : CellDefinition = cell_defs.get(key, CellDefinition.new())
	cell_def.key = key
	cell_defs[key] = cell_def
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		if(!used_cells.has(n_coord)):
			continue
		var n_key : String = get_key_from_coord(n_coord)
		var d_n : Array = cell_def.get(d)
		if(!d_n.has(n_key)):
			var i : int = d_n.bsearch(n_key)
			d_n.insert(i, n_key)

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var coord : Vector2i = world.screen_to_map(event.position)
		
		print(map.get_tile_identifier_for_cell(coord))
