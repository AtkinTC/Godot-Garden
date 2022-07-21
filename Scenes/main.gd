extends Node2D

@onready var world : World = $World
@onready var cam : Camera2D = $Camera

func _init():
	GardenManager.initialize()

func _ready():
	var load_success : bool = SaveController.load_as_current_save_file("test")
	
	if(load_success):
		var current_save_file := SaveController.get_current_save_file()
		GardenManager.setup_from_plots_array(current_save_file.world_plots)
	else:
		setup_test_data()
	
	var center : Vector2 = world.get_world_center()
	print(center)
	cam.set_position(center)
	
	#get_tree().create_timer(10).timeout.connect(_autosave)

#TODO: remove this test code
func setup_test_data():
	pass
	#example plot areas for testing purposes
	#var center_plot : PlotVO = GardenManager.create_plot(Vector2(0,0), "road_00", "blank")
	#GardenManager.complete_exploration(center_plot.get_coord())

func _process(_delta):
	GardenManager.step_plots(_delta)

func _autosave():
	var current_save : SaveFileResource = SaveController.get_current_save_file()
	if(current_save == null):
		current_save = SaveController.create_new_save_file("test")
		
	current_save.world_plots = GardenManager.get_used_plots()
	
	SaveController.save_current_save_file()
	get_tree().create_timer(10).timeout.connect(_autosave)
