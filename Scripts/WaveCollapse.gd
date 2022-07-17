class_name WaveCollapse

const OPEN := "open"
const RESTRICTED := "restricted"
const MANUAL := "manual"

const DIRECTIONS := {"N" : Vector2i(-1,0),
					#"NE" : Vector2i(-1,-1),
					"E" : Vector2i(0,-1),
					#"SE" : Vector2i(1,-1),
					"S" : Vector2i(1,0),
					#"SW" : Vector2i(1,1),
					"W" : Vector2i(0,1),
					#"NW" : Vector2i(-1,1)
					}

const DIR_OPPOSITE := {"N" : "S",
					"NE" : "SW",
					"E" : "W",
					"SE" : "NW",
					"S" : "N",
					"SW" : "NE",
					"W" : "E",
					"NW" : "SE"}

var cell_defs: Dictionary = {}
var auto_cell_keys : Array = []
var border_defs : Dictionary = {}
var restricted_border_defs : Dictionary = {}

# Dictionary(Vector2i, Array) of all the possible cell types at each coordinate
# treat Unset, [] as an unrestricted list of all cell types
var possibility_field: Dictionary = {}

var collapsed: Array = []

var min : Vector2i = Vector2i(0,0)
var max : Vector2i = Vector2i(10, 10)

func _init(_cell_defs : Dictionary, min_bound : Vector2i = min, max_bound : Vector2i = max):
	set_bounds(min_bound, max_bound)
	set_cell_definitions(_cell_defs)

func set_cell_definitions(_cell_defs : Dictionary):
	for cell_name in _cell_defs.keys():
		process_cell_definition(cell_name, _cell_defs[cell_name])
	#print_pretty_cell_defs()
	#print_pretty_border_defs()

# read in a cell definition, and update all relevant data
func process_cell_definition(cell_name : String, cell_def: Dictionary):
	cell_defs[cell_name] = cell_def.duplicate(true)
	
	# cells marked as MANUAL will not be included as a possible cell
	if(!cell_def.get(MANUAL, false)):
		sorted_insert(auto_cell_keys, cell_name)
		for dir in DIRECTIONS.keys():
			var border_type : String = cell_def.get(dir, OPEN)
			var border_def : Dictionary = border_defs.get(border_type, {})
			var border_direction : Array = border_def.get(dir, [])
		
			sorted_insert(border_direction, cell_name)
			border_def[dir] = border_direction
			border_defs[border_type] = border_def
			
	var cell_restricted : Dictionary = cell_def.get(RESTRICTED, {})
	if(cell_restricted.size() > 0):
		for dir in cell_restricted.keys():
			var cell_restricted_borders : Array = cell_restricted[dir]
			for restricted_border in cell_restricted_borders:
				var restricted_border_def : Dictionary = restricted_border_defs.get(restricted_border, {})
				var restricted_border_directions : Array = restricted_border_def.get(dir, [])
				
				sorted_insert(restricted_border_directions, cell_name)
				restricted_border_def[dir] = restricted_border_directions
				restricted_border_defs[restricted_border] = restricted_border_def

# collapse a cell to one of the possible cell types chosen at random
func collapse_cell(coord : Vector2i) -> String:
	if(coord.x < min.x || coord.x > max.x || coord.y < min.y || coord.y > max.y):
		print_debug(str(coord) + " is outside of bounds")
		return ""
	if(collapsed.has(coord)):
		print_debug(str(coord) + " has already been collapsed")
		return ""
	
	var possible_cells : Array = possibility_field.get(coord, auto_cell_keys)
	if(possible_cells.size() == 0):
		possible_cells = auto_cell_keys
	var chosen_cell : String = possible_cells[randi_range(0, possible_cells.size()-1)]
	
	collapse_cell_forced(coord, chosen_cell)
	
	return chosen_cell

# collapse a cell to a specific cell type and propagate the probability wave to neighboring cells
func collapse_cell_forced(coord : Vector2i, cell_name : String):
	if(!is_coord_in_bounds(coord)):
		print_debug(str(coord) + " is outside of bounds")
		return
	if(collapsed.has(coord)):
		print_debug(str(coord) + " has already been collapsed")
		return
	if(!cell_defs.has(cell_name)):
		print_debug(str(cell_name) + " is not a recognized cell key")
		return
	
	sorted_insert(collapsed, coord)
	possibility_field[coord] = [cell_name]
	
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		refine_possibilities(n_coord)

