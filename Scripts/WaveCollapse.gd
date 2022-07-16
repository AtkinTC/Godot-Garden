class_name WaveCollapse

# bitwise operators:
#	~ not
#	& and
#	| or
#	^ xor

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
var key_to_name: Dictionary = {}
var name_to_key: Dictionary = {}

var total_key_sum: int = 0

var next_key: int = 1

var possibility_field: Dictionary = {}

var collapsed: Array= []

var min : Vector2i = Vector2i(0,0)
var max : Vector2i = Vector2i(10, 10)

func set_min_bound(_min : Vector2i):
	min = _min

func set_max_bound(_max : Vector2i):
	max = _max

func is_coord_in_bounds(coord : Vector2i) -> bool:
	return (coord.x >= min.x && coord.x <= max.x && coord.y >= min.y && coord.y <= max.y)

func set_cell_definitions(_cell_defs : Dictionary):
	for cell_name in _cell_defs.keys():
		assign_cell_key(cell_name)
	
	# setup cell definitions
	var setup_success : bool = true
	for cell_name in _cell_defs.keys():
		setup_success = set_cell_definition(cell_name, _cell_defs[cell_name]) && setup_success
	assert(setup_success)
	
	# clean cell definitions
	var clean_success : bool = true
	for cell_key in cell_defs.keys():
		clean_success = clean_cell_definition(cell_key) && clean_success
	assert(clean_success)

func assign_cell_key(cell_name):
	key_to_name[next_key] = cell_name
	name_to_key[cell_name] = next_key
	total_key_sum += next_key
	next_key *= 2

func set_cell_definition(cell_name : String, cell_def: Dictionary) -> bool:
	var cell_key : int = name_to_key.get(cell_name, -1)
	if(cell_key < 0):
		print_debug("No key assigned for cell name " + str(cell_name))
		return false
	
	# convert array of string keys into a sum of binary keys
	var new_cell_def : Dictionary = {}
	for dir in DIRECTIONS.keys():
		var poss_names : Array = cell_def.get(dir, [])
		var dir_keys_sum : int = 0
		if(poss_names.size() == 0):
			new_cell_def[dir] = total_key_sum
		else:
			for poss_name in poss_names:
				var key : int = name_to_key.get(poss_name, -1)
				if(key <= 0):
					print_debug("No key assigned for cell name " + str(poss_name))
					return false
				dir_keys_sum |= key
			new_cell_def[dir] = dir_keys_sum
	cell_defs[cell_key] = new_cell_def
	return true


func clean_cell_definition(cell_key : int, permissive : bool = true) -> bool:
	var passed : bool = true
	for d in DIRECTIONS.keys():
		var possible_neighbor_key_sum : int = cell_defs[cell_key][d]
		var possible_neighbor_keys : Array = key_sum_to_keys(possible_neighbor_key_sum)
		for neighbor_key in possible_neighbor_keys:
			var co_neighbor_keys_sum : int = cell_defs[neighbor_key][DIR_OPPOSITE[d]]
			if(cell_key & co_neighbor_keys_sum == 0):
				if(possible_neighbor_key_sum == total_key_sum):
					# allows all possible neighbors
					# remove the non-accepting cell from the list of possible neighbors
					cell_defs[cell_key][d] = cell_defs[cell_key][d] - neighbor_key
				else:
					# has an explicit list of allowed neighbors
					# explicit neighbor list contains a non-accepting cell
					if(!permissive):
						print_debug("Conflict between " + str(key_to_name[cell_key]) + ":" + str(d) + " and " + str(key_to_name[neighbor_key]) + ":" + str(DIR_OPPOSITE[d]))
						# non-permissive: do not allow these conflicts
						passed = false
						continue
					else:
						# permissive: clean up conflicts and continue on
						cell_defs[neighbor_key][DIR_OPPOSITE[d]] = cell_defs[neighbor_key][DIR_OPPOSITE[d]] + cell_key
	return passed

func get_cell_name_from_key(key : int) -> String:
	return key_to_name.get(key, "")

func get_cell_key_from_name(name : String) -> int:
	return name_to_key.get(name, -1)

