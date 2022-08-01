class_name FlowMap

var tile_nav_map : TileNavMap
var flow_map : Array2D
var open_set : Array[Vector2i]
var d_map : Dictionary
var goal_cells : Array

const CARD_DIR = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const DIAG_DIR = [Vector2i(1,1), Vector2i(-1,1), Vector2i(-1,-1), Vector2i(1,-1)]

const CARD_DIST = 10
const DIAG_DIST = 14

func _init(_tile_nav_map : TileNavMap, _goal_cells : Array[Vector2i]):
	tile_nav_map = _tile_nav_map
	open_set = []
	d_map = {}
	goal_cells = [] 
	
	flow_map = Array2D.new(tile_nav_map.tiles.width, tile_nav_map.tiles.height, Vector2.ZERO)
	for cell in _goal_cells:
		if(open_set.has(cell)):
			continue
		if(tile_nav_map.is_cell_navigable(cell)):
			open_set.append(cell)
			d_map[cell] = 0.0
		else:
			var closest := get_closest_navigable_cells(cell)
			for c_cell in closest:
				if(open_set.has(c_cell)):
					continue
				open_set.append(c_cell)
				d_map[c_cell] = 0.0
	
	goal_cells = open_set.duplicate()

func get_flow_direction(cell : Vector2i) -> Vector2:
	if(flow_map == null || !tile_nav_map.has_cell(cell)):
		return Vector2.ZERO
	return flow_map.get_from_v(cell).normalized()

#func get_weighted_flow_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
#	var startv: Vector2 = world_to_map(start_pos)
#	var targetv: Vector2 = world_to_map(target_pos)
#
#	var flow_dir: Vector2 = Vector2.ZERO
#
#	var flow_map_2d: Array2D = flow_maps.get(targetv)
#	var main_flow: Vector2 = flow_map_2d.get_from_v(startv)
#	var cell_mid := (startv + Vector2(0.5,0.5)) * (tile_map.cell_size as Vector2)
#	var from_center_v := (start_pos - cell_mid) / ((tile_map.cell_size as Vector2)/2)
#
#	var cutoff = 0.333
#	if(abs(from_center_v.x) > cutoff):
#		var x_coord = ceil(abs(from_center_v.x)) * sign(from_center_v.x)
#		if(startv.x + x_coord >= 0 && startv.x + x_coord < flow_map_2d.width):
#			var flow: Vector2 = flow_map_2d.get_from(startv.x + x_coord, startv.y)
#			if(flow.length_squared() > 0 && main_flow - flow != Vector2.ZERO):
#				flow_dir += flow * (abs(from_center_v.x) - cutoff)/cutoff
#
#	if(abs(from_center_v.y) > cutoff):
#		var y_coord = ceil(abs(from_center_v.y)) * sign(from_center_v.y)
#		if(startv.y + y_coord >= 0 && startv.y + y_coord < flow_map_2d.height):
#			var flow: Vector2 = flow_map_2d.get_from(startv.x, startv.y + y_coord)
#			if(flow.length_squared() > 0 && main_flow - flow != Vector2.ZERO):
#				flow_dir += flow * (abs(from_center_v.y) - cutoff)/cutoff
#
#	flow_dir += main_flow
#	return flow_dir.normalized()

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
	# cardinal directions
	for direction in CARD_DIR:
		var n_cell: Vector2i = cell + direction
		if(tile_nav_map.is_cell_navigable(n_cell)):
			var distance: int = d_map[cell] + CARD_DIST * tile_nav_map.get_cell_nav_value(cell)
			if(!d_map.has(n_cell) || distance <= d_map[n_cell]):
				d_map[n_cell] = distance
				# record the direction vector from neighbor cell to the current cell
				flow_map.set_to_v(n_cell, ((cell-n_cell) as Vector2).normalized())
				if(!open_set.has(n_cell)):
					open_set.append(n_cell)

	# diagonal directions
	for direction in DIAG_DIR:
			var n_cell : Vector2i = cell + direction
			if(tile_nav_map.is_cell_navigable(n_cell)):
				# two cardinal neighbors both need to be open to consider diagonal
				var n_card_1 := Vector2i(n_cell.x, cell.y)
				var n_card_2 := Vector2i(cell.x, n_cell.y)
				if(tile_nav_map.is_cell_navigable(n_card_1) && tile_nav_map.is_cell_navigable(n_card_2)):
					var distance: int = d_map[cell] + DIAG_DIST * tile_nav_map.get_cell_nav_value(cell)
					if(!d_map.has(n_cell) || distance < d_map[n_cell]):
						d_map[n_cell] = distance
						# record the direction vector from neighbor cell to the current cell
						flow_map.set_to_v(n_cell, ((cell-n_cell) as Vector2).normalized())
						if(!open_set.has(n_cell)):
							open_set.append(n_cell)

