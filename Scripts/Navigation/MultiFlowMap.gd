class_name MultiFlowMap

var flow_maps : Dictionary
var tile_nav_map : TileNavMap

func _init(_tile_nav_map : TileNavMap):
	flow_maps = {}
	tile_nav_map = _tile_nav_map

func get_flow_direction(start_cell : Vector2i, end_cell : Vector2i) -> Vector2:
	var flow_map : FlowMap = flow_maps.get(end_cell, null)
	if(flow_map == null):
		return Vector2.ZERO
	return flow_map.get_flow_direction(start_cell)

func is_complete(end_cell: Vector2i):
	var flow_map : FlowMap = flow_maps.get(end_cell, null)
	if(flow_map == null):
		return false
	return flow_map.is_complete()

func process_flow_map_segmented(end_cell: Vector2i, cells_limit: int = 0, time_limit: int = 0):
	if(is_complete(end_cell)):
		return false
	if(!flow_maps.has(end_cell)):
		start_flow_map_segmented(end_cell)
	continue_flow_map_segmented(end_cell, cells_limit, time_limit)

# setup the initial empty flow map targeting cellv
func start_flow_map_segmented(end_cell: Vector2i):
	if(flow_maps.has(end_cell)):
		return false
	flow_maps[end_cell] = FlowMap.new(tile_nav_map, [end_cell])

# processes one segment of the in-progress flow map (limited by number of cells, time, or unlimited)
func continue_flow_map_segmented(cellv: Vector2i, cells_limit: int = 1, time_limit: int = 1):
	if(!flow_maps.has(cellv) || is_complete(cellv)):
		return false
	var flow_map : FlowMap = flow_maps[cellv]
	flow_map.process_segmented(cells_limit, time_limit)

func draw(node: Node2D, tile_size : Vector2i, end_cell: Vector2i):
	if(flow_maps.has(end_cell)):
		var flow_map : FlowMap = flow_maps[end_cell]
		flow_map.draw(node, tile_size)
