class_name Array2D

var width: int = 0
var height: int = 0
var array : Array = []

func _init(_width: int, _height: int, init_value = null):
	assert(_width > 0)
	assert(_height > 0)
	
	width = _width
	height = _height

	var col_0 := []
	col_0.resize(height)
	for y in range(col_0.size()):
		col_0[y] = init_value
		
	array = []
	array.resize(width)
	for x in range(array.size()):
		array[x] = col_0.duplicate()

func has_index(x: int, y: int) -> bool:
	if(x >= 0 && x < width && y >= 0 && y < height):
		return true
	return false
	
func has_index_v(index: Vector2i) -> bool:
	if(index.x >= 0 && index.x < width && index.y >= 0 && index.y < height):
		return true
	return false

func get_from(x: int, y: int):
	return array[x][y]
	
func get_from_v(index: Vector2i):
	return array[index.x][index.y]
	
func set_to(x: int, y: int, value):
	array[x][y] = value
	
func set_to_v(index: Vector2i, value):
	array[index.x][index.y] = value
