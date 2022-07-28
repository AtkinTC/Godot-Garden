class_name TileNavMap

const NAV_LAYER_KEY := "nav_cost"

var map_layer_id : int = 0
var tile_map : TileMapCust
var tiles : Array2D

func _init(_tile_map : TileMapCust):
	tile_map = _tile_map
	
	var used_rect := tile_map.get_used_rect()
	
	var height: int = (used_rect.position.y + used_rect.size.y) as int
	var width: int = (used_rect.position.x + used_rect.size.x) as int
	tiles = Array2D.new(width, height, -1)
	
	for cell in tile_map.get_used_cells(map_layer_id):
		var tile_def : TileDefinition = tile_map.get_tile_identifier_for_cell(cell)
		var nav_value : float = -1.0
		if(tile_def != null):
			nav_value = tile_def.get_custom_data(NAV_LAYER_KEY, -1.0)
		tiles.set_to_v(cell, nav_value)
		
		#var id = tile_map.get_cell_source_id(0, cell, false)
		#tiles.set_to_v(cell, id)

func world_to_map(coordv: Vector2) -> Vector2i:
	return tile_map.world_to_map(tile_map.to_local(coordv))

func get_closest_navigable_cells(cellv : Vector2i) -> Array[Vector2i] :
	if(is_cell_navigable(cellv)):
		return [cellv]
	
	var cells : Array[Vector2i] = []
	var r : int = 1
	var max_r : int = max(tiles.width, tiles.height)
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
	return tiles.has_index_v(cellv)

func is_cell_navigable(cellv : Vector2i) -> bool:
	return (tiles.has_index_v(cellv) && tiles.get_from_v(cellv) > 0)

func get_cell_nav_value(cellv : Vector2i) -> float:
	if(!tiles.has_index_v(cellv)):
		return -1.0
	else:
		return tiles.get_from_v(cellv)
