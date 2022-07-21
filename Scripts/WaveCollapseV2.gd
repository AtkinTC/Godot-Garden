class_name WaveCollapseV2

const OPEN := "open"
const RESTRICTED := "restricted"

const DIRECTIONS := Constants.DIRECTIONS

const DIR_OPPOSITE := Constants.DIR_OPPOSITE

var cell_defs: Dictionary = {}

# Dictionary(Vector2i, Array) of all the possible cell types at each coordinate
# treat Unset, [] as an unrestricted list of all cell types
var possibility_field: Dictionary = {}

var collapsed: Array = []

var min_bounds : Vector2i = Vector2i(0,0)
var max_bounds : Vector2i = Vector2i(10, 10)

var total_refinements : int = 0
var deepest : int = 0

var refinement_queue := []

func _init(_cell_defs : Dictionary, _min_bounds : Vector2i = min_bounds, _max_bounds : Vector2i = max_bounds):
	set_bounds(_min_bounds, _max_bounds)
	set_cell_definitions(_cell_defs)

func set_cell_definitions(_cell_defs : Dictionary):
	for cell_name in _cell_defs.keys():
		process_cell_definition(cell_name, _cell_defs[cell_name].to_dictionary())
	#print_pretty_cell_defs()

# read in a cell definition, and update all relevant data
func process_cell_definition(cell_name : String, cell_def: Dictionary):
	cell_defs[cell_name] = cell_def.duplicate(true)

# collapse a cell to one of the possible cell types chosen at random
func collapse_cell(coord : Vector2i) -> String:
	if(is_coord_in_bounds(coord)):
		print_debug(str(coord) + " is outside of bounds")
		return ""
	if(collapsed.has(coord)):
		print_debug(str(coord) + " has already been collapsed")
		return possibility_field.get(coord)[0]
	
	var possible_cells : Array = possibility_field.get(coord, [])
	if(possible_cells.size() == 0):
		possible_cells = cell_defs.keys()
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
		add_cell_to_refinement_queue(n_coord)
	refine_possibilities()

func add_cell_to_refinement_queue(coord : Vector2i):
	if(refinement_queue.has(coord)):
		return false
	refinement_queue.append(coord)
	return true

func refine_possibilities():
	while(refinement_queue.size() > 0):
		refine_cell(refinement_queue.pop_front())

# update the possible cell types of an non-collapsed cell and propagate the probability wave to neighboring cells
func refine_cell(coord : Vector2i):
	if(!is_coord_in_bounds(coord)):
		return
	if(collapsed.has(coord)):
		return
	
	var old_possible_cells : Array = possibility_field.get(coord, cell_defs.keys())
		
	var new_possible_cells : Array = cell_defs.keys()
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		var n_possible_cells = possibility_field.get(n_coord, [])
		if(n_possible_cells.size() == 0):
			n_possible_cells = cell_defs.keys()
		var possible_cells := get_possible_neighbors_for_cell_types(n_possible_cells, DIR_OPPOSITE[d])
		if(possible_cells.size() > 0):
			new_possible_cells = array_inner_join(new_possible_cells, possible_cells)
	
	if(new_possible_cells.size() == 0):
		print_debug("EMPTY")
	
	if(new_possible_cells.size() == 1):
		sorted_insert(collapsed, coord)
	else:
		if(new_possible_cells.size() > old_possible_cells.size()):
			print_debug("ERROR")
			possibility_field[coord] = old_possible_cells
			return
		if(new_possible_cells.size() == cell_defs.size() || array_compare(old_possible_cells, new_possible_cells)):
			# no change
			possibility_field[coord] = old_possible_cells
			return
	
	possibility_field[coord] = new_possible_cells
	
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		add_cell_to_refinement_queue(n_coord)

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
	
	var possible_cells : Array = cell_defs[cell_name].get(direction, [])
	
	return possible_cells

func set_bounds(_min_bounds : Vector2i, _max_bounds : Vector2i):
	min_bounds = _min_bounds
	max_bounds = _max_bounds

func is_coord_in_bounds(coord : Vector2i) -> bool:
	return (coord.x >= min_bounds.x && coord.x <= max_bounds.x && coord.y >= min_bounds.y && coord.y <= max_bounds.y)

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