# update the possible cell types of an non-collapsed cell and propagate the probability wave to neighboring cells
func refine_possibilities(coord : Vector2i):
	if(!is_coord_in_bounds(coord)):
		return
	if(collapsed.has(coord)):
		return
	
	var old_possible_cells : Array = possibility_field.get(coord, [])
	if(old_possible_cells.size() == auto_cell_keys.size()):
		old_possible_cells = []
		
	var new_possible_cells : Array = auto_cell_keys
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		var n_possible_cells = possibility_field.get(n_coord, auto_cell_keys)
		if(n_possible_cells.size() == 0):
			n_possible_cells = auto_cell_keys
		var possible_cells := get_possible_neighbors_for_cell_types(n_possible_cells, DIR_OPPOSITE[d])
		new_possible_cells = array_inner_join(new_possible_cells, possible_cells)
	if(new_possible_cells.size() == auto_cell_keys.size()):
		new_possible_cells = []
	
	if(array_compare(old_possible_cells, new_possible_cells)):
		# no change
		return
	
	possibility_field[coord] = new_possible_cells
	
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		refine_possibilities(n_coord)

# get array of all possible neighbor cells for the specified list of cells in one specified direction
func get_possible_neighbors_for_cell_types(cell_names : Array, direction : String) -> Array:
	if(cell_names.size() == 0):
		print_debug("Empty cell name list")
		return []
	
	var possible_neighbors := []
	for cell_name in cell_names:
		var cell_possible_neighbors := get_possible_neighbors_for_cell_type(cell_name, direction)
		for neighbor_name in cell_possible_neighbors:
			if(!possible_neighbors.has(neighbor_name)):
				sorted_insert(possible_neighbors, neighbor_name)
	
	return possible_neighbors

# get array of all possible neighbor cells for the specified cell in one specified direction
func get_possible_neighbors_for_cell_type(cell_name : String, direction : String) -> Array:
	if(!cell_defs.has(cell_name)):
		print_debug(str(cell_name) + " is not a recognized cell type")
		return []
	
	var possible_cells := []
	var border_name : String = cell_defs[cell_name].get(direction, OPEN)
	var cells : Array = border_defs[border_name].get(DIR_OPPOSITE[direction], [])
	for cell in cells:
		if(!possible_cells.has(cell)):
			sorted_insert(possible_cells, cell)
	
	var restricted_border_names : Array = cell_defs[cell_name].get(RESTRICTED, {}).get(direction, [])
	for restricted_border_name in restricted_border_names:
		var restricted_cells : Array = restricted_border_defs[restricted_border_name].get(DIR_OPPOSITE[direction], [])
		for restricted_cell in restricted_cells:
			if(possible_cells.has(restricted_cell)):
				possible_cells.erase(restricted_cell)
	
	return possible_cells

func set_bounds(_min : Vector2i, _max : Vector2i):
	min = _min
	max = _max

func is_coord_in_bounds(coord : Vector2i) -> bool:
	return (coord.x >= min.x && coord.x <= max.x && coord.y >= min.y && coord.y <= max.y)

func sorted_insert(array : Array, value : Variant) -> Array:
	var i := array.bsearch(value)
	array.insert(i, value)
	return array

func array_compare(array_1 : Array, array_2 : Array):
	if(array_1.size() != array_2.size()):
		return false
		
	var a : Array
	var b : Array
	if(array_1.size() <= array_2.size()):
		a = array_1
		b = array_2
	else:
		a = array_2
		b = array_1
	
	for v in a:
		if(!b.has(v)):
			return false
	return true
		
func array_inner_join(array_1 : Array, array_2 : Array) -> Array:
	var a : Array
	var b : Array
	if(array_1.size() <= array_2.size()):
		a = array_1
		b = array_2
	else:
		a = array_2
		b = array_1
	
	var joined : Array = []
	for v in a:
		if(b.has(v)):
			joined.append(v)
	return joined

# print cell defs in human-readable form, for testing/debug
func print_pretty_cell_defs():
	for name in cell_defs.keys():
		print("CELL:" + str(name) + " :")
		for dir in cell_defs[name]:
			var border : String = cell_defs[name][dir]
			print("\t" + str(dir) + " : " + str(border))

# print border defs in human-readable form, for testing/debug
func print_pretty_border_defs():
	for name in border_defs.keys():
		print("BORDER:" + str(name) + " :")
		for dir in DIRECTIONS.keys():
			var cells : Array = border_defs[name].get(dir, [])
			print("\t" + str(dir) + " : " + str(cells))
