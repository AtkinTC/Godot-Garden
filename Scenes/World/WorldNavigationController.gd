class_name WorldNavigationController
extends Node2D

var a_star : AStar2D
var coord_to_id : Dictionary

func _ready() -> void:
	initialize()

func initialize():
	a_star = AStar2D.new()
	coord_to_id = {}
	setup_points()

# adds all world tiles as points for navigation
# subsequent calls will add in any new world tiles without regenerating the whole map
# currently assuming new tiles are added but never removed
func setup_points():
	var new_coords : Array = []
	
	# add world tiles to the AStar as points
	for coord in GardenManager.get_used_plot_coords():
		if(!coord_to_id.has(coord)):
			var id : int = a_star.get_available_point_id()
			coord_to_id[coord] = id
			new_coords.append(coord)
			a_star.add_point(id, coord)
	
	# setup connections for any newly added points with their neighbors
	for i in new_coords.size():
		var coord : Vector2i = new_coords[i]
		if(!coord_to_id.has(coord)):
			continue
		var id : int = coord_to_id[coord]
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var n_coord : Vector2i = coord + d
			if(!coord_to_id.has(n_coord)):
				continue
			var n_id : int = coord_to_id[n_coord]
			a_star.connect_points(id, n_id)

# creates a list of coordinate points from the start point to the end point, inclusive
# returns an empty array if either point is invalid or if there is no valid path
func get_nav_path(coord_a : Vector2i , coord_b : Vector2i) -> PackedVector2Array:
	setup_points()
	
	if(!coord_to_id.has(coord_a) || !coord_to_id.has(coord_b)):
		return PackedVector2Array()
	
	var id_a : int = coord_to_id[coord_a]
	var id_b : int = coord_to_id[coord_b]
	if(id_a == id_b):
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