func process_cell_advanced(cell):
	var target_cell : Vector2i = ((cell as Vector2) + flow_map.get_from_v(cell)) as Vector2i
	
	# cardinal directions
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var n_cell: Vector2i = cell + direction
		
		if(tile_nav_map.is_cell_navigable(n_cell)):
			# try to leapfrog forward by looking for a direct line of sight to a future cell
			var inters : Array[Vector2i] = Utils.greedy_line_raster(n_cell, target_cell)
			
			var direct = true
			for inter_c in inters:
				if(!tile_nav_map.is_cell_navigable(inter_c)):
					direct = false
					break
			if(direct):
				var vec : Vector2 = ((target_cell - n_cell) as Vector2)
				var distance: float =  d_map[target_cell] + vec.length()
				if(!d_map.has(n_cell) || distance < d_map[n_cell]):
					d_map[n_cell] = distance
					# record the direction vector from neighbor cell to the current cell
					flow_map.set_to_v(n_cell, vec)
					open_set.append(n_cell)
					continue
			
			var distance: float = d_map[cell] + 1
			if(!d_map.has(n_cell) || distance < d_map[n_cell]):
				d_map[n_cell] = distance
				# record the direction vector from neighbor cell to the current cell
				flow_map.set_to_v(n_cell, ((cell-n_cell) as Vector2))
				open_set.append(n_cell)

func get_closest_navigable_cells(cellv : Vector2i) -> Array[Vector2i] :
	if(tile_nav_map.is_cell_navigable(cellv)):
		return [cellv]
	
	var cells : Array[Vector2i] = []
	var r : int = 1
	var max_r : int = max(tile_nav_map.tiles.width, tile_nav_map.tiles.height)
	while(cells.size() == 0 && r < max_r):
		for x in range(-r, r+1):
			var co_x : int = r - abs(x)
			for y in range(-co_x, co_x+1):
				var c := cellv + Vector2i(x,y)
				if(tile_nav_map.is_cell_navigable(c)):
					cells.append(c)
		r += 1
	return cells

func draw(node: Node2D, cell_size: Vector2i):
	for cell in goal_cells:
		var pos = (cell * cell_size) as Vector2 + (cell_size * 0.5)
		node.draw_circle(pos, 8, Color.RED)
	
	var lines_1 : PackedVector2Array = []
	var lines_2 : PackedVector2Array = []
	for x in range(flow_map.width):
		for y in range(flow_map.height):
			var cell = Vector2i(x,y)
			if(!tile_nav_map.is_cell_navigable(cell)):
				continue
			var startv: Vector2 = (cell * cell_size) as Vector2 + (cell_size * 0.5)
			var flow: Vector2 = get_flow_direction(cell)
			if(abs(flow.x) > 0 || abs(flow.y) > 0):
				var endv: Vector2  = startv + flow * 16.0
				lines_1.append_array([startv, endv])
				lines_2.append_array([endv - (endv-startv).normalized() * 5, endv])
	node.draw_multiline(lines_1, Color.BLUE, 3.0)
	node.draw_multiline(lines_2, Color.RED, 3.0)