func get_possible_cell_names(coord : Vector2i) -> Array:
	var possible_names := []
	for key in key_sum_to_keys(possibility_field.get(coord, total_key_sum)):
		possible_names.append(key_to_name[key])
	if possible_names.size() == 0:
		return name_to_key.keys()
	return possible_names

# collapse a cell to one of the possible cell types chosen at random
func collapse_cell(coord : Vector2i) -> int:
	if(coord.x < min.x || coord.x > max.x || coord.y < min.y || coord.y > max.y):
		print_debug(str(coord) + " is outside of bounds")
		return -1
	if(collapsed.has(coord)):
		print_debug(str(coord) + " has already been collapsed")
		return -1
	
	var possible_keys : Array = key_sum_to_keys(possibility_field.get(coord, total_key_sum))
	var chosen_key : int = possible_keys[randi_range(0, possible_keys.size()-1)]
	
	collapse_cell_forced(coord, chosen_key)
	
	return chosen_key

# collapse a cell to a specific cell type and propagate the probability wave to neighboring cells
func collapse_cell_forced(coord : Vector2i, cell_key : int):
	if(!is_coord_in_bounds(coord)):
		print_debug(str(coord) + " is outside of bounds")
		return
	if(collapsed.has(coord)):
		print_debug(str(coord) + " has already been collapsed")
		return
	if(!cell_defs.has(cell_key)):
		print_debug(str(key_to_name[cell_key]) + " is not a recognized cell key")
		return
	
	collapsed.append(coord)
	possibility_field[coord] = cell_key
	
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		refine_possibilities(n_coord)

# update the possible cell types of an non-collapsed cell and propagate the probability wave to neighboring cells
func refine_possibilities(coord : Vector2i):
	if(!is_coord_in_bounds(coord)):
		return
	if(collapsed.has(coord)):
		return
	
	var new_possible_keys_sum : int = total_key_sum
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		new_possible_keys_sum &= get_possible_neighbors(n_coord, DIR_OPPOSITE[d])
	
	var old_possible_keys_sum : int = possibility_field.get(coord, total_key_sum)
	
	if(new_possible_keys_sum == old_possible_keys_sum):
		# no change
		return
	
	possibility_field[coord] = new_possible_keys_sum
	
	for d in DIRECTIONS.keys():
		var n_coord : Vector2i = coord + DIRECTIONS[d]
		refine_possibilities(n_coord)

# return all the possible neighbors of a cell to one direction as a key sum
func get_possible_neighbors(coord : Vector2i, direction : String) -> int:
	if(!is_coord_in_bounds(coord)):
		return total_key_sum
	
	var possible_neighbor_keys_sum : int = 0
	var possible_keys_sum : int = possibility_field.get(coord, total_key_sum)
	if(possible_keys_sum == total_key_sum):
		# every possible cell
		possible_neighbor_keys_sum = total_key_sum
	else:
		# every possible neighbor cell for every possible local cells
		var possible_keys : Array = key_sum_to_keys(possible_keys_sum)
		for key in possible_keys:
			var neighbors_key_sum : int = cell_defs[key][direction]
			possible_neighbor_keys_sum |= neighbors_key_sum
	return possible_neighbor_keys_sum

# breakes up key sum (integer) into an array of individual keys (square integer components)
func key_sum_to_keys(key_sum : int) -> Array:
	var new_key_sum = key_sum
	var keys := []
	var key : int = 1
	while new_key_sum > 0:
		if(key > new_key_sum):
			print_debug("error decomposing key sum " + str(key_sum))
			return []
		if(new_key_sum & key != 0):
			keys.append(key)
			new_key_sum -= key
		key *= 2
	return keys

func print_pretty_cell_defs():
	var pretty_cell_defs := {}
	for key in cell_defs.keys():
		var name : String = key_to_name[key]
		print(str(name) + " :")
		for dir in cell_defs[key]:
			var possible_keys_sum : int = cell_defs[key][dir]
			var possible_keys : Array = key_sum_to_keys(possible_keys_sum)
			var possible_names := []
			for p_key in possible_keys:
				var p_name : String = key_to_name[p_key]
				possible_names.append(p_name)
			print(str(dir) + " : " + str(possible_names))
