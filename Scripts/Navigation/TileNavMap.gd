class_name TileNavMap

const NAV_LAYER_KEY := "nav_cost"

var map_layer_id : int = 0
var tile_map : TileMapCust
var border_map : TileMapCust
var tiles : Array2D
var borders : Array2D
var cell_widths : Array2D

var max_width : int
var effective_max_width : int

func _init(_tile_map : TileMapCust, _border_map: TileMapCust, _max_width : int = 3):
	tile_map = _tile_map
	border_map = _border_map
	
	max_width = _max_width
	effective_max_width = 0
	
	var used_rect := tile_map.get_used_rect()
	var height: int = (used_rect.position.y + used_rect.size.y) as int
	var width: int = (used_rect.position.x + used_rect.size.x) as int
	tiles = Array2D.new(width, height, int(-1))
	borders = Array2D.new(width+1, (height+1)*2, int(1))
	cell_widths = Array2D.new(width, height, int(0))
	
	for cell in tile_map.get_used_cells(map_layer_id):
		process_cell_tile(cell)
	
	for border in border_map.get_used_cells(map_layer_id):
		process_border_tile(border)
	
	for cell in tile_map.get_used_cells(map_layer_id):
		process_cell_width(cell)

func process_cell_tile(_cell : Vector2i):
	var tile_def : TileDefinition = tile_map.get_tile_identifier_for_cell(_cell)
	var nav_value : float = -1.0
	if(tile_def != null):
		nav_value = tile_def.get_custom_data(NAV_LAYER_KEY, -1.0)
	tiles.set_to_v(_cell, nav_value)

func process_border_tile(_border : Vector2i):
	var border_def : TileDefinition = border_map.get_tile_identifier_for_cell(_border)
	var nav_value : float = -1.0
	if(border_def != null):
		nav_value = border_def.get_custom_data(NAV_LAYER_KEY, -1.0)
	borders.set_to_v(_border, nav_value)

func process_cell_width(_cell : Vector2i):
	if(!is_tile_navigable(_cell)):
		cell_widths.set_to_v(_cell, int(0))
		return
	
	for i in range(0, max_width-1):
		for x in range(0, i+1):
			var cell = _cell + Vector2i(x, i)
			if(!are_cells_connected(cell, cell+Vector2i(1,1))):
				cell_widths.set_to_v(_cell, int(i+1))
				effective_max_width = max(effective_max_width, i+1)
				return
		for y in range(0, i+1):
			var cell = _cell + Vector2i(i, y)
			if(!are_cells_connected(cell, cell+Vector2i(1,1))):
				cell_widths.set_to_v(_cell, int(i+1))
				effective_max_width = max(effective_max_width, i+1)
				return
	
	cell_widths.set_to_v(_cell, int(max_width))
	effective_max_width = max_width

func world_to_map(coordv: Vector2) -> Vector2i:
	return tile_map.world_to_map(tile_map.to_local(coordv))

func get_closest_navigable_cells(_cell : Vector2i, _width : int = 1) -> Array[Vector2i] :
	if(is_cell_navigable(_cell, _width)):
		return [_cell]
	
	var cells : Array[Vector2i] = []
	var r : int = 1
	var max_r : int = max(tiles.width, tiles.height)
	while(cells.size() == 0 && r < max_r):
		for x in range(-r, r+1):
			var co_x : int = r - abs(x)
			for y in range(-co_x, co_x+1):
				var c := _cell + Vector2i(x,y)
				if(is_cell_navigable(c, _width)):
					cells.append(c)
		r += 1
	
	return cells

func has_cell(cellv: Vector2i) -> bool:
	return tiles.has_index_v(cellv)

func is_tile_navigable(_cell : Vector2i) -> bool:
	return (tiles.has_index_v(_cell) && tiles.get_from_v(_cell) > 0)

func is_width_navigable(_cell : Vector2i, _width : int = 1) -> bool:
	return (_width <= 1 || (cell_widths.has_index_v(_cell) && cell_widths.get_from_v(_cell) >= _width))

func is_cell_navigable(_cell : Vector2i, _width : int = 1) -> bool:
	return (is_tile_navigable(_cell) && is_width_navigable(_cell, _width))

# checks if there two neighbor cells are connected
# 	checking navigablility, nav width, and borders
# 	also checks cardinal neighbors in case of a diagonal connection
func are_cells_connected(_cell1 : Vector2i, _cell2 : Vector2i, _width : int = 1) -> bool:
	var dif := _cell2 - _cell1
	if(abs(dif.x) > 1 || abs(dif.y) > 1):
		return false
	
	if(!is_tile_navigable(_cell1) || !is_tile_navigable(_cell2)):
		return false
	
	if(!is_width_navigable(_cell1, _width) || !is_width_navigable(_cell2, _width)):
		return false
	
	var x_ok = (dif.x == 0 || get_border_nav_value(_cell1, Vector2i(dif.x, 0)) > 0)
	if(!x_ok):
		return false
		
	var y_ok = (dif.y == 0 || get_border_nav_value(_cell1, Vector2i(0, dif.y)) > 0)
	if(!y_ok):
		return false
	
	# checking diagonal
	if(dif.x != 0 && dif.y != 0):
		var cell_x := _cell1 + Vector2i(dif.x, 0)
			
		if(!is_tile_navigable(cell_x) || !is_width_navigable(cell_x, _width) || get_border_nav_value(cell_x, Vector2i(0, dif.y)) <= 0):
			return false
		
		var cell_y := _cell1 + Vector2i(0, dif.y)
		if(!is_tile_navigable(cell_y) || !is_width_navigable(cell_y, _width) || get_border_nav_value(cell_y, Vector2i(dif.x, 0)) <= 0):
			return false
	return true

func get_cell_nav_value(_cell : Vector2i) -> float:
	if(!tiles.has_index_v(_cell)):
		return -1.0
	else:
		return tiles.get_from_v(_cell)

func get_border_nav_value(_cell: Vector2i, dir : Vector2i):
	var b := _cell
	match dir:
		Vector2i.UP:
			# N -> (x+1, y*2)
			b = Vector2i(b.x+1, b.y*2)
		Vector2i.RIGHT:
			# E -> (x+1, y*2+1)
			b = Vector2i(b.x+1, b.y*2+1)
		Vector2i.DOWN:
			# S -> (x+1, y*2+2)
			b = Vector2i(b.x+1, b.y*2+2)
		Vector2i.LEFT:
			# W -> (x, y*2+1)
			b = Vector2(b.x, b.y*2+1)
	
	if(!borders.has_index_v(b)):
		return -1.0
	else:
		return borders.get_from_v(b)

func get_cell_width(_cell : Vector2i) -> int:
	if(cell_widths == null || !cell_widths.has_index_v(_cell)):
		return 0
	else:
		return cell_widths.get_from_v(_cell)

func draw_cell_widths(node: Node2D, font : Font):
	for x in range(cell_widths.width):
		for y in range(cell_widths.height):
			var cell := Vector2i(x,y)
			var w := get_cell_width(cell)
			if(w > 0):
				var c := str(w)
				node.draw_char(font, (cell+Vector2i(0,1))*tile_map.get_tile_size() + Vector2i(4,-4), c, 8)

func get_effective_max_width() -> int:
	return effective_max_width
