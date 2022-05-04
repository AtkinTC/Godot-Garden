class_name GardenPlot

var coord : Vector2 = Vector2.ZERO

var plant_key : String
var planted : bool = false
var grow_progress : float = 0
var grow_capacity : float = 1000

var water_capacity : float = 60
var water_level : float = 0

var grow_speed_unsatisfied : float = 1
var grow_speed_satisfied : float = 1
var water_consumption : float = 1

var plant_display_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_coord(_coord : Vector2):
	coord = _coord
  
func plant_plot(_plant_key : String= ""):
	if(planted):
		return false
	
	if(_plant_key == ""):
		plant_key = PlantManager.selected_plant_key
	else:
		plant_key = _plant_key
	
	var plant_type := PlantManager.get_plant_type(plant_key)
	
	if(plant_type == null || plant_type.size() == 0):
		return
	
	var purchase_price : Dictionary = plant_type[PlantManager.PURCHASE_PRICE]
	if(!PurchaseManager.can_afford(purchase_price)):
		return
	PurchaseManager.spend(purchase_price)
	
	planted = true
	grow_progress = 0
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

func complete_plant_growth():
	if(grow_progress < grow_capacity):
		return
	
	if(plant_key == null || plant_key == ""):
		return
	
	# gain resources from 'selling' the grown plant
	var sell_price : Dictionary = PlantManager.get_plant_type_attribute(plant_key, PlantManager.SELL_PRICE)
	for resource_key in sell_price:
		var current_amount = ResourceManager.get_resource_attribute(resource_key, ResourceManager.AMOUNT)
		ResourceManager.set_resource_attribute(resource_key, ResourceManager.AMOUNT, current_amount + sell_price[resource_key])
	
	# reset growth progress 
	grow_progress = 0

func step(step_time : float):
	if(grow_progress >= grow_capacity):
		complete_plant_growth()
	
	if(planted):
		if water_level >= water_consumption:
			grow_progress += (grow_speed_satisfied * step_time)
		else:
			grow_progress += (grow_speed_unsatisfied * step_time)
	
	if(water_level > 0 && planted):
		water_level = max(0, water_level - (water_consumption * step_time))

func get_coord() -> Vector2:
	return coord

func is_planted() -> bool:
	return planted

func get_plant_display_name() -> String:
	return plant_display_name

func get_water_level() -> float:
	return water_level

func get_water_capacity() -> float:
	return water_capacity

func get_grow_speed_unsatisfied() -> float:
	return grow_speed_unsatisfied

func get_grow_speed_satisfied() -> float:
	return grow_speed_satisfied

func get_grow_progress() -> float:
	return grow_progress

func get_grow_capacity() -> float:
	return grow_capacity
	
