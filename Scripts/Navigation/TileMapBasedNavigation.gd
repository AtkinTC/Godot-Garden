class_name TileMapBasedNavigation
extends NavigationBase

var map_layer_id : int = 0
var tile_map: TileMap

var tiles_2d: Array2D

func set_tile_map(_tile_map: TileMap):
	tile_map = _tile_map
	
	var used_rect := tile_map.get_used_rect()
	
	var height: int = (used_rect.position.y + used_rect.size.y) as int
	var width: int = (used_rect.position.x + used_rect.size.x) as int
	tiles_2d = Array2D.new(width, height, -1)
	
	for cell in tile_map.get_used_cells(map_layer_id):
		var id = tile_map.get_cell_source_id(0, cell, false)
		tiles_2d.set_to_v(cell, id)

func world_to_map(coordv: Vector2) -> Vector2i:
	return tile_map.world_to_map(tile_map.to_local(coordv))

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
