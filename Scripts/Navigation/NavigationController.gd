class_name NavigationController

const NAV_WIDTH_BUFFER := 6

var tile_map: TileMapCust
var goal_cells : Array[Vector2i] = []

var tile_nav_map : TileNavMap
#var goal_flow_map : FlowMap
var goal_flow_maps : Array[FlowMap]
var multi_flow_map : MultiFlowMap

var incomplete_flow_targets : Array[Vector2i]

func _init(_tile_map : TileMap, _goal_cells : Array[Vector2i]):
	tile_map = _tile_map
	tile_nav_map = TileNavMap.new(_tile_map)
	#goal_flow_map = FlowMap.new(tile_nav_map, _goal_cells)
	multi_flow_map = MultiFlowMap.new(tile_nav_map)
	
	goal_flow_maps = []
	var max_nav_width := tile_nav_map.get_effective_max_width()
	for width in range(1, max_nav_width+1):
		goal_flow_maps.append(FlowMap.new(tile_nav_map, _goal_cells, width))

func process_maps_segmented(cells_limit: int = 0, time_limit: int = 0):
	var maps_to_process_count := incomplete_flow_targets.size()
	#if(!goal_flow_map.is_complete()):
	for map in goal_flow_maps:
		if(!map.is_complete()):
			maps_to_process_count += 1
	
	if(maps_to_process_count == 0):
		return
	
	var partial_cells_limit : int = max(cells_limit/maps_to_process_count, 1) if cells_limit > 0 else 0
	var partial_time_limit : int = max(time_limit/maps_to_process_count, 1) if time_limit > 0 else 0
	
	#if(!goal_flow_map.is_complete()):
	#	goal_flow_map.process_segmented(partial_cells_limit, partial_time_limit)
	
	for map in goal_flow_maps:
		if(!map.is_complete()):
			map.process_segmented(partial_cells_limit, partial_time_limit)
	
	for target_cell in incomplete_flow_targets:
		multi_flow_map.process_segmented(target_cell, partial_cells_limit, partial_time_limit)
	
	incomplete_flow_targets = []

func get_nav_width(_real_width : int = 0) -> int:
	if(_real_width <= 0):
		return 1
	var adj_width = _real_width + NAV_WIDTH_BUFFER
	var tile_size := tile_map.get_tile_size()
	var nav_width : int = ceil(max(float(adj_width)/float(tile_size.x), float(adj_width)/float(tile_size.y)))
	return nav_width

func get_width_adjusted_nav_position(_real_position : Vector2, _real_width : int):
	if(_real_width <= 0):
		return _real_position
	var tile_size := tile_map.get_tile_size()
	if(_real_width < tile_size.x && _real_width < tile_size.y):
		return _real_position
	
	# navigation uses top right cell for multi-cell units
	var adj_position = _real_position - Vector2(_real_width, _real_width)/2
	return adj_position

func get_goal_nav_direction(_start_pos: Vector2, _real_width : int = 0, weighted := false) -> Vector2:
	if(weighted):
		return get_goal_nav_direction_weighted(_start_pos, _real_width)
	else:
		return get_goal_nav_direction_unweighted(_start_pos, _real_width)

func get_goal_nav_direction_unweighted(_start_pos: Vector2, _real_width : int = 0) -> Vector2:
	var nav_width = get_nav_width(_real_width)
	if(nav_width > tile_nav_map.get_effective_max_width()):
		return Vector2.ZERO
	var adj_start_pos = _start_pos
	if(nav_width > 1):
		adj_start_pos = get_width_adjusted_nav_position(_start_pos, _real_width)
	var start_cell = tile_map.world_to_map(adj_start_pos)
	var dir := goal_flow_maps[nav_width-1].get_flow_direction(start_cell)
	return dir

func get_goal_nav_direction_weighted(_start_pos: Vector2, _real_width : int = 0) -> Vector2:
	var nav_width = get_nav_width(_real_width)
	if(nav_width > tile_nav_map.get_effective_max_width()):
		return Vector2.ZERO
	var adj_start_pos = _start_pos
	if(nav_width > 1):
		adj_start_pos = get_width_adjusted_nav_position(_start_pos, _real_width)
	var start_cell = tile_map.world_to_map(adj_start_pos)
	var offset := get_cell_weighted_offset(_start_pos)
	var offset_s : Vector2 = sign(offset)
	
	var flow_map := goal_flow_maps[nav_width-1]
	
	var div : float = 1.0
	var summed_dir : Vector2 = flow_map.get_flow_direction(start_cell)
	if(!is_equal_approx(offset.x, 0.0)):
		var dir : Vector2= flow_map.get_flow_direction(start_cell + Vector2i(offset_s.x, 0))
		if(!is_equal_approx(dir.length_squared(), 0.0)):
			var multi : float = abs(offset.x)
			summed_dir += dir * multi
			div += multi
	if(!is_equal_approx(offset.y, 0.0)):
		var dir : Vector2 = flow_map.get_flow_direction(start_cell + Vector2i(0,offset_s.y))
		if(!is_equal_approx(dir.length_squared(), 0.0)):
			var multi : float = abs(offset.y)
			summed_dir += dir * multi
			div += multi
	if(!is_equal_approx(offset.x, 0.0) && !is_equal_approx(offset.y, 0.0)):
		var dir : Vector2 = flow_map.get_flow_direction(start_cell + Vector2i(offset_s.x, offset_s.y))
		if(!is_equal_approx(dir.length_squared(), 0.0)):
			var multi : float = abs(offset.x) * abs(offset.y)
			summed_dir += dir * multi
			div += multi
		
	return summed_dir / div

func get_cell_weighted_offset(_pos: Vector2) -> Vector2:
	var offset := Vector2.ZERO
	var cell : Vector2i = tile_map.world_to_map(_pos)
	var center = tile_map.map_to_world(cell)
	var diff := _pos - center
	
	var tile_size := tile_map.get_tile_size()
	var r_x : float = pow(diff.x*2/tile_size.x, 2) * sign(diff.x)
	var r_y : float = pow(diff.y*2/tile_size.y, 2) * sign(diff.y)
	
	return Vector2(r_x, r_y)

func get_targeted_nav_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	var start_cell = tile_map.world_to_map(start_pos)
	var target_cell = tile_map.world_to_map(target_pos)
	if(!incomplete_flow_targets.has(target_cell) && !multi_flow_map.is_complete(target_cell)):
		var i := incomplete_flow_targets.bsearch(target_cell)
		incomplete_flow_targets.insert(i, target_cell)
		
	var dir := multi_flow_map.get_flow_direction(start_cell, target_cell)
	return dir

func draw_goal_flow(node: Node2D, nav_width : int = 1):
	if(nav_width - 1 < goal_flow_maps.size()):
		goal_flow_maps[nav_width-1].draw(node, tile_map.get_tile_size())

func draw_target_flow(node: Node2D, target_cell: Vector2i):
	multi_flow_map.draw(node, tile_map.get_tile_size(), target_cell)

func draw_cell_widths(node: Node2D, font : Font):
	tile_nav_map.draw_cell_widths(node, font)
