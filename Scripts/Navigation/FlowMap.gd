class_name FlowMap

var tile_nav_map : TileNavMap
var flow_map : Array2D
var open_set : Array[Vector2i]
var d_map : Dictionary
var goal_cells : Array

var nav_width : int

const CARD_DIR = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const DIAG_DIR = [Vector2i(1,1), Vector2i(-1,1), Vector2i(-1,-1), Vector2i(1,-1)]

const CARD_DIST = 10
const DIAG_DIST = 14

func _init(_tile_nav_map : TileNavMap, _goal_cells : Array[Vector2i], _nav_width : int = 1):
	tile_nav_map = _tile_nav_map
	open_set = []
	d_map = {}
	goal_cells = []
	nav_width = _nav_width
	
	flow_map = Array2D.new(tile_nav_map.tiles.width, tile_nav_map.tiles.height, Vector2.ZERO)
	for cell in _goal_cells:
		if(open_set.has(cell)):
			continue
		if(tile_nav_map.is_cell_navigable(cell, nav_width)):
			open_set.append(cell)
			d_map[cell] = 0.0
		else:
			var closest := tile_nav_map.get_closest_navigable_cells(cell, nav_width)
			for c_cell in closest:
				if(open_set.has(c_cell)):
					continue
				open_set.append(c_cell)
				d_map[c_cell] = 0.0
	
	goal_cells = open_set.duplicate()

func get_flow_direction(cell : Vector2i) -> Vector2:
	if(flow_map == null || !flow_map.has_index_v(cell)):
		return Vector2.ZERO
	return flow_map.get_from_v(cell).normalized()

func is_complete():
	return open_set.is_empty()

# processing is segmented so that the full calculation can be split over multipe calls
# only processes a max of <cells_limit> cells if <cells_limit> is greater than 0
# only process for a max of <time_limit> msecs if <time_limit> is greater than 0
# processes the whole map if neither limit is set
func process_segmented(cells_limit: int = 0, time_limit: int = 0):
	if(is_complete()):
		return false
	
	var start := Time.get_ticks_msec()
	var run_time = 0
	var cells: int = 0
	
	while(open_set.size() > 0 && (cells_limit <= 0 || cells < cells_limit) && (time_limit <= 0 || run_time <= time_limit)):
		process_next_open_cell()
		cells += 1
		run_time = Time.get_ticks_msec() - start

# processes a single cell in an in-progress flow map
func process_next_open_cell():
	var cell: Vector2i = open_set.pop_front()
	if(!tile_nav_map.has_cell(cell)):
		return
	
	process_cell_standard(cell)

func process_cell_standard(cell : Vector2i):
	#consider all cells covered by the nav width for cell cost
	var nav_cost_multi : float = 0.0
	for x in range(cell.x, cell.x+nav_width):
		for y in range(cell.y, cell.y+nav_width):
			nav_cost_multi += tile_nav_map.get_cell_nav_value(Vector2i(x,y))
	nav_cost_multi /= nav_width * nav_width
	
	# cardinal directions
	for direction in CARD_DIR:
		var n_cell: Vector2i = cell + direction
		if(tile_nav_map.is_cell_navigable(n_cell, nav_width)):
			var distance: int = d_map[cell] + CARD_DIST * nav_cost_multi
			if(!d_map.has(n_cell) || distance <= d_map[n_cell]):
				d_map[n_cell] = distance
				# record the direction vector from neighbor cell to the current cell
				flow_map.set_to_v(n_cell, ((cell-n_cell) as Vector2).normalized())
				if(!open_set.has(n_cell)):
					open_set.append(n_cell)

	# diagonal directions
	for direction in DIAG_DIR:
			var n_cell : Vector2i = cell + direction
			if(tile_nav_map.is_cell_navigable(n_cell, nav_width)):
				# two cardinal neighbors both need to be open to consider diagonal
				var n_card_1 := Vector2i(n_cell.x, cell.y)
				var n_card_2 := Vector2i(cell.x, n_cell.y)
				if(tile_nav_map.is_cell_navigable(n_card_1, nav_width) && tile_nav_map.is_cell_navigable(n_card_2, nav_width)):
					var distance: int = d_map[cell] + DIAG_DIST * nav_cost_multi
					if(!d_map.has(n_cell) || distance < d_map[n_cell]):
						d_map[n_cell] = distance
						# record the direction vector from neighbor cell to the current cell
						flow_map.set_to_v(n_cell, ((cell-n_cell) as Vector2).normalized())
						if(!open_set.has(n_cell)):
							open_set.append(n_cell)

#func process_cell_advanced(cell):
#	var target_cell : Vector2i = ((cell as Vector2) + flow_map.get_from_v(cell)) as Vector2i
#
#	# cardinal directions
#	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
#		var n_cell: Vector2i = cell + direction
#
#		if(tile_nav_map.is_cell_navigable(n_cell)):
#			# try to leapfrog forward by looking for a direct line of sight to a future cell
#			var inters : Array[Vector2i] = Utils.greedy_line_raster(n_cell, target_cell)
#
#			var direct = true
#			for inter_c in inters:
#				if(!tile_nav_map.is_cell_navigable(inter_c)):
#					direct = false
#					break
#			if(direct):
#				var vec : Vector2 = ((target_cell - n_cell) as Vector2)
#				var distance: float =  d_map[target_cell] + vec.length()
#				if(!d_map.has(n_cell) || distance < d_map[n_cell]):
#					d_map[n_cell] = distance
#					# record the direction vector from neighbor cell to the current cell
#					flow_map.set_to_v(n_cell, vec)
#					open_set.append(n_cell)
#					continue
#
#			var distance: float = d_map[cell] + 1
#			if(!d_map.has(n_cell) || distance < d_map[n_cell]):
#				d_map[n_cell] = distance
#				# record the direction vector from neighbor cell to the current cell
#				flow_map.set_to_v(n_cell, ((cell-n_cell) as Vector2))
#				open_set.append(n_cell)

func draw(node: Node2D, cell_size: Vector2i):
	for cell in goal_cells:
		var pos = (cell * cell_size) as Vector2 + (cell_size * 0.5)
		node.draw_circle(pos, 8, Color.RED)
	
	var lines_1 : PackedVector2Array = []
	var lines_2 : PackedVector2Array = []
	for x in range(flow_map.width):
		for y in range(flow_map.height):
			var cell = Vector2i(x,y)
			if(!tile_nav_map.is_cell_navigable(cell, nav_width)):
				continue
			var startv: Vector2 = (cell * cell_size) as Vector2 + (cell_size * 0.5)
			var flow: Vector2 = get_flow_direction(cell)
			if(abs(flow.x) > 0 || abs(flow.y) > 0):
				var endv: Vector2  = startv + flow * 16.0
				lines_1.append_array([startv, endv])
				lines_2.append_array([endv - (endv-startv).normalized() * 5, endv])
	if(lines_1.size() >= 2):
		node.draw_multiline(lines_1, Color.BLUE, 3.0)
	if(lines_2.size() >= 2):
		node.draw_multiline(lines_2, Color.RED, 3.0)
