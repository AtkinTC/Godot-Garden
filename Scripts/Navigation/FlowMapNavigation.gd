class_name FlowMapNavigation
extends NavigationBase

var map_layer_id : int = 0
var tile_map: TileMap

var tiles_2d: Array2D
var flow_maps := {}

func set_tile_map(_tile_map: TileMap):
	tile_map = _tile_map
	flow_maps = {}
	
	var used_rect := tile_map.get_used_rect()
	
	var height: int = (used_rect.position.y + used_rect.size.y) as int
	var width: int = (used_rect.position.x + used_rect.size.x) as int
	tiles_2d = Array2D.new(width, height, -1)
	
	for cell in tile_map.get_used_cells(map_layer_id):
		var id = tile_map.get_cell_source_id(0, cell, false)
		tiles_2d.set_to_v(cell, id)

func world_to_map(coordv: Vector2) -> Vector2i:
	return tile_map.world_to_map(tile_map.to_local(coordv))

func get_nav_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	return get_flow_direction(start_pos, target_pos)

func get_flow_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	var startv: Vector2i = world_to_map(start_pos)
	var targetv: Vector2i = world_to_map(target_pos)
	var flow_map_2d: Array2D = flow_maps.get(targetv)
	return get_flow_direction_local(startv, flow_map_2d)

func get_flow_direction_local(startv: Vector2i, flow_map_2d: Array2D):
	if(flow_map_2d == null):
		return Vector2.ZERO
	return flow_map_2d.get_from_v(startv)

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
	

var flow_map_complete := {}
var flow_map_open_set := {}
var flow_map_d_map := {}

func is_flow_map_complete(cellv: Vector2i):
	return flow_map_complete.get(cellv, false)

# trigger processing of a flow map for cellv
# processing is segmented that the full calculation can be split over multipe calls
# only processes a max of <cells_limit> cells if <cells_limited> is true
# only process for a max of <time_limit> msecs if is true
# processes the whole map if neither limit is set
func process_flow_map_segmented(cellv: Vector2i, cells_limited: bool = true, cells_limit: int = 1, time_limited: bool = false, time_limit: int = 1):
	if(is_flow_map_complete(cellv)):
		return false
	
	if(!flow_maps.has(cellv)):
		start_flow_map_segmented(cellv)
	
	continue_flow_map_segmented(cellv, cells_limited, cells_limit, time_limited, time_limit)

# setup the initial empty flow map targeting cellv
func start_flow_map_segmented(cellv: Vector2i):
	if(flow_maps.has(cellv)):
		return false
	flow_maps[cellv] = Array2D.new(tiles_2d.width, tiles_2d.height, Vector2.ZERO)
	if(is_cell_navigable(cellv)):
		flow_map_open_set[cellv] = [cellv]
		flow_map_d_map[cellv] = {cellv: 0}
	else:
		var closest := get_closest_navigable_cells(cellv)
		flow_map_open_set[cellv] = closest
		var d_map := {}
		for c in closest:
			d_map[c] = 1
		flow_map_d_map[cellv] = d_map

# processes one segment of the in-progress flow map (limited by number of cells, time, or unlimited)
func continue_flow_map_segmented(cellv: Vector2i, cells_limited: bool = true, cells_limit: int = 1, time_limited: bool = false, time_limit: int = 1):
	if(!flow_maps.has(cellv) || is_flow_map_complete(cellv)):
		return false
	
	var flow_map: Array2D = flow_maps[cellv]
	var open_set: Array = flow_map_open_set[cellv]
	var d_map: Dictionary = flow_map_d_map[cellv]
	
	var start := Time.get_ticks_msec()
	var run_time = 0
	var cells: int = 0
	
	while(open_set.size() > 0 && (!cells_limited || cells < cells_limit) && (!time_limited || run_time <= time_limit)):
		process_next_cell_flow_map(flow_map, open_set, d_map)
		cells += 1
		run_time = Time.get_ticks_msec() - start
	
	flow_maps[cellv] = flow_map
	flow_map_open_set[cellv] = open_set
	flow_map_d_map[cellv] = d_map
	
	if(open_set.size() <= 0):
		flow_map_open_set.erase(cellv)
		flow_map_d_map.erase(cellv)
		flow_map_complete[cellv] = true

