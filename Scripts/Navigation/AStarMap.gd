class_name AStarMap

var a_star : AStar2D

var tile_nav_map : TileNavMap

var nav_width : int

func _init(_tile_nav_map : TileNavMap, _nav_width : int = 1):
	tile_nav_map = _tile_nav_map
	nav_width = _nav_width
	a_star = AStar2D.new()
	
	# add navigable points to a_star
	for x in tile_nav_map.tiles.width+1:
		for y in tile_nav_map.tiles.height+1:
			var cell = Vector2i(x, y)
			if(tile_nav_map.is_cell_navigable(cell, nav_width)):
				a_star.add_point(cell_to_id(cell), cell)
	
	# connect points in a_star
	for x in tile_nav_map.tiles.width+1:
		for y in tile_nav_map.tiles.height+1:
			var cell := Vector2i(x, y)
			var id := cell_to_id(cell)
			
			if(a_star.has_point(id)):
				for d in [Vector2i(-1, 0), Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1)]:
					var cell_d = cell+d
					if(tile_nav_map.are_cells_connected(cell, cell_d, nav_width)):
						var id_d = cell_to_id(cell_d)
						a_star.connect_points(id, id_d)

func get_path(from : Vector2i, to : Vector2i) -> Array[Vector2]:
	return a_star.get_point_path(cell_to_id(from), cell_to_id(to)) as Array[Vector2]

func get_path_cells(from : Vector2i, to : Vector2i) -> Array[Vector2i]:
	var cells : Array[Vector2i] = get_path(from, to).map(func(p): return p as Vector2i)
	return cells

func get_next_cell(from : Vector2i, to : Vector2i):
	var p = get_path(from, to)
	if(p.size() <= 1):
		return null
	return p[1] as Vector2i

func cell_to_id(cell: Vector2i) -> int:
	var w : int = tile_nav_map.tiles.width
	var h : int = tile_nav_map.tiles.height
	if(cell.x < 0 || cell.x >= w || cell.y < 0 || cell.y >= h):
		return -1
	
	return cell.x + (cell.y * w)

func id_to_cell(id: int):
	if(id < 0):
		return Vector2i(-1,-1)
	
	var w : int = tile_nav_map.tiles.width
	var h : int = tile_nav_map.tiles.height
	
	var x : int = id % h
	var y : int = (id - x)/h
	
	if(x >= 2 || y >= h):
		return Vector2i(-1,-1)
	
	return Vector2i(x,y)
	
	
	
