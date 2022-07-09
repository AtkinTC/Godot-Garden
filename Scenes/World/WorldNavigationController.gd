class_name WorldNavigationController
extends Node2D

@onready var a_star : AStar2D = AStar2D.new()

var max_x : int = 20
var max_y : int = 20

func _ready() -> void:
	setup_points()

# adds all world tiles as points for navigation
# subsequent calls will add in any new world tiles without regenerating the whole map
# currently assuming new tiles are added but never removed
func setup_points():
	var world_used_points : Array = GardenManager.get_used_plots()
	
	var new_points : Array = []
	
	# add world tiles to the AStar as points
	for i in world_used_points.size():
		var point : Vector2i = world_used_points[i]
		var id = coord_to_id(point)
		if(!a_star.has_point(id)):
			new_points.append(point)
			a_star.add_point(id, point)
	
	# setup connections for any newly added points with their neighbors
	for i in new_points.size():
		var point : Vector2i = new_points[i]
		var id = coord_to_id(point)
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var neighbor_id = coord_to_id(point + d)
			if(a_star.has_point(neighbor_id)):
				a_star.connect_points(id, neighbor_id)

# creates a list of coordinate points from the start point to the end point, inclusive
# returns an empty array if either point is invalid or if there is no valid path
func get_nav_path(point_a : Vector2i , point_b : Vector2i) -> PackedVector2Array:
	setup_points()
	
	var id_a := coord_to_id(point_a)
	var id_b := coord_to_id(point_b)
	if(id_a == id_b):
		return PackedVector2Array()
	if(!a_star.has_point(id_a) || !a_star.has_point(id_b)):
		return PackedVector2Array()
	
	var point_path = a_star.get_point_path(id_a, id_b)
	
	return point_path

# returns the next point coord (Vector2i) in the path from the start point to the end point
# or null if there is no next valid point
func get_next_path_step(point_a : Vector2i , point_b : Vector2i):
	var path := get_nav_path(point_a, point_b)
	if(path.size() <= 1):
		return null
	return (path[1] as Vector2i)

# converts a Vector2i to a unique integer id value
func coord_to_id(coord : Vector2i) -> int:
	assert(abs(coord.x) <= max_x)
	assert(abs(coord.y) <= max_y)
	
	var id : int = abs(coord.y) * max_x + abs(coord.x)
	if(coord.x < 0 && coord.y < 0):
		id += 3 * max_x * max_y
	elif(coord.y < 0):
		id += 2 * max_x * max_y
	elif(coord.x < 0):
		id += 1 * max_x * max_y
	return id

# converts an interger id value into it's corresponding Vector2i value 
func id_to_coord(id : int) -> Vector2i:
	var coord := Vector2i.ZERO
	
	var sign_comp : int = floor(id/(max_x * max_y))
	id -= sign_comp * max_x * max_y
	
	coord.x = modi(id, max_x)
	coord.y = (id - coord.x) / max_x
	
	if(sign_comp == 3):
		coord.x *= -1
		coord.y *= -1
	elif(sign_comp == 2):
		coord.y *= -1
	elif(sign_comp == 1):
		coord.x *= -1
	
	return coord

# custom mod function added because I was running into strange issues with the build in % mod function
func modi(a : int, b: int) -> int:
	var q : int = floor(a/b)
	return a - (b * q)
