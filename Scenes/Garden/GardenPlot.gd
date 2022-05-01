class_name GardenPlot

var coord : Vector2 = Vector2.ZERO

var planted : bool = false
var grow_progress : int = 0
var grow_capacity : int = 1000

var water_capacity : int = 500
var water_level : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_coord(_coord : Vector2):
	coord = _coord

func plant_plot():
	planted = true

func water_plot():
	water_level = water_capacity

func step():
	if(grow_progress >= grow_capacity):
		planted = false
		grow_progress = 0
	
	if(planted):
		grow_progress += 2 if water_level > 0 else 1
	
	if(water_level > 0 && planted):
		water_level -= 1

func get_coord() -> Vector2:
	return coord

func is_planted() -> bool:
	return planted

func get_water_level() -> int:
	return water_level

func get_water_capacity() -> int:
	return water_capacity

func get_grow_progress() -> int:
	return grow_progress

func get_grow_capacity() -> int:
	return grow_capacity
	
