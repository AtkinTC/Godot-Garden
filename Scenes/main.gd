extends Node2D

@onready var seeds_list : ItemList = $Control/H/LPanel/SeedsList
var plant_list_indexes := {}

var step_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	# seeds list
	seeds_list.clear()
	
	var index := 0
	for plant_key in PlantManager.get_plant_type_keys():
		var plant_type : Dictionary = PlantManager.get_plant_type(plant_key)
		seeds_list.add_item(plant_type["display_name"])
		plant_list_indexes[index] = plant_key
		
		if(index == 0):
			PlantManager.set_selected_plant_key(plant_key)
			seeds_list.select(0)
		
		index += 1
	
	#start step timer
	step_timer = Timer.new()
	step_timer.wait_time = 0.1
	step_timer.one_shot = true
	step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(step_timer)
	step_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_step_timer_timeout():
	PlantManager.step_garden_plots()
	
	step_timer.start()

func _on_seeds_list_item_selected(index):
	PlantManager.set_selected_plant_key(plant_list_indexes[index])
