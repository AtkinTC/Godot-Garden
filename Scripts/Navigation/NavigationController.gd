class_name NavigationController

var tile_map: TileMap
var goal_cells : Array[Vector2i] = []

var tile_nav_map : TileNavMap
var goal_flow_map : FlowMap
var multi_flow_map : MultiFlowMap

var incomplete_flow_targets : Array[Vector2i]

func _init(_tile_map : TileMap, _goal_cells : Array[Vector2i]):
	tile_map = _tile_map
	tile_nav_map = TileNavMap.new(_tile_map) 
	goal_flow_map = FlowMap.new(tile_nav_map, _goal_cells)
	multi_flow_map = MultiFlowMap.new(tile_nav_map)

func process_maps_segmented(cells_limit: int = 0, time_limit: int = 0):
	var maps_to_process_count := incomplete_flow_targets.size()
	if(!goal_flow_map.is_complete()):
		maps_to_process_count += 1
	
	if(maps_to_process_count == 0):
		return
	
	var partial_cells_limit : int = max(cells_limit/maps_to_process_count, 1) if cells_limit > 0 else 0
	var partial_time_limit : int = max(time_limit/maps_to_process_count, 1) if time_limit > 0 else 0
	
	if(!goal_flow_map.is_complete()):
		goal_flow_map.process_segmented(partial_cells_limit, partial_time_limit)
	
	for target_cell in incomplete_flow_targets:
		multi_flow_map.process_segmented(target_cell, partial_cells_limit, partial_time_limit)
	
	incomplete_flow_targets = []

func get_goal_nav_direction(start_pos: Vector2) -> Vector2:
	var start_cell = tile_map.world_to_map(start_pos)
	var dir := goal_flow_map.get_flow_direction(start_cell)
	return dir

func get_targeted_nav_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	var start_cell = tile_map.world_to_map(start_pos)
	var target_cell = tile_map.world_to_map(target_pos)
	if(!incomplete_flow_targets.has(target_cell) && !multi_flow_map.is_complete(target_cell)):
		var i := incomplete_flow_targets.bsearch(target_cell)
		incomplete_flow_targets.insert(i, target_cell)
		
	var dir := multi_flow_map.get_flow_direction(start_cell, target_cell)
	return dir

func draw_goal_flow(node: Node2D):
	goal_flow_map.draw(node, tile_map.get_tileset().get_tile_size())

func draw_target_flow(node: Node2D, target_cell: Vector2i):
	multi_flow_map.draw(node, tile_map.get_tileset().get_tile_size(), target_cell)
