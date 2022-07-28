class_name MultiFlowMapNavigation

var tile_map: TileMap
var tile_nav_map: TileNavMap

var multi_flow_map : MultiFlowMap

func _init(_tile_map: TileMap):
	tile_map = _tile_map
	tile_nav_map = TileNavMap.new(tile_map)
	multi_flow_map = MultiFlowMap.new(tile_nav_map)

func get_nav_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	return get_flow_direction(start_pos, target_pos)

func get_flow_direction(start_pos: Vector2, target_pos: Vector2) -> Vector2:
	var start_cell: Vector2i = tile_nav_map.world_to_map(start_pos)
	var target_cell: Vector2i = tile_nav_map.world_to_map(target_pos)
	if(multi_flow_map == null):
		return Vector2.ZERO
	return multi_flow_map.get_flow_direction(start_cell, target_cell)

func is_flow_map_complete(target_cell: Vector2i):
	if(multi_flow_map == null):
		return false
	return multi_flow_map.is_complete(target_cell)

func process_flow_map_segmented(target_cell: Vector2i, cells_limit: int = 1, time_limit: int = 1):
	if(is_flow_map_complete(target_cell)):
		return false
	
	multi_flow_map.process_flow_map_segmented(target_cell, cells_limit, time_limit)

func is_complete(target_cell: Vector2i):
	return multi_flow_map.is_complete(target_cell)

func draw(node: Node2D, targetpos: Vector2i):
	if(multi_flow_map == null):
		return
	var target_cell := tile_nav_map.world_to_map(targetpos)
	var tile_size := tile_map.get_tileset().get_tile_size()
	multi_flow_map.draw(node, tile_size, target_cell)