const CARD_DIST = 10
const DIAG_DIST = 14

# processes a single cell in an in-progress flow map
func process_next_cell_flow_map(flow_map: Array2D, open_set: Array, d_map: Dictionary):
	var c_cell: Vector2i = open_set.pop_front()
	if(!has_cell(c_cell)):
		return
	
	# cardinal directions
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var n_cell: Vector2i = c_cell + direction
		if(is_cell_navigable(n_cell)):
			var distance: int = d_map[c_cell] + CARD_DIST
			if(!d_map.has(n_cell) || distance <= d_map[n_cell]):
				d_map[n_cell] = distance
				# record the direction vector from neighbor cell to the current cell
				flow_map.set_to_v(n_cell, ((c_cell-n_cell) as Vector2).normalized())
				open_set.append(n_cell)
	
	# diagonal directions
	for x in [-1,1]:
		for y in [-1, 1]:
			var n_cell : Vector2i = c_cell + Vector2i(x,y)
			if(is_cell_navigable(n_cell)):
				# two cardinal neighbors both need to be open to consider diagonal
				var n_card_1 := Vector2i(n_cell.x, c_cell.y)
				var n_card_2 := Vector2i(c_cell.x, n_cell.y)
				if(is_cell_navigable(n_card_1) && is_cell_navigable(n_card_2)):
					var distance: int = d_map[c_cell] + DIAG_DIST
					if(!d_map.has(n_cell) || distance < d_map[n_cell]):
						d_map[n_cell] = distance
						# record the direction vector from neighbor cell to the current cell
						flow_map.set_to_v(n_cell, ((c_cell-n_cell) as Vector2).normalized())
						open_set.append(n_cell)

func get_closest_navigable_cells(cellv : Vector2i) -> Array[Vector2i] :
	if(is_cell_navigable(cellv)):
		return [cellv]
	
	var cells : Array[Vector2i] = []
	var r : int = 1
	var max_r : int = max(tiles_2d.width, tiles_2d.height)
	while(cells.size() == 0 && r < max_r):
		for x in range(-r, r+1):
			var co_x : int = r - abs(x)
			for y in range(-co_x, co_x+1):
				var c := cellv + Vector2i(x,y)
				if(is_cell_navigable(c)):
					cells.append(c)
		r += 1
	
	return cells

func has_cell(cellv: Vector2i) -> bool:
	return tiles_2d.has_index_v(cellv)

func is_cell_navigable(cellv : Vector2i) -> bool:
	return (tiles_2d.has_index_v(cellv) && tiles_2d.get_from_v(cellv) != -1)

func draw(node: Node2D, targetpos: Vector2i):
	var target_cell = world_to_map(targetpos)
	if(flow_maps.has(target_cell)):
		var flow_map_2d: Array2D = flow_maps[target_cell]
		var lines_1 : PackedVector2Array = []
		var lines_2 : PackedVector2Array = []
		for x in range(flow_map_2d.width):
			for y in range(flow_map_2d.height):
				var startv: Vector2 = tile_map.map_to_world(Vector2(x,y))
				var flow: Vector2 = get_flow_direction_local(Vector2(x,y), flow_map_2d)
				if(abs(flow.x) > 0 || abs(flow.y) > 0):
					var endv: Vector2  = startv + flow * 16.0
					lines_1.append_array([startv, endv])
					lines_2.append_array([endv - (endv-startv).normalized() * 5, endv])
		node.draw_multiline(lines_1, Color.BLUE, 3.0)
		node.draw_multiline(lines_2, Color.RED, 3.0)
