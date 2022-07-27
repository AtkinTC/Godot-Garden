class_name NavigationController

var tile_map: TileMap
var goal_cells : Array[Vector2] = []

func initialize():
	assert(tile_map != null)
	
	

func set_tile_map(_tile_map: TileMap):
	tile_map = _tile_map

func set_goal_cells(_goal_cells: Array[Vector2]):
	goal_cells = _goal_cells
