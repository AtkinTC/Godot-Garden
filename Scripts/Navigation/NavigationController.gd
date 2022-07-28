class_name NavigationController

var tile_map: TileMap
var goal_cells : Array[Vector2i] = []

var goal_flow_nav : FlowMapNavigation
var multi_flow_nav : MultiFlowMapNavigation

var incomplete_flow_targets : Array[Vector2i]

func _init(_tile_map : TileMap, _goal_cells : Array[Vector2i]):
	tile_map = _tile_map
	goal_flow_nav = FlowMapNavigation.new(_tile_map, _goal_cells)
	multi_flow_nav = MultiFlowMapNavigation.new(_tile_map)

func process_maps_segmented(cells_limit: int = 0, time_limit: int = 0):
	var maps_to_process_count := incomplete_flow_targets.size()
	if(!goal_flow_nav.is_complete()):
		maps_to_process_count += 1
	
	if(maps_to_process_count == 0):
		if(!goal_flow_nav.is_complete()):
			goal_flow_nav.process_flow_map_segmented(cells_limit, time_limit)
		return
	
	var partial_cells_limit : int = max(cells_limit/maps_to_process_count, 1) if cells_limit > 0 else 0
	var partial_time_limit : int = max(time_limit/maps_to_process_count, 1) if time_limit > 0 else 0
	
	if(!goal_flow_nav.is_complete()):
		goal_flow_nav.process_flow_map_segmented(partial_cells_limit, partial_time_limit)
	
	for target_cell in incomplete_flow_targets:
		multi_flow_nav.process_flow_map_segmented(target_cell, partial_cells_limit, partial_time_limit)
	
	incomplete_flow_targets = []

func get_goal_nav_direction(start_pos: Vector2) -> Vector2:
	var dir := goal_flow_nav.get_nav_direction(start_pos)
	return dir

func get_targeted_nav_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	var target_cell = tile_map.world_to_map(target_pos)
	if(!incomplete_flow_targets.has(target_cell) && !multi_flow_nav.is_complete(target_cell)):
		var i := incomplete_flow_targets.bsearch(target_cell)
		incomplete_flow_targets.insert(i, target_cell)
		
	var dir := multi_flow_nav.get_nav_direction(start_pos, target_pos)
	return dir

func draw_goal_flow(node: Node2D):
	goal_flow_nav.draw(node)

func draw_target_flow(node: Node2D, target_cell: Vector2i):
	multi_flow_nav.draw(node, target_cell)
