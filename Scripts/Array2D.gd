class_name Array2D

var size : Vector2
var array : Array
var offset : Vector2

func _init(_size : Vector2 = Vector2.ZERO, _offset : Vector2 = Vector2.ZERO):
	size = _size
	offset = _offset
	
	var col_0 := []
	col_0.resize(size.y as int)
	for y in range(col_0.size()):
		col_0[y] = null
	
	array = []
	array.resize(size.x as int)
	for x in range(array.size()):
		array[x] = col_0.duplicate()

func get_size() -> Vector2:
	return size

func get_offset() -> Vector2:
	return offset

func set_offset(_offset : Vector2):
	offset = _offset

func set_at(_coord : Vector2, _value):
	var adj_coord : Vector2= _coord - offset
	if(adj_coord.x < 0 || adj_coord.x >= size.x):
		return null
	if(adj_coord.y < 0 || adj_coord.y >= size.y):
		return null
	
	array[adj_coord.x][adj_coord.y] = _value

func get_at(_coord : Vector2):
	var adj_coord : Vector2 = _coord - offset
	if(adj_coord.x < 0 || adj_coord.x >= size.x):
		return null
	if(adj_coord.y < 0 || adj_coord.y >= size.y):
		return null
	
	return array[adj_coord.x][adj_coord.y]

func min_x() -> int:
	return offset.x as int

func max_x() -> int:
	return offset.x + size.x - 1 as int

func min_y() -> int:
	return offset.y as int

func max_y() -> int:
	return offset.y + size.y - 1 as int

func range_x() -> Array:
	return range(offset.x, size.x + offset.x)

func range_y() -> Array:
	return range(offset.y, size.y + offset.y)

func insert(array2d : Array2D):
	for x in array2d.range_x():
		for y in array2d.range_y():
			set_at(Vector2(x,y), array2d.get_at(Vector2(x,y)))
