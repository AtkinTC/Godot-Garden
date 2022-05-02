class_name GardenPlot

var coord : Vector2 = Vector2.ZERO

var plant_key : String
var planted : bool = false
var grow_progress : int = 0
var grow_capacity : int = 1000

var water_capacity : int = 500
var water_level : int = 0

var grow_speed_unsatisfied : int = 1
var grow_speed_satisfied : int = 1
var water_consumption : int = 1

var plant_display_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_coord(_coord : Vector2):
	coord = _coord
  
func plant_plot(_plant_key : String= ""):
	if(_plant_key == ""):
		plant_key = PlantManager.selected_plant_key
	else:
		plant_key = _plant_key
	
	var plant_type := PlantManager.get_plant_type(plant_key)
	
	if(plant_type == null || plant_type.size() == 0):
		return
		
	planted = true
	grow_capacity = plant_type[PlantManager.GROW_CAPACITY]
	grow_speed_unsatisfied = plant_type[PlantManager.GROW_SPEED_UNSATISFIED]
	grow_speed_satisfied = plant_type[PlantManager.GROW_SPEED_SATISFIED]
	water_consumption = plant_type[PlantManager.WATER_CONSUMPTION]
	plant_display_name = plant_type[PlantManager.DISPLAY_NAME]

func water_plot(water_amount : int = -1, override_capacity : bool = false):
	var new_water_level = water_level
	if(water_amount == -1):
		## fills to capacity, or doesn't change if already above capacity
		new_water_level = max(water_capacity, water_level)
	else:
		new_water_level = water_level + water_amount
		if(!override_capacity):
			## increase is capped by water_capacity, but doesn't change if already above capacity
			new_water_level = max(water_level, min(new_water_level, water_capacity))
	
	water_level = new_water_level

func step():
	if(grow_progress >= grow_capacity):
		planted = false
		grow_progress = 0
	
	if(planted):
		grow_progress += grow_speed_satisfied if water_level >= water_consumption else grow_speed_unsatisfied
	
	if(water_level > 0 && planted):
		water_level -= water_consumption

func get_coord() -> Vector2:
	return coord

func is_planted() -> bool:
	return planted

func get_plant_display_name() -> String:
	return plant_display_name

func get_water_level() -> int:
	return water_level

func get_water_capacity() -> int:
	return water_capacity

func get_grow_speed_unsatisfied() -> int:
	return grow_speed_unsatisfied

func get_grow_speed_satisfied() -> int:
	return grow_speed_satisfied

func get_grow_progress() -> int:
	return grow_progress

func get_grow_capacity() -> int:
	return grow_capacity
	
