class_name FlowMapNavigation

var tile_nav_map : TileNavMap
var flow_map : FlowMap

func _init(_tile_map : TileMap, _goal_cells : Array[Vector2i]):
	tile_nav_map = TileNavMap.new(_tile_map) 
	flow_map = FlowMap.new(tile_nav_map, _goal_cells)

func get_nav_direction(position: Vector2) -> Vector2:
	var cell: Vector2i = tile_nav_map.world_to_map(position)
	return get_flow_direction(cell)

func get_flow_direction(cell: Vector2) -> Vector2:
	return flow_map.get_flow_direction(cell)

func process_flow_map_segmented(cells_limit: int = 0, time_limit: int = 0):
	if(flow_map.is_complete()):
		return false
	flow_map.process_segmented(cells_limit, time_limit)

func is_complete():
	if(flow_map == null):
		return false
	return flow_map.is_complete()

func draw(node: Node2D):
	var tile_size := tile_nav_map.tile_map.get_tileset().get_tile_size()
	flow_map.draw(node, tile_size)
